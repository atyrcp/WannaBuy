//
//  BLTPaymentViewController.h
//  Bolt iOS SDK
//
//  Created by Laurence Andersen on 11/14/16.
//  Copyright © 2016 Bolt. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BLTPaymentViewConfiguration;
@class BLTPayerInfo;
@class BLTCart;
@class BLTCartItem;
@class BLTLineItem;
@class BLTTransactionAmount;
@class BLTTransactionResponse;

@protocol BLTPaymentViewControllerDelegate;

extern NSString * const BLTErrorDomain;
extern NSString * const BLTConfigurationException;
extern NSString * const BLTCurrencyException;
extern NSString * const BLTCartItemException;
extern NSString * const BLTAddressException;

extern NSInteger const BLTErrorDomainJavascriptErrorCode;

typedef NS_ENUM(NSUInteger, BLTServerEnvironment) {
    BLTServerEnvironmentProduction,
    BLTServerEnvironmentSandbox
};

typedef NS_ENUM(NSUInteger, BLTCurrencyType) {
    BLTCurrencyTypeUSDollars
};


/**
 Handles the presentation and lifecycle of a Bolt payment form.
 */
@interface BLTPaymentViewController : UIViewController <UIScrollViewDelegate>

/**
 Specifies merchant-specific configuration options for the payment view.
 */
@property (nonatomic, readonly) BLTPaymentViewConfiguration *configuration;

/**
 Represents the monetary components of the transaction (items, tax, discounts). Must be specified at the time the view is initialized.
 */
@property (nonatomic, readonly) BLTCart *cart;

/**
 Optional information about the payer used to pre-fill the payment form. Must be specified at the time the view is initialized.
 */
@property (nonatomic, readonly) BLTPayerInfo *payerInfo;

/**
 The delegate that should receive notifications related to the payment view's lifecycle (payment success, error, view dismissed by user).
 */
@property (nonatomic, weak) id<BLTPaymentViewControllerDelegate> delegate;

/**
 The payment view controller's designated initializer. Will use the default configuration as specified in the Info.plist (see documentation for the configuration property).

 @param cart Required. Represents the monetary components of the transaction.
 @param payerInfo Optional. Used to pre-fill the payment form with the user's name and address information.
 @return A new payment view controller instance.
 */
- (instancetype)initWithCart:(BLTCart *)cart payerInfo:(BLTPayerInfo *)payerInfo;

/**
 Alternate initializer that allows for a custom (non-default) configuration.

 @param cart Required. Represents the monetary components of the transaction.
 @param payerInfo Optional. Used to pre-fill the payment form with the user's name and address information.
 @param configuration Optional. If not specified, the default configuration will be used (see documentation for the configuration property).
 @return A new payment view controller instance.
 */
- (instancetype)initWithCart:(BLTCart *)cart payerInfo:(BLTPayerInfo *)payerInfo configuration:(BLTPaymentViewConfiguration *)configuration;

@end


/**
  Specifies merchant-specific configuration options for the payment view. These values can be configured programatically in a custom configuration instance, or by including the keys BLTMerchantKey and BLTServerEnvironmentKey in the app's info.plist and creating a configuration instance through the defaultConfiguration class method. For BLTServerEnvironmentKey, a value of 0 specifies the production server environment, a value of 1 specifies the sandbox environment. Throws an exception if a default configuration instance is created but the BLTServerEnvironmentKey isn't present in the Info.plist. If BLTServerEnvironmentKey isn't present, production is assumed.
 */
@interface BLTPaymentViewConfiguration : NSObject

/**
 The Bolt server environment the view should use: either sandbox (for testing) or production.
 */
@property (nonatomic) BLTServerEnvironment serverEnvironment;

/**
 The merchant's unique Bolt identifier.
 */
@property (nonatomic, readonly) NSString *merchantKey;

/**
 Creates a configuration instance using the values specified in the app's Info.plist.

 @return A new configuration instance.
 */
+ (instancetype)defaultPaymentViewConfiguration;


/**
 Creates a custom configuration instance using the programatically specified key.

 @param merchantKey The merchant's unique Bolt key.
 @return A new configuration instance.
 */
+ (instancetype)paymentViewConfigurationWithMerchantKey:(NSString *)merchantKey;


