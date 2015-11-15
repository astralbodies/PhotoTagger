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
    @IBOutlet var activityIndicatorView: UIActivityIndicatorView!
    
    private var tags: [String]?
    private var colors: [PhotoColor]?

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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender);
        
        if segue.identifier == "ShowResults" {
            if let viewController = segue.destinationViewController as? TagsColorsViewController {
                viewController.tags = tags
                viewController.colors = colors
            }
        }
    }
}

extension ViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let image = info[UIImagePickerControllerOriginalImage] {
            imageView.image = image as? UIImage
            takePictureButton.hidden = true
            self.progressView.progress = 0.0
            self.progressView.hidden = false
            self.activityIndicatorView.startAnimating()
            
            uploadImage(
                image as! UIImage,
                progress: { percent in
                    self.progressView.setProgress(percent, animated: true)
                },
                completion: { tags, colors in
                    self.takePictureButton.hidden = false
                    self.progressView.hidden = true
                    self.activityIndicatorView.stopAnimating()
                    
                    self.tags = tags
                    self.colors = colors
                    
                    self.performSegueWithIdentifier("ShowResults", sender: self)
                })
            
            dismissViewControllerAnimated(true, completion: nil)
        }
    }
}

// MARK: Networking Functions
extension ViewController {
    func uploadImage(image: UIImage, progress: (percent: Float) -> Void, completion: (tags: [String], colors: [PhotoColor]) -> Void) {
        let imageData = UIImageJPEGRepresentation(image, 0.5)!
        
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
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            let percent = (Float(totalBytesWritten) / Float(totalBytesExpectedToWrite))
                            progress(percent: percent)
                        })
                    }
                    upload.responseJSON { response in
                        if response.result.isSuccess {
                            let responseJSON = response.result.value
                            let uploadedFiles = responseJSON?.valueForKey("uploaded") as! NSArray
                            let firstFile = uploadedFiles.firstObject!
                            let firstFileID = firstFile.valueForKey("id")! as! String
                            
                            print(firstFileID)
                            
                            self.downloadTags(firstFileID) { tags in
                                
                                self.downloadColors(firstFileID) { colors in
                                    completion(tags: tags, colors: colors)
                                }
                            }
                        }
                    }
                case .Failure(let encodingError):
                    print(encodingError)
                }
            }
        )
        
    }
    
    func downloadTags(contentID: String, completion: ([String]) -> Void) {
        Alamofire.request(
            .GET,
            "http://api.imagga.com/v1/tagging",
            parameters: ["content" : contentID, "extract_object_colors" : 0],
            encoding: .URL,
            headers: ["Authorization" : "Basic YWNjXzc3MmY3ZjhjNzc0MzcxZjphNGMxYWMyMDQwNWE5MDZjZmEwMWRjMmYzMDhjOWNlYw=="]
        )
            .responseJSON { response in
                guard response.result.isSuccess else {
                    completion([String]())
                    return
                }
                
                let responseJSON = response.result.value
                let results = responseJSON?.valueForKey("results") as! NSArray
                let tagsAndConfidences = results.firstObject!.valueForKey("tags") as! Array<NSDictionary>
                
                let tags = tagsAndConfidences.map({ (let dict: NSDictionary) -> String in
                    let tag = dict["tag"]! as! String
                    return tag
                })

                completion(tags)
                
        }
    }
    
    func downloadColors(contentID: String, completion: ([PhotoColor]) -> Void) {
        Alamofire.request(
            .GET,
            "http://api.imagga.com/v1/colors",
            parameters: ["content" : contentID],
            encoding: .URL,
            headers: ["Authorization" : "Basic YWNjXzc3MmY3ZjhjNzc0MzcxZjphNGMxYWMyMDQwNWE5MDZjZmEwMWRjMmYzMDhjOWNlYw=="]
            )
            .responseJSON { response in
                guard response.result.isSuccess else {
                    completion([PhotoColor]())
                    return
                }
                
                let responseJSON = response.result.value
                let results = responseJSON?.valueForKey("results") as! NSArray
                let firstResult = results.firstObject!
                let info = firstResult.valueForKey("info")!
                let imageColors = info.valueForKey("image_colors") as! Array<NSDictionary>
                
                let photoColors = imageColors.map({ (let values: NSDictionary) -> PhotoColor in
                    let r = values["r"] as! String
                    let g = values["g"] as! String
                    let b = values["b"] as! String
                    let closestPaletteColor = values["closest_palette_color"] as! String
                    
                    let photoColor = PhotoColor(red: Int(r), green: Int(g), blue: Int(b), colorName: closestPaletteColor)
                    
                    return photoColor
                })
                
                completion(photoColors)
        }
    }
}

