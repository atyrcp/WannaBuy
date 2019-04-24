//
//  APIrequest.swift
//  WannaBuy
//
//  Created by alien on 2019/1/28.
//  Copyright © 2019 z. All rights reserved.
//

import Foundation

class APIrequest {
    
    private init() {}
    static let shared = APIrequest()
    private let baseUrl = "https://facebookoptimizedlivestreamsellingsystem.rayawesomespace.space/api/"
    typealias completionWithString = (_ responseString: ResponseWithString) -> Void
    typealias completionWithDecodableModel = (Decodable) -> Void
    
    
    func postToken(withToken token: String, result: @escaping (POSTtoken) -> Void) {
        guard let url = URL(string: baseUrl + "token") else {return}
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.customHttpHeader(withBearer: token)
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (rData, rResponse, rError) in
            guard let encodeData = rData else {return}
            do {
                let decodeData = try JSONDecoder().decode(POSTtoken.self, from: encodeData)
                result(decodeData)
            } catch let error {
                print("decode postToken error with \(error)")
            }
        }
        task.resume()
    }
    
    
    func getUsers(withToken token: String, result: @escaping (GETusers) -> Void) {
        guard let url = URL(string: baseUrl + "users") else {return}
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.customHttpHeader(withBearer: token)
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (rData, rResponse, rError) in
            guard let encodeData = rData else {return}
            do {
                let decodeData = try JSONDecoder().decode(GETusers.self, from: encodeData)
                result(decodeData)
            } catch let error {
                print("decode postToken error with \(error)")
            }
        }
        task.resume()
    }
    
    
    func getStreamingItems(withToken token: String, result: @escaping (GETstreamingitems) -> Void) {
        guard let url = URL(string: baseUrl + "streaming-items") else {return}
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.customHttpHeader(withBearer: token)
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (rData, rResponse, rError) in
            guard let encodeData = rData else {return}
            do {
                let decodeData = try JSONDecoder().decode(GETstreamingitems.self, from: encodeData)
                result(decodeData)
            } catch let error {
                print("decode postToken error with \(error)")
            }
        }
        task.resume()
    }
    
    
    func putUsers(withToken token: String, withPhonenumber phoneNumber: String, result: @escaping completionWithString) {
        guard let url = URL(string: baseUrl + "users") else {return}
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.customHttpHeader(withBearer: token)
        
        let phoneInfo = PhoneInfo(phoneNumber: phoneNumber)
        let putUsers = PUTusers.init(phone: phoneInfo)
        
        do {
            let encodeData = try JSONEncoder().encode(putUsers)
            request.httpBody = encodeData
        } catch let error {
            print("encode postToken error with \(error)")
        }
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (rData, rResponse, rError) in
            guard let encodeData = rData else {return}
            do {
                let decodeData = try JSONDecoder().decode(ResponseWithString.self, from: encodeData)
                result(decodeData)
            } catch let error {
                print("decode postToken error with \(error)")
            }
        }
        task.resume()
    }
    
    //TODO: decode may be incompleted, but i dont need the result of the decode data
    func postRecipients(withToken token: String, byName name: String, withPhoneInfo phoneInfo: PhoneInfo, withAddressInfo addressInfo: AddressInfo, result: @escaping completionWithString) {
        guard let url = URL(string: baseUrl + "recipients") else {return}
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.customHttpHeader(withBearer: token)
        
        let postRecipients = POSTrecipients.init(name: name, phone: phoneInfo, address: addressInfo)
        
        do {
            let encodeData = try JSONEncoder().encode(postRecipients)
            request.httpBody = encodeData
        } catch let error {
            print("encode postToken error with \(error)")
        }
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (rData, rResponse, rError) in
            guard let encodeData = rData else {return}
            do {
                let decodeData = try JSONDecoder().decode(ResponseWithString.self, from: encodeData)
                result(decodeData)
            } catch let error {
                print("decode postToken error with \(error)")
            }
        }
        task.resume()
    }
    
    func getRecipient(withToken token: String, result: @escaping (GETrecipients) -> Void) {
        guard let url = URL(string: baseUrl + "recipients") else {return}
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.customHttpHeader(withBearer: token)
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (rData, rResponse, rError) in
            guard let encodeData = rData else {return}
            do {
                let decodeData = try JSONDecoder().decode(GETrecipients.self, from: encodeData)
                result(decodeData)
            } catch let error {
                print("decode postToken error with \(error)")
            }
        }
        task.resume()
    }
    
    func patchRecipients(withToken token: String, byName name: String, withPhoneInfo phoneInfo: PhoneInfo,withAddressInfo addressInfo: AddressInfo,withRecipientID id: Int, result: @escaping completionWithString) {
        guard let url = URL(string: baseUrl + "recipients/" + "\(id)") else {return}
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.customHttpHeader(withBearer: token)
        
        let patchRecipients = PATCHrecipients.init(name: name, phone: phoneInfo, address: addressInfo)
        
        do {
            let encodeData = try JSONEncoder().encode(patchRecipients)
            request.httpBody = encodeData
        } catch let error {
            print("encode postToken error with \(error)")
        }
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (rData, rResponse, rError) in
            guard let encodeData = rData else {return}
            do {
                let decodeData = try JSONDecoder().decode(ResponseWithString.self, from: encodeData)
                result(decodeData)
            } catch let error {
                print("decode postToken error with \(error)")
            }
        }
        task.resume()
    }
    
    func getTaiwanPostCode(withToken token: String, result: @escaping (GETtaiwanpostcode) -> Void) {
        guard let url = URL(string: baseUrl + "taiwan-post-code") else {return}
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.customHttpHeader(withBearer: token)
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (rData, rResponse, rError) in
            guard let encodeData = rData else {return}
            do {
                let decodeData = try JSONDecoder().decode(GETtaiwanpostcode.self, from: encodeData)
                result(decodeData)
            } catch let error {
                print("decode postToken error with \(error)")
            }
        }
        task.resume()
    }
    
    func patchUserChannelId(withToken token: String, withChannelToken channelToken: String, result: @escaping completionWithString) {
        guard let url = URL(string: baseUrl + "user-channel-id") else {return}
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.customHttpHeader(withBearer: token)
        
        let patchUserChannelId = PATCHuserchannelid.init(channel_token: channelToken)
        
        do {
            let encodeData = try JSONEncoder().encode(patchUserChannelId)
            request.httpBody = encodeData
        } catch let error {
            print("encode postToken error with \(error)")
        }
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (rData, rResponse, rError) in
            guard let encodeData = rData else {return}
            do {
                let decodeData = try JSONDecoder().decode(ResponseWithString.self, from: encodeData)
                result(decodeData)
            } catch let error {
                print("decode postToken error with \(error)")
            }
        }
        task.resume()
    }
    
    func putUserChannelId(withToken token: String, result: @escaping completionWithDecodableModel) {
        guard let url = URL(string: baseUrl + "user-channel-id") else {return}
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.customHttpHeader(withBearer: token)
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (rData, rResponse, rError) in
            guard let encodeData = rData else {return}
            do {
                let decodeData = try JSONDecoder().decode(ResponseWithString.self, from: encodeData)
                result(decodeData)
            } catch let error {
                print("decode postToken error with \(error)")
            }
        }
        task.resume()
    }
    
    func postOrders(withToken token: String, withItemId ItemId: Int, withRecipientId recipientId: Int, withNumbers numbers: Int, result: @escaping completionWithString) {
        guard let url = URL(string: baseUrl + "recipients/" + "\(ItemId)/" + "\(recipientId)") else {return}
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.customHttpHeader(withBearer: token)
        
        let postOrders = POSTorders.init(number: numbers)
        
        do {
            let encodeData = try JSONEncoder().encode(postOrders)
            request.httpBody = encodeData
        } catch let error {
            print("encode postToken error with \(error)")
        }
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (rData, rResponse, rError) in
            guard let encodeData = rData else {return}
            do {
                let decodeData = try JSONDecoder().decode(ResponseWithString.self, from: encodeData)
                result(decodeData)
            } catch let error {
                print("decode postToken error with \(error)")
            }
        }
        task.resume()
    }
    
    func getOrders(withToken token: String, result: @escaping (GETorders) -> Void) {
        guard let url = URL(string: baseUrl + "orders") else {return}
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.customHttpHeader(withBearer: token)
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (rData, rResponse, rError) in
            guard let encodeData = rData else {return}
            do {
                let decodeData = try JSONDecoder().decode(GETorders.self, from: encodeData)
                result(decodeData)
            } catch let error {
                print("decode postToken error with \(error)")
            }
        }
        task.resume()
    }

    func getLatestChannelOrders(withToken token: String, result: @escaping (GETlatestchannelorders) -> Void) {
        guard let url = URL(string: baseUrl + "latest-channel-orders") else {return}
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.customHttpHeader(withBearer: token)
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (rData, rResponse, rError) in
            guard let encodeData = rData else {return}
            do {
                let decodeData = try JSONDecoder().decode(GETlatestchannelorders.self, from: encodeData)
                result(decodeData)
            } catch let error {
                print("decode postToken error with \(error)")
            }
        }
        task.resume()
    }

    //Now the Seller comes in
    
    //TODO: postItem and updateItem involves form data, need to custom a function here
    func postItem(withToken token: String, withName name: String, withDescription description: String, withStock stock: Int, withPrice price: Int, fromImage imageData: Data, result: @escaping completionWithString){
        
        let item = POSTitems.init(name: name, description: description, stock: stock, cost: 0, unit_price: price, images: imageData)
        let boundary = "Boundry-\(UUID().uuidString)"
        let lineBreak = "\r\n"
        
        guard let url = URL(string: baseUrl + "items") else {return}
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.addValue("XMLHttpRequest", forHTTPHeaderField: "X-Requested-With")
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        
        func createDataBody(fromItem item: POSTitems) -> Data {
            var body = Data()
            let parameter: [String: Any] = ["name": item.name, "description": item.description, "stock": item.stock, "cost": item.cost, "unit_price": item.unit_price]
            
            for (key, value) in parameter {
                body.appendFromString("--\(boundary + lineBreak)")
                body.appendFromString("Content-Disposition: form-dara; name=\"\(key)\"\(lineBreak + lineBreak)")
                body.appendFromString("\(value)" + "\(lineBreak)")
            }
            
            body.appendFromString("--\(boundary + lineBreak)")
            body.appendFromString("Content-Disposition: form-dara; name=\"image\"; filename=\"\(item.name)\"\(lineBreak)")
            body.appendFromString("Content-Type: image/jpeg\(lineBreak + lineBreak)")
            body.append(item.images)
            body.appendFromString(lineBreak)
            
            body.appendFromString("--\(boundary)--\(lineBreak)")
            
            return body
        }
        
        request.httpBody = createDataBody(fromItem: item)
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (rData, rResponse, rError) in
            guard let encodeData = rData else {return}
            do {
                let decodeData = try JSONDecoder().decode(ResponseWithString.self, from: encodeData)
                result(decodeData)
            } catch let error {
                print("decode postToken error with \(error)")
            }
        }
        task.resume()
    }
    
    
    
    func getItems(withToken token: String, result: @escaping (GETitems) -> Void) {
        guard let url = URL(string: baseUrl + "items") else {return}
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.customHttpHeader(withBearer: token)
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (rData, rResponse, rError) in
            guard let encodeData = rData else {return}
            do {
                let decodeData = try JSONDecoder().decode(GETitems.self, from: encodeData)
                result(decodeData)
            } catch let error {
                print("decode postToken error with \(error)")
            }
        }
        task.resume()
    }

    func postChannel(withToken token: String, withLink link: String, withDescription description: String,  result: @escaping (POSTchannelresponse) -> Void) {
        guard let url = URL(string: baseUrl + "channel") else {return}
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.customHttpHeader(withBearer: token)
        
        let postChannel = POSTchannel.init(iFrame: link, channel_description: description)
        
        do {
            let encodeData = try JSONEncoder().encode(postChannel)
            request.httpBody = encodeData
        } catch let error {
            print("encode postToken error with \(error)")
        }
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (rData, rResponse, rError) in
            guard let encodeData = rData else {return}
            do {
                let decodeData = try JSONDecoder().decode(POSTchannelresponse.self, from: encodeData)
                result(decodeData)
            } catch let error {
                print("decode postToken error with \(error)")
            }
        }
        task.resume()
    }
    
    func postStreamingItems(withToken token: String, withItemId id: Int, result: @escaping completionWithString) {
        guard let url = URL(string: baseUrl + "streaming-items/" + "\(id)") else {return}
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.customHttpHeader(withBearer: token)
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (rData, rResponse, rError) in
            guard let encodeData = rData else {return}
            do {
                let decodeData = try JSONDecoder().decode(ResponseWithString.self, from: encodeData)
                result(decodeData)
            } catch let error {
                print("decode postToken error with \(error)")
            }
        }
        task.resume()
    }

    func putChannel(withToken token: String, result: @escaping completionWithString) {
        guard let url = URL(string: baseUrl + "users-channel-id") else {return}
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.customHttpHeader(withBearer: token)
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (rData, rResponse, rError) in
            guard let encodeData = rData else {return}
            do {
                let decodeData = try JSONDecoder().decode(ResponseWithString.self, from: encodeData)
                result(decodeData)
            } catch let error {
                print("decode postToken error with \(error)")
            }
        }
        task.resume()
    }

    func getSellerOrders(withToken token: String, result: @escaping (GETsellerorders) -> Void) {
        guard let url = URL(string: baseUrl + "seller-orders") else {return}
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.customHttpHeader(withBearer: token)
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (rData, rResponse, rError) in
            guard let encodeData = rData else {return}
            do {
                let decodeData = try JSONDecoder().decode(GETsellerorders.self, from: encodeData)
                result(decodeData)
            } catch let error {
                print("decode postToken error with \(error)")
            }
        }
        task.resume()
    }

    func getSellerOrdersWithChannel(withToken token: String,withChannelID channelID: String, result: @escaping (GETsellerorders) -> Void) {
        guard let url = URL(string: baseUrl + "seller-orders/" + "\(channelID)") else {return}
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.customHttpHeader(withBearer: token)
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (rData, rResponse, rError) in
            guard let encodeData = rData else {return}
            do {
                let decodeData = try JSONDecoder().decode(GETsellerorders.self, from: encodeData)
                result(decodeData)
            } catch let error {
                print("decode postToken error with \(error)")
            }
        }
        task.resume()
    }
    
    func getSoldItems(withToken token: String, result: @escaping completionWithDecodableModel) {
        guard let url = URL(string: baseUrl + "sold-items") else {return}
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.customHttpHeader(withBearer: token)
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (rData, rResponse, rError) in
            guard let encodeData = rData else {return}
            do {
                let decodeData = try JSONDecoder().decode(GETsolditems.self, from: encodeData)
                result(decodeData)
            } catch let error {
                print("decode postToken error with \(error)")
            }
        }
        task.resume()
    }
    
    
    
    
    
}

extension URLRequest {
    mutating func customHttpHeader(withBearer token: String) {
        setValue("application/json", forHTTPHeaderField: "Content-Type")
        addValue("XMLHttpRequest", forHTTPHeaderField: "X-Requested-With")
        addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    }
}

extension Data {
    mutating func appendFromString(_ string: String) {
        if let data = string.data(using: .utf8) {
            self.append(data)
        }
    }
}
