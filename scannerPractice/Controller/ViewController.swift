//
//  ViewController.swift
//  scannerPractice
//
//  Created by Levi Davis on 5/12/20.
//  Copyright © 2020 Levi Davis. All rights reserved.
//

import UIKit
import MobileCoreServices

class ViewController: UIViewController {
    
//    MARK: - Instance Variable
    
    private var frameSublayer = CALayer()
    var scannedText: String = "Detected text can be edited here." {
        didSet {
            DispatchQueue.main.async {[weak self] in
                self?.textView.text = self?.scannedText
            }
        }
    }
    private let processor = ScaledElementProcessor()
    
//    MARK: - UI Elements
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "scanned-text")
        return imageView
    }()
    
    lazy var textView: UITextView = {
        let textView = UITextView()
        textView.text = "Detected text can be edited here."
        textView.font = UIFont(name: "Futura-Medium", size: 17)
        textView.isEditable = true
        textView.isSelectable = true
        return textView
    }()
    
    lazy var cameraButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "camera-icon"), for: .normal)
        button.addTarget(self, action: #selector(cameraButtonPressed), for: .touchUpInside)
        return button
    }()
    
    lazy var takeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "menu-icon"), for: .normal)
        button.addTarget(self, action: #selector(libraryButtonPressed), for: .touchUpInside)
        return button
    }()

//    MARK: - Lifcycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavBar()
        addSubviews()
        constrainSubviews()
        addObservers()
        processText()
    }
    
//    MARK: - Touch handling to dismiss keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let evt = event, let tchs = evt.touches(for: view), tchs.count > 0 {
            textView.resignFirstResponder()
        }
    }
    
//    MARK: - Obj-C Methods
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        if let keyBoardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if view.frame.origin.y == 0 {
                view.frame.origin.y -= keyBoardSize.height
            }
        }
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        if let keyBoardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if view.frame.origin.y != 0 {
                view.frame.origin.y += keyBoardSize.height
            }
        }
    }
    
    @objc private func cameraButtonPressed() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            presentImagePickerController(withSourceType: .camera)
        } else {
            let alert = UIAlertController(title: "Camera Not Available", message: "A camera is not available. Please try picking an image from the image library instead.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
    
    @objc private func libraryButtonPressed() {
        presentImagePickerController(withSourceType: .photoLibrary)
    }
    
    @objc private func shareButtonPressed() {
        guard imageView.image != nil else {return}
        let vc = UIActivityViewController(activityItems: [scannedText, imageView.image!], applicationActivities: [])
        present(vc, animated: true, completion: nil)
    }
    
//    MARK: - Private Methods
    
    private func processText() {
        processor.process(in: imageView) {[weak self] text in
            self?.scannedText = text
        }
    }
    
    private func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    private func setNavBar() {
        self.navigationController?.title = "Extractor"
        let rightButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareButtonPressed))
        self.navigationItem.rightBarButtonItem = rightButton
        
    }
    
    private func addSubviews() {
        view.addSubview(imageView)
        view.addSubview(textView)
        view.addSubview(cameraButton)
        view.addSubview(takeButton)
    }
    
    private func constrainSubviews() {
        view.backgroundColor = .white
        constrainImageView()
        constrainTextView()
        constrainCameraButton()
        constrainTakeButton()
    }
    
    private func constrainImageView() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        [imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
         imageView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
         imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
         imageView.heightAnchor.constraint(equalToConstant: view.safeAreaLayoutGuide.layoutFrame.height * 0.6)].forEach{$0.isActive = true}
        imageView.layer.addSublayer(frameSublayer)
    }
    
    private func constrainTextView() {
        textView.translatesAutoresizingMaskIntoConstraints = false
        [textView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
        textView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
        textView.topAnchor.constraint(equalTo: imageView.bottomAnchor),
        textView.bottomAnchor.constraint(equalTo: cameraButton.topAnchor, constant: -5)].forEach{$0.isActive = true}
    }
    
    private func constrainCameraButton() {
        cameraButton.translatesAutoresizingMaskIntoConstraints = false
        [cameraButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor, constant: 100),
         cameraButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
         cameraButton.heightAnchor.constraint(equalToConstant: 50)].forEach{$0.isActive = true}
    }
    
    private func constrainTakeButton() {
        takeButton.translatesAutoresizingMaskIntoConstraints = false
        [takeButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor, constant: -100),
         takeButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
         takeButton.heightAnchor.constraint(equalToConstant: 50)].forEach{$0.isActive = true}
    }

}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPopoverPresentationControllerDelegate {
    
    private func presentImagePickerController(withSourceType sourceType: UIImagePickerController.SourceType) {
        let controller = UIImagePickerController()
        controller.delegate = self
        controller.sourceType = sourceType
        controller.mediaTypes = [String(kUTTypeImage), String(kUTTypeMovie)]
        present(controller, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageView.contentMode = .scaleAspectFit
            imageView.image = pickedImage
        }
        dismiss(animated: true, completion: nil)
    }
}
