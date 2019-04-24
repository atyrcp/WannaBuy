//
//  BLTPaymentViewController.m
//  Bolt iOS SDK
//
//  Created by Laurence Andersen on 11/14/16.
//  Copyright © 2016 Bolt. All rights reserved.
//

#import "BLTPaymentViewController.h"
#import <WebKit/WebKit.h>

NSString * const BLTErrorDomain = @"BoltErrorDomain";
NSString * const BLTConfigurationException = @"ConfigurationException";
NSString * const BLTCurrencyException = @"CurrencyException";
NSString * const BLTCartItemException = @"CartItemException";
NSString * const BLTAddressException = @"AddressException";

NSString * const BLTMerchantIDInfoPlistKey = @"BLTMerchantKey";
NSString * const BLTServerEnvironmentInfoPlistKey = @"BLTServerEnvironment";

NSString * const BLTProductionURLString = @"https://connect-cdn.boltapp.com/connect.js";
NSString * const BLTSandboxURLString = @"https://cdn-connect-sandbox.boltapp.com/connect.js";

NSString * const BLTJSMessageHandlerNameSuccess = @"handleSuccess";
NSString * const BLTJSMessageHandlerNameClose = @"handleClose";
NSString * const BLTJSMessageHandlerNameError = @"handleError";

const NSInteger BLTErrorDomainJavascriptErrorCode = -1000;


@protocol BLTSerializable <NSObject>

- (id)serializableRepresentationForCurrencyType:(BLTCurrencyType)currencyType;

@end


@interface BLTPaymentViewController () <WKScriptMessageHandler, WKNavigationDelegate, WKUIDelegate>

@property (strong, nonatomic, readwrite) BLTPaymentViewConfiguration *configuration;
@property (strong, nonatomic, readwrite) BLTCart *cart;
@property (strong, nonatomic, readwrite) BLTPayerInfo *payerInfo;
@property (nonatomic, strong) WKWebView *webView;

- (void)configureWebView;
- (void)loadBoltUI;

@end


@interface BLTPaymentViewConfiguration ()

@property (readonly) NSString *connectURL;

@end


@interface BLTCart () <BLTSerializable>

@property (strong, nonatomic, readwrite) NSString *cartID;

@property (strong, nonatomic) NSNumber *customCartTotal;
@property (nonatomic) NSInteger calculatedCartTotal;

@property (strong, nonatomic) NSMutableArray<BLTCartItem *> *items;
@property (strong, nonatomic) NSMutableArray<BLTLineItem *> *taxItems;
@property (strong, nonatomic) NSMutableArray<BLTLineItem *> *discountItems;
@property (strong, nonatomic) NSMutableArray<BLTLineItem *> *shippingItems;

@property (strong, nonatomic) NSData *JSONRepresentation;
@property (strong, nonatomic) NSString *JSONStringRepresentation;

- (void)addTaxItemWithDescription:(NSString *)description amount:(NSInteger)amount;
- (void)clearTaxItems;

- (void)addShippingItemWithDescription:(NSString *)description amount:(NSInteger)amount;
- (void)clearShippingItems;

@end


@interface BLTCartItem () <BLTSerializable>

@property (strong, nonatomic, readwrite) NSString *referenceID;

- (NSString *)priceStringForCurrencyType:(BLTCurrencyType)currencyType;

@end


@interface BLTLineItem () <BLTSerializable>

@property (strong, nonatomic) NSString *descriptionKey;
@property (strong, nonatomic) NSString *amountKey;

- (NSString *)amountStringForCurrencyType:(BLTCurrencyType)currencyType;

@end


@interface BLTPayerInfo ()

@property (strong, nonatomic) NSDictionary *userBillingAddress;
@property (strong, nonatomic) NSDictionary *userShippingAddress;

@property (strong, nonatomic) NSString *merchantKey;
@property (strong, nonatomic) NSString *merchantID;
@property (strong, nonatomic) NSString *merchantSignature;
@property (strong, nonatomic) NSString *merchantNonce;

@property (readonly) NSData *JSONRepresentation;

- (NSDictionary *)addressDictionaryWithLines:(NSArray *)lines city:(NSString *)city state:(NSString *)state country:(NSString *)country;