/**
 Initializes a custom configuration instance using the programatically specified key.
 
 @param merchantKey The merchant's unique Bolt key.
 @return A new configuration instance.
 */
- (instancetype)initWithMerchantKey:(NSString *)merchantKey;

@end


/**
 The methods in BLTPaymentViewControllerDelegate aid in integration of the payment view into third party applications. Using these methods a merchant application can determine when various events in the payment view's lifecycle have occurred.
 */
@protocol BLTPaymentViewControllerDelegate <NSObject>

/**
 Called when a payment has succeeded.

 @param paymentViewController The payment view invoking the delegate method.
 */
- (void)paymentViewControllerPaymentDidSucceed:(BLTPaymentViewController *)paymentViewController withTransactionJSONBlob:(NSString *)jsonBlob;

/**
 Called when the payer dismisses the payment view from the UI without completing a successful payment.

 @param paymentViewController The payment view invoking the delegate method.
 */
- (void)paymentViewControllerDidClose:(BLTPaymentViewController *)paymentViewController;

/**
 Called when the payment view encounters either an HTTP error or a JavaScript exception.

 @param paymentViewController The payment view invoking the delegate method.
 @param error The error encountered. Will be in the BLTErrorDomain and will either be an HTTP code or BLTErrorDomainJavascriptErrorCode in the case of a JavaScript exception.
 */
- (void)paymentViewController:(BLTPaymentViewController *)paymentViewController didEncounterError:(NSError *)error;

@end


/**
 Represents information about the payer used to pre-fill the payment view form.
 */
@interface BLTPayerInfo : NSObject

@property (strong, nonatomic) NSString *userFirstName;
@property (strong, nonatomic) NSString *userLastName;
@property (nonatomic, readonly) NSDictionary *userBillingAddress;
@property (nonatomic, readonly) NSDictionary *userShippingAddress;
@property (strong, nonatomic) NSString *userPhoneNumber;
@property (strong, nonatomic) NSString *userEmail;

@property (nonatomic, readonly) NSString *merchantUserID;
@property (nonatomic, readonly) NSString *merchantSignature;
@property (nonatomic, readonly) NSString *merchantNonce;

/**
 Sets the payer's shipping address. No more than 4 lines are supported, and all parameters are required.

 @param lines An array of strings representing the payer's shipping address. Count must be less than or equal to 4.
 @param city The payer's shipping city.
 @param state The payer's shipping state.
 @param country The payer's shipping country.
 */
- (void)setUserShippingAddressWithLines:(NSArray <NSString *> *)lines city:(NSString *)city state:(NSString *)state country:(NSString *)country;

/**
 Sets the payer's billing address. No more than 4 lines are supported, and all parameters are required.
 
 @param lines An array of strings representing the payer's billing address. Count must be less than or equal to 4.
 @param city The payer's billing city.
 @param state The payer's billing state.
 @param country The payer's billing country.
 */
- (void)setUserBillingAddressWithLines:(NSArray <NSString *> *)lines city:(NSString *)city state:(NSString *)state country:(NSString *)country;

/**
 Adds the merchant's signed Bolt user ID to the payer info, which enables the payer to save the payment card with Bolt for future transactions.

 @param userID The merchant's Bolt user ID.
 @param signature A signature obtained from Bolt's API.
 @param nonce A nonce obtained from Bolt's API.
 */
- (void)setMerchantSignedUserID:(NSString *)userID withSignature:(NSString *)signature nonce:(NSString *)nonce;

/**
 A convenience method for adding the merchant's signed Bolt user ID to the payer info using a JSON object obtained from Bolt's API.

 @param JSONDictionary A signed user ID JSON object obtained from Bolt's API.
 */
- (void)setMerchantSignatureInfoWithJSONDictionary:(NSDictionary *)JSONDictionary;

@end


/**
 Represents the monetary components of a Bolt transaction.
 */
@interface BLTCart : NSObject

@property (nonatomic, readonly) NSString *cartID;

@property (nonatomic, readonly) NSInteger cartTotal;

@property (nonatomic, readonly) NSArray<BLTCartItem *> *cartItems;
@property (nonatomic, readonly) NSArray<BLTLineItem *> *discountItems;
@property (nonatomic, readonly) NSArray<BLTLineItem *> *taxItems;
@property (nonatomic, readonly) NSArray<BLTLineItem *> *shippingItems;

