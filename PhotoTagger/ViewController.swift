//
//  ViewController.swift
//  PhotoTagger
//
//  Created by Aaron Douglas on 11/11/15.
//  Copyright © 2015 Razeware LLC. All rights reserved.
//

import UIKit
import Alamofire

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
            self.progressView.progress = 0.0
            self.progressView.hidden = false
            
            let imageData = UIImageJPEGRepresentation(image as! UIImage, 0.5)!
            
            Alamofire.upload(
                .POST,
                "http://api.imagga.com/v1/content",
                headers: [
                    "Authorization" : "Basic YWNjXzc3MmY3ZjhjNzc0MzcxZjphNGMxYWMyMDQwNWE5MDZjZmEwMWRjMmYzMDhjOWNlYw==",
                ],
                multipartFormData: { multipartFormData in
                    multipartFormData.appendBodyPart(data: imageData, name: "imagefile", fileName: "image.jpg", mimeType: "image/jpeg")
                },
                encodingCompletion: { encodingResult in
                    switch encodingResult {
                    case .Success(let upload, _, _):
                        upload.progress { bytesWritten, totalBytesWritten, totalBytesExpectedToWrite in
                            print(totalBytesWritten)
                            
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                let percent = (Float(totalBytesWritten) / Float(totalBytesExpectedToWrite))
                                self.progressView.setProgress(percent, animated: true)
                            })
                        }
                        upload.responseJSON { response in
                            print(response)
                        }
                    case .Failure(let encodingError):
                        print(encodingError)
                    }
                }
            )
            
            
            dismissViewControllerAnimated(true, completion: nil)
        }
    }
}


