//
//  ScaledElementProcessor.swift
//  scannerPractice
//
//  Created by Levi Davis on 5/12/20.
//  Copyright © 2020 Levi Davis. All rights reserved.
//

import Foundation
import Firebase

//A convenience to bundle the text objects frame and layer together.
struct ScaledElement {
    let frame: CGRect
    let shapeLayer: CALayer
}
//This is the text detector
class ScaledElementProcessor {
//    The textRecognizer is the main object that will detect text in images
    let vision = Vision.vision()
    var textRecognizer: VisionTextRecognizer
    
    init() {
        textRecognizer = vision.onDeviceTextRecognizer()
    }
//    Takes an array of ScaledElements in addition to recognized text
    func process(in imageView: UIImageView, callback: @escaping (_ text: String, _ scaledElements: [ScaledElement]) -> ()) {
        guard let image = imageView.image else {return}
//        MLKit uses a special image type.
        let visionImage = VisionImage(image: image)
//        Process takes in the VisionImage, and it returns an array of text results in the form of a parameter passed to a closure
        textRecognizer.process(visionImage) { (result, error) in
            guard error == nil,
            let result = result,
                !result.text.isEmpty else {
                    callback("", [])
                    return
            }
//            A collection for frames and shapeLayers
            var scaledElements: [ScaledElement] = []
//            A loop to get to the frame of each object
            for block in result.blocks {
                print(block.text)
                for line in block.lines {
                    for element in line.elements {
                        let frame = self.createScaledFrame(featureFrame: element.frame, imageSize: image.size, viewFrame: imageView.frame)
                        let shapeLayer = self.createShapeLayer(frame: frame)
                        let scaledElement = ScaledElement(frame: frame, shapeLayer: shapeLayer)
//                        Add to array
                        scaledElements.append(scaledElement)
                    }
                }
            }
//        The callback escaping closure is triggered to relay the recognized text.
            callback(result.text, scaledElements)
        }
    }
//    Create shape layer from the text object's frame
    func createShapeLayer(frame: CGRect) -> CAShapeLayer {
//CAShapeLayer does not have an initializer that takes in a CGRect. So, you construct a UIBezierPath with the CGRect and set the shape layer’s path to the UIBezierPath.
        let bPath = UIBezierPath(rect: frame)
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = bPath.cgPath
        
        shapeLayer.strokeColor = Constants.lineColor
        shapeLayer.fillColor = Constants.fillColor
        shapeLayer.lineWidth = Constants.lineWidth
        
        return shapeLayer
    }
//    Adjusts frame to account for content mode
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
