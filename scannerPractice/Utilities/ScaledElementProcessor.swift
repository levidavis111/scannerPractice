//
//  ScaledElementProcessor.swift
//  scannerPractice
//
//  Created by Levi Davis on 5/12/20.
//  Copyright © 2020 Levi Davis. All rights reserved.
//

import Foundation
import Firebase

class ScaledElementProcessor {
    let vision = Vision.vision()
    var textRecognizer: VisionTextRecognizer
    
    init() {
        textRecognizer = vision.onDeviceTextRecognizer()
    }
    
    func process(in imgageView: UIImageView, callback: @escaping (_ text: String) -> ()) {
        guard let image = imgageView.image else {return}
        
        let visionImage = VisionImage(image: image)
        
        textRecognizer.process(visionImage) { (result, error) in
            guard error == nil,
            let result = result,
                !result.text.isEmpty else {
                    callback("")
                    return
            }
            callback(result.text)
        }
    }
}
