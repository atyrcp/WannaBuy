//
//  SellerSettingViewController.swift
//  WannaBuy
//
//  Created by alien on 2019/2/14.
//  Copyright © 2019 z. All rights reserved.
//

import UIKit

class SellerSettingViewController: UIViewController, UINavigationControllerDelegate {

    var user: User?
    var sellingList = [Item]()
    var imagePickerController = UIImagePickerController()
    
    @IBOutlet weak var streamingUrlTextField: UITextField!
    @IBOutlet weak var streamingDescriptionTextField: UITextField!
    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var itemNameTextField: UITextField!
    @IBOutlet weak var itemPriceTextField: UITextField!
    @IBOutlet weak var itemQuantityTextField: UITextField!
    @IBOutlet weak var itemDescriptionTextView: UITextView!
    @IBOutlet weak var itemCollectionCiew: UICollectionView!
    
    
    @IBAction func chooseItemImageFromAlbum(_ sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum)
        {
            imagePickerController.sourceType = .savedPhotosAlbum
//            imagePickerController.allowsEditing = false
            
            self.present(imagePickerController, animated: true, completion: nil)
        }
    }
    
    @IBAction func addItemToSellingList(_ sender: UIButton) {
        guard let imageData = itemImageView.image?.jpegData(compressionQuality: 0.7) else {return}
        if let token = user?.token, let name = itemNameTextField.text, let price = Int(itemPriceTextField.text!), let quantity = Int(itemQuantityTextField.text!), let description = itemDescriptionTextView.text {
            APIrequest.shared.postItem(withToken: token, withName: name, withDescription: description, withStock: quantity, withPrice: price, fromImage: imageData) { (APIresponse) in
                if APIresponse.result {
                    APIrequest.shared.getItems(withToken: token) { (responseItems) in
                        self.sellingList = responseItems.response
                        self.itemCollectionCiew.reloadData()
                    }
                }
            }
        }
    }
    
    @IBAction func startStreaming(_ sender: UIButton) {
        guard let streamingLink = streamingUrlTextField.text, let streamingDescription = streamingDescriptionTextField.text else {return}
        
        APIrequest.shared.postChannel(withToken: (user?.token)!, withLink: streamingLink, withDescription: streamingDescription) { (responseChannel) in
            if responseChannel.result {
                let id = responseChannel.response.channel_id
                let token = responseChannel.response.channel_token
                self.user?.channelInfo = ChannelInfo.init(channel_id: id, channel_token: token, channel_link: streamingLink, channel_description: streamingDescription)
                
                guard let destinationViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SellerStreamingViewController") as? SellerStreamingViewController else {return}
                
                destinationViewController.user = self.user
                destinationViewController.sellingList = self.sellingList
                self.present(destinationViewController, animated: true)
            } else {
                return
            }
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePickerController.delegate = self
    }

}

extension SellerSettingViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sellingList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "itemCell", for: indexPath) as? SellingCollectionViewCell {
            cell.figureImageOnCell(with: sellingList[indexPath.row])
            return cell
        } else {
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = sellingList[indexPath.row]
        
        itemImageView.image = UIImage(data: item.images)
        itemNameTextField.text = item.name
        itemPriceTextField.text = String(item.unit_price)
        itemQuantityTextField.text = String(item.stock)
        itemDescriptionTextView.text = item.description
    }
}

extension SellerSettingViewController: UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            itemImageView.image = image
            dismiss(animated: true, completion: nil)
        }
    }
}
