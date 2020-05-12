//
//  ViewController.swift
//  scannerPractice
//
//  Created by Levi Davis on 5/12/20.
//  Copyright © 2020 Levi Davis. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
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
        return button
    }()
    
    lazy var takeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "menu-icon"), for: .normal)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setNavBar()
        addSubviews()
        constrainSubviews()
    }
    
    @objc private func navButtonPressed() {}

    private func setNavBar() {
        self.navigationController?.title = "Extractor"
        let rightButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(navButtonPressed))
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

