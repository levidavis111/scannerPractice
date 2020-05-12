//
//  ScaledElementProcessor.swift
//  scannerPractice
//
//  Created by Levi Davis on 5/12/20.
//  Copyright © 2020 Levi Davis. All rights reserved.
//

import Foundation
import Firebase

struct ScaledElement {
    let frame: CGRect
    let shapeLayer: CALayer
}

class ScaledElementProcessor {
    let vision = Vision.vision()
    var textRecognizer: VisionTextRecognizer
    
    init() {
        textRecognizer = vision.onDeviceTextRecognizer()
    }
    
    func process(in imageView: UIImageView, callback: @escaping (_ text: String, _ scaledElements: [ScaledElement]) -> ()) {
        guard let image = imageView.image else {return}
        let visionImage = VisionImage(image: image)
        
        textRecognizer.process(visionImage) { (result, error) in
            guard error == nil,
            let result = result,
                !result.text.isEmpty else {
                    callback("", [])
                    return
            }
            var scaledElements: [ScaledElement] = []
            
            for block in result.blocks {
                for line in block.lines {
                    for element in line.elements {
                        let shapeLayer = self.createShapeLayer(frame: element.frame)
                        let scaledElement = ScaledElement(frame: element.frame, shapeLayer: shapeLayer)
                        scaledElements.append(scaledElement)
                    }
                }
            }
            callback(result.text, scaledElements)
        }
    }
    
    func createShapeLayer(frame: CGRect) -> CAShapeLayer {
        let bPath = UIBezierPath(rect: frame)
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = bPath.cgPath
        
        shapeLayer.strokeColor = Constants.lineColor
        shapeLayer.fillColor = Constants.fillColor
        shapeLayer.lineWidth = Constants.lineWidth
        
        return shapeLayer
    }
    
    private enum Constants {
        static let lineWidth: CGFloat = 3.0
        static let lineColor = UIColor.yellow.cgColor
        static let fillColor = UIColor.clear.cgColor
    }
    
}
