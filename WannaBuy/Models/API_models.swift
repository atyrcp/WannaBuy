//
//  API_models.swift
//  WannaBuy
//
//  Created by alien on 2019/1/28.
//  Copyright © 2019 z. All rights reserved.
//

import Foundation


//Global struct

struct PhoneInfo: Codable {
    var phone_code = "886"
    var phone_number: String
    
    init(phoneNumber: String) {
        self.phone_number = phoneNumber
    }
}

//is post_code an Int or String?
struct AddressInfo: Codable {
    var country_code = "TW"
    var post_code: String
    var city: String
    var district: String
    var others: String
    
    init(postCode: String, city: String, district: String, others: String) {
        self.post_code = postCode
        self.city = city
        self.district = district
        self.others = others
    }
}

struct PostCodeInfo: Decodable {
    var City: String
    var Area: String
    var ZipCode: String
}

struct RecipientInfo: Codable {
    var recipient_id: Int
    var name: String
    var phone: PhoneInfo
    var address: AddressInfo
}

struct ItemInfo: Decodable {
    var item_id: Int
    var name: String
    var description: String
    var unit_price: Int
    var image: Data?
    var remaining_quantity: Int
    var sold_quantity: Int
}

struct Order: Decodable {
    var id: Int
    var order: String
    var user_id: Int
    var seller_name: String
    var name: String
    var channel_description: String
    var description: String
    var unit_price: Int
    var quantity: Int
    var total_amount: Int
    var channel_id: Int
    var status: Int
    var expiry_time: String?
    var created_time: String?
    var images: Data?
    var recipient: String
    var phone_code: String
    var phone_number: String
    var post_code: String
    var country: String
    var city: String
    var district: String
    var others: String
    var to_be_deleted_time: String?
    var to_be_completed_time: String?
}

struct ResponseWithString: Decodable {
    var result: Bool
    var response: String
}


//Common API struct

struct POSTtoken: Decodable {
    var result: Bool
    var response: TokenState
    
    struct TokenState: Decodable {
        var access_token: String
        var expires_in: Int
    }
}

struct GETusers: Decodable {
    var result: Bool
    var response: UserInfo?
    
    struct UserInfo: Decodable {
        var name: String
        var email: String
        var avatar: String
        var user_id: Int
        var phone: String?
    }
}

struct GETstreamingitems: Decodable {
    var result: Bool
    var response: ItemInfo?
}


//Buyer struct

struct PUTusers: Codable {
    var phone: PhoneInfo
}

struct POSTrecipients: Codable {
    var name: String
    var phone: PhoneInfo
    var address: AddressInfo
}

struct GETrecipients: Codable {
    var result: Bool
    var response: [RecipientInfo]
}

struct PATCHrecipients: Codable {
    var name: String
    var phone: PhoneInfo
    var address: AddressInfo
}

struct GETtaiwanpostcode: Decodable {
    var result: Bool
    var response: [PostCodeInfo]
}



struct PATCHuserchannelid: Codable {
    var channel_token: String
}

struct POSTorders: Codable {
    var number: Int
}

struct GETorders: Decodable {
    var result: Bool
    var response: [Order]
//
//    struct OrderInfo: Decodable {
//        var order: String
//        var user_id: Int
//        var name: String
//        var description: String
//        var unit_price: Int
//        var quantity: Int
//        var total_amount: Int
//        var channel_id: Int
//        var status: Int
//        var time: String
//        var images: Data?
//        var recipient: String
//        var phone_code: String
//        var phone_number: String
//        var post_code: String
//        var country: String
//        var city: String
//        var district: String
//        var others: String
//    }
}

struct GETlatestchannelorders: Decodable {
    var result: Bool
    var response: [Order]
}


//Seller struct

struct POSTitems: Codable {
    var name: String
    var description: String
    var stock: Int
    var cost = 0
    var unit_price: Int
    var images: Data
}

struct GETitems: Decodable {
    var result: Bool
    var response: [Item]
}
// it just belongs to GETitems model
struct Item: Decodable {
    var id: Int
    var name: String
    var description: String
    var stock: Int
    var cost: Int
    var unit_price: Int
    var images: Data
}

struct POSTchannel: Codable {
    var iFrame: String
    var channel_description: String
}

//not sure if channel_id is a string or an int, ask Ray someday
struct POSTchannelresponse: Decodable {
    var result: Bool
    var response: ChannelInfo
    
    struct ChannelInfo: Decodable {
        var channel_id: String
        var channel_token: String
    }
}

struct GETsellerorders: Decodable {
    var result: Bool
    var response: [Order]
}

// i dont think i need this, cause it's for managing stocks, but im not gonna do that part in this app
struct GETsolditems: Decodable {
    var result: Bool
    var response: [SoldInfo]
    
    struct SoldInfo: Decodable {
        var item_name: String
        var item_description: String
        var cost: Int
        var unit_price: Int
        var profit: Int
        var quantity: Int
        var turnover: Int
    }
}