@end


@interface NSArray (BLTConveniences)

- (NSArray *)BLT_serializableRepresentationForCurrencyType:(BLTCurrencyType)currencyType;

@end


NSString * BLTFormatAmountForCurrencyType(NSInteger amount, BLTCurrencyType currencyType);
NSNumberFormatter * BLTNumberFormatterForCurrencyType (BLTCurrencyType currencyType);

#pragma mark -

@implementation BLTPaymentViewController

#pragma mark Initialization

- (instancetype)initWithCart:(BLTCart *)cart payerInfo:(BLTPayerInfo *)payerInfo
{
    if (!(self = [super initWithNibName:nil bundle:nil])) {
        return nil;
    }
    
    _cart = cart;
    _payerInfo = payerInfo;
    _configuration = [BLTPaymentViewConfiguration defaultPaymentViewConfiguration];
    
    return self;
}

- (instancetype)initWithCart:(BLTCart *)cart payerInfo:(BLTPayerInfo *)payerInfo configuration:(BLTPaymentViewConfiguration *)configuration
{
    if (!(self = [super initWithNibName:nil bundle:nil])) {
        return nil;
    }

    _cart = cart;
    _payerInfo = payerInfo;
    _configuration = configuration;
    
    return self;
}

#pragma mark View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithWhite:0.97 alpha:1.0];
    
    [self configureWebView];
    [self.view addSubview:_webView];
    
    [self.webView.topAnchor constraintEqualToAnchor:self.topLayoutGuide.bottomAnchor].active = YES;
    [self.webView.bottomAnchor constraintEqualToAnchor:self.bottomLayoutGuide.bottomAnchor].active = YES;
    [self.webView.leftAnchor constraintEqualToAnchor:self.view.leftAnchor].active = YES;
    [self.webView.rightAnchor constraintEqualToAnchor:self.view.rightAnchor].active  = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [self loadBoltUI];
}

#pragma mark Web View Configuration 

- (void)configureWebView
{
    WKWebViewConfiguration *webViewConfiguration = [[WKWebViewConfiguration alloc] init];
    WKUserContentController *contentController = [[WKUserContentController alloc] init];
    [contentController addScriptMessageHandler:self name:BLTJSMessageHandlerNameSuccess];
    [contentController addScriptMessageHandler:self name:BLTJSMessageHandlerNameClose];
    [contentController addScriptMessageHandler:self name:BLTJSMessageHandlerNameError];
    webViewConfiguration.userContentController = contentController;
    
    NSString *encodedCartJSONString = [self.cart.JSONRepresentation base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    NSString *encodedPayerInfoJSONString = [self.payerInfo.JSONRepresentation base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    
    NSString *scriptString = [NSString stringWithFormat:@"window.onload = function() { var encoded_cart_data = \'%@\'; var decoded_cart_data = window.atob(encoded_cart_data); var cart_json = JSON.parse(decoded_cart_data); var encoded_configuration_data = \'%@\'; var decoded_configuration_data = window.atob(encoded_configuration_data); var configuration_json = JSON.parse(decoded_configuration_data); BoltConnect.process(cart_json, configuration_json, { close: function() { window.webkit.messageHandlers.%@.postMessage(\"Close\") }, success: function(transaction, callback) { window.webkit.messageHandlers.%@.postMessage(JSON.stringify(transaction)); } }); } \n window.onerror = function(msg, url, lineNo, columnNo, error) { window.webkit.messageHandlers.%@.postMessage(msg); return true; } \n ", encodedCartJSONString, encodedPayerInfoJSONString, BLTJSMessageHandlerNameClose, BLTJSMessageHandlerNameSuccess, BLTJSMessageHandlerNameError];
    WKUserScript *script = [[WKUserScript alloc] initWithSource:scriptString injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:NO];
    [contentController addUserScript:script];
    
    _webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:webViewConfiguration];
    _webView.translatesAutoresizingMaskIntoConstraints = NO;
    
    _webView.navigationDelegate = self;
    _webView.UIDelegate = self;
    _webView.scrollView.delegate = self;
}

#pragma mark Bolt

- (void)loadBoltUI
{
    if (self.configuration.merchantKey == nil || self.configuration.connectURL == nil) {
        [[NSException exceptionWithName:BLTConfigurationException reason:@"Invalid Bolt configuration: missing merchant key or connect URL." userInfo:nil] raise];
        return;
    }
    
    NSString *HTMLString = [NSString stringWithFormat:@"<html><head><meta name=\"viewport\" content=\"width=device-width\"><script id=\"bolt-connect\" type=\"text/javascript\" src=\"%@\" data-merchant-key=\"%@\"></script></head><body></body></html>", self.configuration.connectURL, self.configuration.merchantKey];
    
    [self.webView loadHTMLString:HTMLString baseURL:nil];
}

#pragma mark WKScriptMessageHandler

- (void)userContentController:(WKUserContentController *)controller didReceiveScriptMessage:(nonnull WKScriptMessage *)message {
    if ([message.name isEqualToString:BLTJSMessageHandlerNameSuccess]) {
        [self.delegate paymentViewControllerPaymentDidSucceed:self withTransactionJSONBlob:message.body];
    } else if ([message.name isEqualToString:BLTJSMessageHandlerNameClose]) {
        [self.delegate paymentViewControllerDidClose:self];
    } else if ([message.name isEqualToString:BLTJSMessageHandlerNameError]) {
        [self.delegate paymentViewController:self didEncounterError:[NSError errorWithDomain:BLTErrorDomain code:BLTErrorDomainJavascriptErrorCode userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"JavaScript Error", @""), NSLocalizedFailureReasonErrorKey: message.body}]];
    }
}

