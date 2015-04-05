//
//  SelectMemeSourceViewController.swift
//  MemeMe
//
//  Created by Matt Curtis on 4/04/2015.
//  Copyright (c) 2015 Matt Curtis. All rights reserved.
//

import UIKit

class SelectMemeSourceViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var cameraButton: UIButton!

    override func viewDidLoad() {
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(.Camera)
    }

    @IBAction func selectFromAlbum(sender: AnyObject?) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .PhotoLibrary
        presentViewController(picker, animated: true, completion: nil)
    }

    @IBAction func selectFromCamera(sender: AnyObject?) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .Camera
        presentViewController(picker, animated: true, completion: nil)
    }

    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        dismissViewControllerAnimated(true, completion: nil)

        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let createVC = storyboard.instantiateViewControllerWithIdentifier("CreateMemeViewController") as CreateMemeViewController
            createVC.selectedImage = image
            navigationController?.pushViewController(createVC, animated: true)
        }
    }

}
