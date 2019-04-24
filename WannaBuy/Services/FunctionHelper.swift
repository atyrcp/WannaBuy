//
//  FunctionHelper.swift
//  WannaBuy
//
//  Created by alien on 2019/2/16.
//  Copyright © 2019 z. All rights reserved.
//

import Foundation
import AVKit

class FunctionHelper {
    func generateImageFromString(using string: String) -> UIImage? {
        guard let url = URL(string: string), let data = try? Data(contentsOf: url) else {return UIImage(named: "defaultUserImage")}
        let image = UIImage(data: data)
        return image
    }
}