#pragma mark WKUIDelegate

- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[frame.request.URL absoluteString] message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }];
    [alertController addAction:action];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[frame.request.URL absoluteString] message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(false);
    }];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(true);
    }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark WKNavigationDelegate

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    [self.delegate paymentViewController:self didEncounterError:error];
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    [self.delegate paymentViewController:self didEncounterError:error];
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    
    if ([navigationResponse.response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSHTTPURLResponse * response = (NSHTTPURLResponse *)navigationResponse.response;
        if (response.statusCode >= 400) {
            [self.delegate paymentViewController:self didEncounterError:[NSError errorWithDomain:BLTErrorDomain code:response.statusCode userInfo:nil]];
        }
    }
    
    decisionHandler(WKNavigationResponsePolicyAllow);
}

#pragma mark UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return nil;
}

@end

#pragma mark -

@implementation BLTPaymentViewConfiguration

#pragma mark Class Methods

+ (instancetype)defaultPaymentViewConfiguration
{
    NSString *merchantKey = [[NSBundle mainBundle] objectForInfoDictionaryKey:BLTMerchantIDInfoPlistKey];
    NSNumber *serverEnvironmentNumber = [[NSBundle mainBundle] objectForInfoDictionaryKey:BLTServerEnvironmentInfoPlistKey];

    if (merchantKey == nil) {
        [[NSException exceptionWithName:BLTConfigurationException reason:@"Default Bolt configuration is being used but Info.plist is missing BLTMerchantKey key." userInfo:nil] raise];
        return nil;
    }
    
    BLTPaymentViewConfiguration *paymentViewConfiguration = [[BLTPaymentViewConfiguration alloc] initWithMerchantKey:merchantKey];
    
    BLTServerEnvironment serverEnv = BLTServerEnvironmentProduction;
    
    if (serverEnvironmentNumber != nil) {
        NSInteger serverEnvironment = serverEnvironmentNumber.integerValue;
        if (serverEnvironment > 0) {
            serverEnv = BLTServerEnvironmentSandbox;
        }
    }
    
    paymentViewConfiguration.serverEnvironment = serverEnv;
    
    return paymentViewConfiguration;
}

+ (instancetype)paymentViewConfigurationWithMerchantKey:(NSString *)merchantKey
{
    BLTPaymentViewConfiguration *configuration = [[BLTPaymentViewConfiguration alloc] initWithMerchantKey:merchantKey];
    return configuration;
}

#pragma mark Initialization

- (instancetype)initWithMerchantKey:(NSString *)merchantKey
{
    if (!(self = [super init])) {
        return nil;
    }
    
    _merchantKey = merchantKey;
    
    return self;
}

