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
                        let frame = self.createScaledFrame(featureFrame: element.frame, imageSize: image.size, viewFrame: imageView.frame)
                        let shapeLayer = self.createShapeLayer(frame: frame)
                        let scaledElement = ScaledElement(frame: frame, shapeLayer: shapeLayer)
                        
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
    
    private func createScaledFrame(featureFrame: CGRect, imageSize: CGSize, viewFrame: CGRect) -> CGRect {
        let viewSize = viewFrame.size
        
        let resolutionView = viewSize.width / viewSize.height
        let resolutionImage = imageSize.width / imageSize.height
        var scale: CGFloat
        
        if resolutionView > resolutionImage {
            scale = viewSize.height / imageSize.height
        } else {
            scale = viewSize.width / imageSize.width
        }
        
        let featureWidthScaled = featureFrame.size.width * scale
        let featureHeightScaled = featureFrame.size.height * scale
        
        let imageWidthScaled = imageSize.width * scale
        let imageHeightScaled = imageSize.height * scale
        
        let imagePointXScaled = (viewSize.width - imageWidthScaled) / 2
        let imagePointYScaled = (viewSize.height - imageHeightScaled) / 2
        
        let featurePointXScaled = imagePointXScaled + featureFrame.origin.x * scale
        let featurePointYScaled = imagePointYScaled + featureFrame.origin.y * scale
        
        return CGRect(x: featurePointXScaled, y: featurePointYScaled, width: featureWidthScaled, height: featureHeightScaled)
    }
    
    private enum Constants {
        static let lineWidth: CGFloat = 3.0
        static let lineColor = UIColor.yellow.cgColor
        static let fillColor = UIColor.clear.cgColor
    }
    
}
