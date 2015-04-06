//
//  CreateMemeViewController.swift
//  MemeMe
//
//  Created by Matt Curtis on 4/04/2015.
//  Copyright (c) 2015 Matt Curtis. All rights reserved.
//

import UIKit

class CreateMemeViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var albumButton: UIBarButtonItem!
    var originalFrameOriginY: CGFloat!

    override func viewWillAppear(animated: Bool) {
        var outlineParagraphStyle = NSMutableParagraphStyle()
        outlineParagraphStyle.alignment = .Center

        let outlineTextAttributes = [
            NSFontAttributeName: UIFont(name: "Impact", size: 40.0)!,
            NSParagraphStyleAttributeName: outlineParagraphStyle,
            NSStrokeColorAttributeName: UIColor.blackColor(),
            NSForegroundColorAttributeName: UIColor.whiteColor(),
            NSStrokeWidthAttributeName: -3.0]

        topTextField.defaultTextAttributes = outlineTextAttributes
        bottomTextField.defaultTextAttributes = outlineTextAttributes
        originalFrameOriginY = view.frame.origin.y
        subscribeToKeyboardNotifications()
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }

    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var toolBar: UIToolbar!
    override func viewDidLoad() {
        super.viewDidLoad()
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
            imageView.image = image
        }
    }

    @IBAction func shareMeme(sender: AnyObject) {
        let memeImage = renderMemeImage()
        shareImages([memeImage])
    }

    func renderMemeImage() -> UIImage {
        toolBar.hidden = true
        navigationBar.hidden = true

        UIGraphicsBeginImageContext(view.frame.size)
        view.drawViewHierarchyInRect(view.frame, afterScreenUpdates: true)
        let memeImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        toolBar.hidden = false
        navigationBar.hidden = false

        return memeImage
    }

    func shareImages(images: [UIImage]) {
        let avc = UIActivityViewController(activityItems: images, applicationActivities: nil)
        presentViewController(avc, animated: true, completion: nil)
    }

    @IBAction func cancel(sender: AnyObject) {

    }

    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as NSValue
        let keyboardSizeRect = keyboardSize.CGRectValue()
        return keyboardSizeRect.height
    }

    func keyboardWillShow(notification: NSNotification) {
        if bottomTextField.editing {
            let height = getKeyboardHeight(notification)
            view.frame.origin.y -= height
        }
    }

    func keyboardWillHide(notification: NSNotification) {
        view.frame.origin.y = originalFrameOriginY
    }

    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }

    func unsubscribeFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }

    @IBAction func translateView(recognizer: UIPanGestureRecognizer) {
        if recognizer.state == .Began || recognizer.state == .Changed {
            let thing = recognizer.view!
            let translation = recognizer.translationInView(thing)

            thing.transform = CGAffineTransformTranslate(thing.transform, translation.x, translation.y)
            recognizer.setTranslation(CGPointZero, inView: thing)
        }
    }

    @IBAction func scaleView(recognizer: UIPinchGestureRecognizer) {
        if recognizer.state == .Began || recognizer.state == .Changed {
            let thing = recognizer.view!
            let scale = recognizer.scale

            thing.transform = CGAffineTransformScale(thing.transform, scale, scale)
            recognizer.scale = 1
        }
    }

    @IBAction func rotateView(recognizer: UIRotationGestureRecognizer) {
        if recognizer.state == .Began || recognizer.state == .Changed {
            let thing = recognizer.view!
            let rotation = recognizer.rotation

            thing.transform = CGAffineTransformRotate(thing.transform, rotation)
            recognizer.rotation = 0
        }
    }

}