#pragma mark Environment

- (NSString *)connectURL
{
    NSString *connectURL = BLTProductionURLString;
    switch (self.serverEnvironment) {
        case BLTServerEnvironmentSandbox:
            connectURL = BLTSandboxURLString;
            break;
        default:
            break;
    }
    
    return connectURL;
}

@end

#pragma mark -

@implementation BLTCart

#pragma mark Initialization

- (instancetype)initWithCartID:(NSString *)cartID
{
    if (!(self = [super init])) {
        return nil;
    }
    
    _cartID = cartID;
    _customCartTotal = nil;
    
    _items = [[NSMutableArray alloc] init];
    _discountItems = [[NSMutableArray alloc] init];
    _taxItems = [[NSMutableArray alloc] init];
    _shippingItems = [[NSMutableArray alloc] init];
    
    _currency = BLTCurrencyTypeUSDollars;
    
    return self;
}

#pragma mark Currency

- (void)setCurrencyWithISO4217String:(NSString *)currencyString
{
    if (![currencyString isEqualToString:@"USD"]) {
        [[NSException exceptionWithName:BLTCurrencyException reason:@"The specified currency is not currently supported." userInfo:nil] raise];
    }
}

#pragma mark Cart Total

- (NSInteger)cartTotal
{
    return (_customCartTotal != nil) ? _customCartTotal.integerValue : self.calculatedCartTotal;
}

- (void)overrideCalculatedCartTotalWithAmount:(NSInteger)amount
{
    _customCartTotal = @(amount);
}

- (void)clearOverridenCartTotal
{
    _customCartTotal = nil;
}

- (NSInteger)calculatedCartTotal
{
    NSInteger itemsTotal = 0;
    
    for (BLTCartItem *currentItem in self.cartItems) {
        itemsTotal += currentItem.price * currentItem.quantity;
    }

    NSInteger shippingTotal = 0;
    
    for (BLTLineItem *currentShippingItem in self.shippingItems) {
        shippingTotal += currentShippingItem.amount;
    }
    
    NSInteger discountsTotal = 0;
    
    for (BLTLineItem *currentDiscountItem in self.discountItems) {
        discountsTotal += currentDiscountItem.amount;
    }
    
    NSInteger taxesTotal = 0;
    
    for (BLTLineItem *currentTaxItem in self.taxItems) {
        taxesTotal = currentTaxItem.amount;
    }
    
    return (itemsTotal + shippingTotal - discountsTotal) + taxesTotal;
}

#pragma mark Cart Items

- (NSArray *)cartItems
{
    return [self.items sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"referenceID" ascending:YES]]];
}

- (void)addCartItem:(BLTCartItem *)cartItem
{
    if (cartItem == nil) {
        [[NSException exceptionWithName:BLTCartItemException reason:@"Attempted to add a nil item to the cart." userInfo:nil] raise];
        return;
    }
    
    [self.items addObject:cartItem];
}

- (void)clearCartItems
{
    [self.items removeAllObjects];
}

#pragma mark Taxes

- (void)setTaxAmount:(NSInteger)amount withDescription:(NSString *)description
{
    [_taxItems removeAllObjects];
    [self addTaxItemWithDescription:description amount:amount];
}

- (void)addTaxItemWithDescription:(NSString *)description amount:(NSInteger)amount
{
    if (description == nil) {
        [[NSException exceptionWithName:BLTCartItemException reason:@"Attempted to add a nil tax item to the cart." userInfo:nil] raise];
        return;
    }
    
    [_taxItems addObject:[BLTLineItem lineItemWithDescription:description amount:amount]];
}

- (void)clearTaxItems
{
    [_taxItems removeAllObjects];
}

#pragma mark Discounts

- (NSArray *)discountItems
{
    return _discountItems;
}

- (void)addDiscountItemWithDescription:(NSString *)description amount:(NSInteger)amount
{
    if (description == nil) {
        [[NSException exceptionWithName:BLTCartItemException reason:@"Attempted to add a nil discount item to the cart." userInfo:nil] raise];
        return;
    }
    
    BLTLineItem *lineItem = [BLTLineItem lineItemWithDescription:description amount:amount];
    lineItem.descriptionKey = @"description";
    lineItem.amountKey = @"amount";
    
    [_discountItems addObject:lineItem];
}

