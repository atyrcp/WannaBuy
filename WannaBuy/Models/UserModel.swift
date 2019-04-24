//
//  UserModel.swift
//  WannaBuy
//
//  Created by alien on 2019/2/14.
//  Copyright © 2019 z. All rights reserved.
//

import Foundation
import UIKit

class User: NSObject, Codable {
    @objc dynamic var name: String
    @objc dynamic var image: Data
    var isStreaming = false
    var isLogin = false
//    var identity: UserIdentity?
    var token: String
    var channelInfo: ChannelInfo?
    var recipientInfo: RecipientInfo?
    
    func setInitialState() {
        self.name = "please login"
        self.image = #imageLiteral(resourceName: "defaultUserImage").jpegData(compressionQuality: 1)!
        self.token = ""
        self.isLogin = false
        self.recipientInfo = nil
        self.channelInfo = nil
    }
    
    func save() {
        let encodeUser = try? JSONEncoder().encode(self)
        UserDefaults.standard.set(encodeUser, forKey: "user")
    }
    
    init(name: String, image: Data, token: String) {
        self.name = name
        self.image = image
        self.token = token
    }
}

struct ChannelInfo: Codable {
    var channel_id: String
    var channel_token: String
    var channel_link: String
    var channel_description: String
}

enum UserIdentity {
    case buyer
    case seller
}
