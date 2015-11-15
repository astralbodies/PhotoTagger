//
//  ViewController.swift
//  PhotoTagger
//
//  Created by Aaron Douglas on 11/11/15.
//  Copyright © 2015 Razeware LLC. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet var takePictureButton: UIButton!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var progressView: UIProgressView!

    override func viewDidLoad() {
        super.viewDidLoad()

        if UIImagePickerController.isSourceTypeAvailable(.Camera) == false {
            takePictureButton.setTitle("Select Photo", forState: .Normal)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func takePicture(sender: UIButton) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = false
        if UIImagePickerController.isSourceTypeAvailable(.Camera) {
            picker.sourceType = UIImagePickerControllerSourceType.Camera
        } else {
            picker.sourceType = .PhotoLibrary
            picker.modalPresentationStyle = .FullScreen
        }
        presentViewController(picker, animated: true, completion: nil)
    }
}

extension ViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let image = info[UIImagePickerControllerOriginalImage] {
            imageView.image = image as? UIImage
            takePictureButton.hidden = true
            
            
            
            dismissViewControllerAnimated(true, completion: nil)
        }
    }
}


