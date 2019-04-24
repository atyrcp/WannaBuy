//
//  ViewController.swift
//  WannaBuy
//
//  Created by alien on 2019/1/28.
//  Copyright © 2019 z. All rights reserved.
//

import UIKit
//import FacebookCore
import FacebookLogin
import FacebookShare

class ViewController: UIViewController, LoginButtonDelegate {
    
    var user: User! {
        didSet {
            observationUserName = user.observe(\User.name, options: .new, changeHandler: { (_ , change) in
                if let newName = change.newValue {
                    DispatchQueue.main.async {
                        self.userNameLabel.text = newName
                    }
                }
            })
            
            observationUserImage = user.observe(\User.image, options: .new, changeHandler: { (_ , change) in
                if let newImage = change.newValue {
                    DispatchQueue.main.async {
                        self.userImageView.image = UIImage(data: newImage)
                    }
                }
            })
        }
    }
    var postCodeInfos = [PostCodeInfo]()
    var observationUserName: NSKeyValueObservation?
    var observationUserImage: NSKeyValueObservation?
    
    @IBOutlet weak var userImageView: UIImageView!{
        didSet {
            userImageView.image = #imageLiteral(resourceName: "defaultUserImage")
        }
    }
    @IBOutlet weak var userNameLabel: UILabel!{
        didSet {
            userNameLabel.text = "please login"
        }
    }
    @IBOutlet weak var userInfoStackView: UIStackView!
    
    @IBAction func unwindSegue(segue: UIStoryboardSegue){}
    
    @IBAction func editUserInfo(_ sender: UIButton) {
        if user.isLogin {
            APIrequest.shared.getTaiwanPostCode(withToken: user.token) { (responseTaiwanPostCode) in
                if responseTaiwanPostCode.result {
                    self.postCodeInfos = responseTaiwanPostCode.response
                    self.performSegue(withIdentifier: "editUser", sender: sender)
                }
            }
        }
    }
    
    @IBAction func userIsSeller(_ sender: UIButton) {
        if user.isLogin {
//            user.identity = .seller
            performSegue(withIdentifier: "userIsSeller", sender: sender)
        }
    }
    
    @IBAction func userIsBuyer(_ sender: UIButton) {
        if user.isLogin {
//            user.identity = .buyer
            performSegue(withIdentifier: "userIsBuyer", sender: sender)
        }
    }
    
    func loginButtonDidCompleteLogin(_ loginButton: LoginButton, result: LoginResult) {
        switch result {
        case .success(grantedPermissions: _, declinedPermissions: _, token: let accessToken):
            
            let token = accessToken.authenticationToken
            
            APIrequest.shared.postToken(withToken: token) { (APIresponse) in
                if APIresponse.result {
                    
                    let backEndToken = APIresponse.response.access_token
                    
                    APIrequest.shared.getUsers(withToken: backEndToken, result: { (responseUser) in
                        if APIresponse.result {
                            
                            print("reponseUser========= \(responseUser)")
                            guard let image = FunctionHelper().generateImageFromString(using: (responseUser.response?.avatar)!)?.jpegData(compressionQuality: 1), let name = responseUser.response?.name else {return}
                            self.user.name = name
                            self.user.image = image
                            self.user.token = backEndToken
                            self.user.isLogin = true
                            self.user.save()
                        }
                    })
                }
            }
            
        case .failed(let error):
            print(error)
        default:
            break
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: LoginButton) {
        user.setInitialState()
        user.save()
    }
    
    func layoutFacebookButton() {
        let facebookLoginButton = LoginButton(readPermissions: [.publicProfile])
        facebookLoginButton.delegate = self
        
        let centerView = UIStackView(arrangedSubviews: [userInfoStackView, facebookLoginButton])
        centerView.axis = .vertical
        centerView.alignment = .center
        centerView.distribution = .fill
        centerView.spacing = 10.0
        centerView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(centerView)
        centerView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        centerView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "userIsSeller":
            if let destinationViewController = segue.destination as? SellerSettingViewController {
                destinationViewController.user = self.user
            }
        case "userIsBuyer":
            if let destinationViewController = segue.destination as? BuyerEnteringViewController {
                destinationViewController.user = self.user
            }
        case "editUser":
            if let destinationViewController = segue.destination as? UserEditInfoViewController {
                destinationViewController.user = self.user
                destinationViewController.postCodeInfos = self.postCodeInfos
            }
        default:
            return
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        layoutFacebookButton()
        
        if let data = UserDefaults.standard.value(forKey: "user") as? Data , let decodeUser = try? JSONDecoder().decode(User.self, from: data) {
            
            
            DispatchQueue.main.async {
                self.user = decodeUser
                self.userNameLabel.text = self.user.name
                self.userImageView.image = UIImage(data: self.user.image)
            }
        } else {
            self.user = User(name: "please login", image: #imageLiteral(resourceName: "defaultUserImage").jpegData(compressionQuality: 1)!, token: "")
        }
        
//        print("token now in the view didload----------------- \(AccessToken.current?.authenticationToken)")
    }

}