- (void)clearDiscountItems
{
    [_discountItems removeAllObjects];
}

#pragma mark Shipping

- (void)setShippingAmount:(NSInteger)amount withDescription:(NSString *)description
{
    [_shippingItems removeAllObjects];
    [self addShippingItemWithDescription:description amount:amount];
}

- (void)addShippingItemWithDescription:(NSString *)description amount:(NSInteger)amount
{
    if (description == nil) {
        [[NSException exceptionWithName:BLTCartItemException reason:@"Attempted to add a nil shipping item to the cart." userInfo:nil] raise];
        return;
    }
    
    [_shippingItems addObject:[BLTLineItem lineItemWithDescription:description amount:amount]];
}

- (void)clearShippingItems
{
    [_shippingItems removeAllObjects];
}

#pragma mark Serialization

- (id)serializableRepresentationForCurrencyType:(BLTCurrencyType)currencyType
{
    NSMutableDictionary *serializableRepresentation = [[NSMutableDictionary alloc] init];
    
    [serializableRepresentation setObject:self.cartID forKey:@"id"];
    [serializableRepresentation setObject:BLTFormatAmountForCurrencyType(self.cartTotal, currencyType) forKey:@"total"];
    
    // Cart Items
    [serializableRepresentation setObject:[self.cartItems BLT_serializableRepresentationForCurrencyType:currencyType] forKey:@"items"];
    
    // Tax
    [serializableRepresentation setObject:[[self.taxItems firstObject] serializableRepresentationForCurrencyType:currencyType] forKey:@"tax"];
    
    // Shipping
    [serializableRepresentation setObject:[[self.shippingItems firstObject] serializableRepresentationForCurrencyType:currencyType] forKey:@"shipping"];
    
    // Discounts
    [serializableRepresentation setObject:[self.discountItems BLT_serializableRepresentationForCurrencyType:currencyType] forKey:@"discounts"];
    
    return serializableRepresentation;
}

#pragma mark JSON

- (NSData *)JSONRepresentation
{
    id serializableRepresentation = [self serializableRepresentationForCurrencyType:self.currency];
    
    NSData *JSONData = [NSJSONSerialization dataWithJSONObject:serializableRepresentation options:NSJSONWritingPrettyPrinted error:NULL];
    
    return JSONData;
}

- (NSString *)JSONStringRepresentation
{
    return [[NSString alloc] initWithData:self.JSONRepresentation encoding:NSUTF8StringEncoding];
}

@end

#pragma mark -

@implementation BLTCartItem

#pragma mark Initialization

- (instancetype)initWithReferenceID:(NSString *)referenceID
{
    if (!(self = [super init])) {
        return nil;
    }
    
    _referenceID = referenceID;
    _quantity = 1;
    
    return self;
}

- (NSString *)priceStringForCurrencyType:(BLTCurrencyType)currencyType
{
    return BLTFormatAmountForCurrencyType(self.price, currencyType);
}


- (id)serializableRepresentationForCurrencyType:(BLTCurrencyType)currencyType
{
    NSMutableDictionary *serializableRepresentation = [[NSMutableDictionary alloc] init];
    
    if (self.referenceID) {
        [serializableRepresentation setObject:self.referenceID forKey:@"reference"];
    }
    
    if (self.name) {
        [serializableRepresentation setObject:self.name forKey:@"name"];
    }
    
    if (self.itemDescription) {
        [serializableRepresentation setObject:self.itemDescription forKey:@"desc"];
    }
    
    if (self.imageURL != nil) {
        [serializableRepresentation setObject:self.imageURL forKey:@"imageURL"];
    }
    
    NSString *priceString = [self priceStringForCurrencyType:currencyType];
    if (priceString != nil) {
        [serializableRepresentation setObject:priceString forKey:@"price"];
    }
    
    [serializableRepresentation setObject:@(self.quantity) forKey:@"quantity"];
    
    return serializableRepresentation;
}

@end

#pragma mark - 

@implementation BLTLineItem

#pragma mark Class Methods