@property (nonatomic) BLTCurrencyType currency;

/**
 Initializes a cart with a merchant-specified identifier.

 @param cartID A merchant-specified identifier.
 @return A new cart instance.
 */
- (instancetype)initWithCartID:(NSString *)cartID;

/**
 Adds an item to the cart.

 @param cartItem The item to be added.
 */
- (void)addCartItem:(BLTCartItem *)cartItem;

/**
 Removes all current items from the cart.
 */
- (void)clearCartItems;

/**
 Adds a discount to the cart. The amount is substracted from the calculated total.

 @param description A human-readable description of the discount.
 @param amount The discount amount in cents.
 */
- (void)addDiscountItemWithDescription:(NSString *)description amount:(NSInteger)amount;

/**
 Removes all current discounts from the cart.
 */
- (void)clearDiscountItems;

/**
 Sets the tax amount added to the calculated total.

 @param amount The tax amount in cents.
 @param description A human-readable description of the tax.
 */
- (void)setTaxAmount:(NSInteger)amount withDescription:(NSString *)description;

/**
 Sets the shipping amount added to the cart's calculated total.

 @param amount The shipping amount in cents.
 @param description A human-readable description of the shipping.
 */
- (void)setShippingAmount:(NSInteger)amount withDescription:(NSString *)description;


/**
 Sets the currency used for the cart using an ISO4217 string. Currently only USD is supported. Will throw an exception if other currencies are specified.

 @param currencyString An ISO4217 string specifying the currency to use.
 */
- (void)setCurrencyWithISO4217String:(NSString *)currencyString;

/**
 Sets a custom total for the cart that supercedes the amount calculated based on items, discounts, tax, and shipping. This total will appear in the payment form instead of the calculated total.

 @param amount A custom total (in cents).
 */
- (void)overrideCalculatedCartTotalWithAmount:(NSInteger)amount;


/**
 Removes a previously specified cart total.
 */
- (void)clearOverridenCartTotal;

@end


/**
 Represents a completed transaction as returned by the Bolt API.
 */
@interface BLTTransactionResponse : NSObject

@property (strong, nonatomic, readonly) NSString *transactionID;
@property (strong, nonatomic, readonly) NSString *type;
@property (nonatomic) NSInteger epochDate;
@property (strong, nonatomic, readonly) NSString *transactionReference;
@property (strong, nonatomic, readonly) NSString *status;
@property (strong, nonatomic, readonly) BLTTransactionAmount *transactionAmount;

- (instancetype)initWithSerializedJSONBlob:(NSString *)jsonBlob;

@end

/**
 Represents a transaction amount from the Bolt API
 */
@interface BLTTransactionAmount : NSObject

@property (strong, nonatomic, readonly) NSString *currency;
@property (strong, nonatomic, readonly) NSString *currencySymbol;
@property (nonatomic) NSInteger amount;

- (instancetype)initWithCurrency:(NSString *)currency withSymbol:(NSString *)symbol withAmount:(NSInteger)amount;

@end



/**
 Represents an item the payer is purchasing.
 */
@interface BLTCartItem : NSObject

@property (nonatomic, readonly) NSString *referenceID;
@property (strong, nonatomic) NSString *imageURL;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *itemDescription;
@property (nonatomic) NSInteger price;
@property (nonatomic) NSInteger quantity;


/**
 Initializes an item using the merchant's specified identifier.

 @param referenceID A merchant-specific identifier for the item.
 @return A new item instance.
 */
- (instancetype)initWithReferenceID:(NSString *)referenceID;

@end


/**
 Represents a line item in the cart (discount, tax, shipping)
 */
@interface BLTLineItem : NSObject

@property (strong, nonatomic) NSString *itemDescription;
@property (nonatomic) NSInteger amount;


/**
 Creates a configuration instance using the values specified in the app's Info.plist.

 @param description A human-readable description of the line item.
 @param amount The amount of the line item in cents.
 @return A new line item instance.
 */
+ (BLTLineItem *)lineItemWithDescription:(NSString *)description amount:(NSInteger)amount;


@end