+ (BLTLineItem *)lineItemWithDescription:(NSString *)description amount:(NSInteger)amount
{
    BLTLineItem *lineItem = [[BLTLineItem alloc] init];
    lineItem.itemDescription = description;
    lineItem.amount = amount;
    
    return lineItem;
}

#pragma mark Initialization

- (instancetype)init
{
    if (!(self = [super init])) {
        return nil;
    }
    
    _descriptionKey = @"name";
    _amountKey = @"price";
    
    return self;
}

#pragma mark Currency Formatting

- (NSString *)amountStringForCurrencyType:(BLTCurrencyType)currencyType
{
    return BLTFormatAmountForCurrencyType(self.amount, currencyType);
}

#pragma mark Serialization

- (id)serializableRepresentationForCurrencyType:(BLTCurrencyType)currencyType
{
    NSString *amountString = [self amountStringForCurrencyType:currencyType];
    if (!amountString) {
        return nil;
    }
    
    return @{ self.descriptionKey : self.itemDescription, self.amountKey : amountString };
}

@end

#pragma mark -

@implementation BLTPayerInfo

#pragma mark Signed Merchant ID

- (void)setMerchantSignedUserID:(NSString *)userID withSignature:(NSString *)signature nonce:(NSString *)nonce
{
    if (!userID || !signature || !nonce) {
        [[NSException exceptionWithName:BLTConfigurationException reason:@"Missing required info for merchant signed ID." userInfo:nil] raise];
        return;
    }
    
    _merchantID = userID;
    _merchantSignature = signature;
    _merchantNonce = nonce;
}

- (void)setMerchantSignatureInfoWithJSONDictionary:(NSDictionary *)JSONDictionary
{
    if (!JSONDictionary) {
        [[NSException exceptionWithName:BLTConfigurationException reason:@"Missing required info for merchant signed ID." userInfo:nil] raise];
        return;
    }
    
    NSString *merchantID = [JSONDictionary objectForKey:@"merchant_user_id"];
    NSString *signature = [JSONDictionary objectForKey:@"signature"];
    NSString *nonce = [JSONDictionary objectForKey:@"nonce"];
    
    [self setMerchantSignedUserID:merchantID withSignature:signature nonce:nonce];
}

#pragma mark User Info

- (void)setUserShippingAddressWithLines:(NSArray *)lines city:(NSString *)city state:(NSString *)state country:(NSString *)country
{
    _userShippingAddress = [self addressDictionaryWithLines:lines city:city state:state country:country];
}

- (void)setUserBillingAddressWithLines:(NSArray *)lines city:(NSString *)city state:(NSString *)state country:(NSString *)country
{
    _userBillingAddress = [self addressDictionaryWithLines:lines city:city state:state country:country];
}

- (NSDictionary *)addressDictionaryWithLines:(NSArray *)lines city:(NSString *)city state:(NSString *)state country:(NSString *)country
{
    NSInteger linesCount = lines.count;
    
    if (!lines || linesCount > 4 || !city || !state) {
        [[NSException exceptionWithName:BLTAddressException reason:@"Invalid address information (did you specify more than 4 lines?) or missing address information." userInfo:nil] raise];
        return nil;
    }
    
    NSMutableDictionary *addressInfo = [[NSMutableDictionary alloc] init];
    
    for (NSInteger i = 0; i < linesCount; i++) {
        NSString *lineKey = [NSString stringWithFormat:@"address%ld", (long)i + 1];
        NSString *lineValue = [lines objectAtIndex:i];
        
        [addressInfo setObject:lineValue forKey:lineKey];
    }
    
    [addressInfo setObject:city forKey:@"city"];
    [addressInfo setObject:state forKey:@"state"];
    
    if (country != nil) {
        [addressInfo setObject:country forKey:@"country"];
    }
    
    return addressInfo;
}

#pragma mark JSON

- (NSData *)JSONRepresentation
{
    NSMutableDictionary *serializableRepresentation = [[NSMutableDictionary alloc] init];
    
    if (self.userFirstName != nil) {
        [serializableRepresentation setObject:self.userFirstName forKey:@"first_name"];
    }
    
    if (self.userLastName != nil) {
        [serializableRepresentation setObject:self.userLastName forKey:@"last_name"];
    }
    
    if (self.userPhoneNumber != nil) {
        [serializableRepresentation setObject:self.userPhoneNumber forKey:@"phone"];
    }
    
    if (self.userEmail != nil) {
        [serializableRepresentation setObject:self.userEmail forKey:@"email"];
    }
    
    if (self.userBillingAddress) {
        [serializableRepresentation setObject:self.userBillingAddress forKey:@"billing"];
    }
    
    if (self.userShippingAddress) {
        [serializableRepresentation setObject:self.userShippingAddress forKey:@"shipping"];
    }
    
    if (self.merchantID != nil && self.merchantNonce != nil && self.merchantSignature != nil) {
        NSMutableDictionary *merchantInfo = [[NSMutableDictionary alloc] init];
        [merchantInfo setObject:self.merchantID forKey:@"merchant_user_id"];
        [merchantInfo setObject:self.merchantNonce forKey:@"nonce"];
        [merchantInfo setObject:self.merchantSignature forKey:@"signature"];
        
        [serializableRepresentation setObject:merchantInfo forKey:@"signed_merchant_user_id"];
    }
    
    NSData *JSONData = [NSJSONSerialization dataWithJSONObject:serializableRepresentation options:NSJSONWritingPrettyPrinted error:NULL];
    
    return JSONData;
}

@end

#pragma mark -

@implementation NSArray (BLTConveniences)

- (id)BLT_serializableRepresentationForCurrencyType:(BLTCurrencyType)currencyType
{
    NSMutableArray *returnArray = [[NSMutableArray alloc] init];
    
    for (id<BLTSerializable> currentItem in self) {
        if (![currentItem conformsToProtocol:@protocol(BLTSerializable)]) {
            continue;
        }
        
        [returnArray addObject:[currentItem serializableRepresentationForCurrencyType:currencyType]];
    }
         
    return returnArray;
}

@end

#pragma mark - BLTTransactionResponse

@implementation BLTTransactionResponse

- (instancetype)initWithSerializedJSONBlob:(NSString *)jsonBlob {
    if (!(self = [super init])) {
        return nil;
    }
    
    NSError *e = nil;
    NSDictionary *transactionData = [NSJSONSerialization JSONObjectWithData: [jsonBlob dataUsingEncoding:NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: &e];
    
    _transactionID = [transactionData objectForKey:@"id"];
    _type = [transactionData objectForKey:@"type"];
    _epochDate = [[transactionData objectForKey:@"date"] integerValue];
    _transactionReference = [transactionData objectForKey:@"reference"];
    _status = [transactionData objectForKey:@"status"];
    NSDictionary *amount = [transactionData objectForKey:@"amount"];
    _transactionAmount = [[BLTTransactionAmount alloc] initWithCurrency:[amount objectForKey:@"currency"] withSymbol:[amount objectForKey:@"currency_symbol"] withAmount:[[amount objectForKey:@"amount"] intValue]];
    
    return self;
}

@end

#pragma mark - BLTTransactionAmount

@implementation BLTTransactionAmount

- (instancetype)initWithCurrency:(NSString *)currency withSymbol:(NSString *)symbol withAmount:(NSInteger)amount {
    if (!(self = [super init])) {
        return nil;
    }
    
    _currency = currency;
    _currencySymbol = symbol;
    _amount = amount;
    
    return self;
}

@end

NSString * BLTFormatAmountForCurrencyType(NSInteger amount, BLTCurrencyType currencyType) {
    NSNumberFormatter *formatter = BLTNumberFormatterForCurrencyType(currencyType);
    NSNumber *amountNumber = [NSNumber numberWithFloat:amount * .01];
    return [formatter stringFromNumber:amountNumber];
}

NSNumberFormatter * BLTNumberFormatterForCurrencyType (BLTCurrencyType currencyType) {
    static NSNumberFormatter *numberFormatter;
    
    if (numberFormatter == nil) {
        numberFormatter = [[NSNumberFormatter alloc] init];
        numberFormatter.numberStyle = NSNumberFormatterCurrencyStyle;
        numberFormatter.currencyCode = @"USD";
    }
    
    return numberFormatter;
}
