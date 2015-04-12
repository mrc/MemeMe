//
//  CreateMemeViewController.swift
//  MemeMe
//
//  Created by Matt Curtis on 4/04/2015.
//  Copyright (c) 2015 Matt Curtis. All rights reserved.
//

import UIKit

class CreateMemeViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var albumButton: UIBarButtonItem!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var toolBar: UIToolbar!

    var originalFrameOriginY: CGFloat!

    override func viewWillAppear(animated: Bool) {
        // Center the meme text
        var outlineParagraphStyle = NSMutableParagraphStyle()
        outlineParagraphStyle.alignment = .Center

        // Use the "Impact" font with a black outline, filled white
        let outlineTextAttributes = [
            NSFontAttributeName: UIFont(name: "Impact", size: 40.0)!,
            NSParagraphStyleAttributeName: outlineParagraphStyle,
            NSStrokeColorAttributeName: UIColor.blackColor(),
            NSForegroundColorAttributeName: UIColor.whiteColor(),
            NSStrokeWidthAttributeName: -3.0]

        // Use the meme text style for the text fields
        topTextField.defaultTextAttributes = outlineTextAttributes
        bottomTextField.defaultTextAttributes = outlineTextAttributes
        originalFrameOriginY = view.frame.origin.y

        // Watch keyboard notifications to "slide up" the keyboard
        subscribeToKeyboardNotifications()
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Only enable the camera button if the camera device is available
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(.Camera)
    }

    /**
        Pick an image from the photo album.
    */
    @IBAction func selectFromAlbum(sender: AnyObject?) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .PhotoLibrary
        presentViewController(picker, animated: true, completion: nil)
    }

    /**
        Take an image with the camera.
    */
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

    /**
        Create the meme image, and share it or save it.
    */
    @IBAction func shareMeme(sender: AnyObject) {
        // Create the meme image
        let memeImage = renderMemeImage()

        // Save it to the list of memes
        saveMeme(memeImage)

        // Share the image (using a singleton array)
        shareImages([memeImage])
    }

    /**
        Render the image and text to a single UIImage.
    
        @return The rendered image.
    */
    func renderMemeImage() -> UIImage {
        // Hide elements that should not be rendered.
        toolBar.hidden = true
        navigationBar.hidden = true

        // Save the display to an image.
        UIGraphicsBeginImageContext(view.frame.size)
        view.drawViewHierarchyInRect(view.frame, afterScreenUpdates: true)
        let memeImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        // Restore hidden elements.
        toolBar.hidden = false
        navigationBar.hidden = false

        return memeImage
    }

    /**
        Save the meme to the list of sent memes.
    
        @param memeImage The meme to be sent.
    */
    func saveMeme(memeImage: UIImage) {
        if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate {
            let meme = Meme(topText: topTextField.text, bottomText: bottomTextField.text, image: memeImage)
            appDelegate.memes.append(meme)
        }
    }

    /**
        Share a collection of images using the UIActivityViewController.
    
        @param images An array of images to share.
    */
    func shareImages(images: [UIImage]) {
        let avc = UIActivityViewController(activityItems: images, applicationActivities: nil)
        avc.popoverPresentationController?.sourceView = view
        presentViewController(avc, animated: true, completion: nil)
    }

    /**
        Done creating memes, return from this view.
    */
    @IBAction func cancel(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        // Allow the return key to dismiss the keyboard.
        textField.resignFirstResponder()
        return true
    }

    /**
        Get the keyboard height from an NSNotification.
    
        @param notification The notification.
    
        @return The keyboard height.
    */
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as? NSValue
        let keyboardSizeRect = keyboardSize?.CGRectValue()
        return keyboardSizeRect?.height ?? 0
    }

    /**
        The target for the UIKeyboardWillShowNotification.
    
        Move the view up (including the image and the text field) when
        editing the bottom text field, so it can be seen.
    */
    func keyboardWillShow(notification: NSNotification) {
        if bottomTextField.editing {
            let height = getKeyboardHeight(notification)
            view.frame.origin.y -= height
        }
    }

    /**
        The target for the UIKeyboardWillHideNotification.
    
        Restore the view after earlier moving it up in keyboardWillShow.
    */
    func keyboardWillHide(notification: NSNotification) {
        view.frame.origin.y = originalFrameOriginY
    }

    /**
        Subscribe to keyboard notifications in NSNotificationCenter.
    */
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }

    /**
        Remove subscriptions for keyboard notifications in NSNotificationCenter.
    */
    func unsubscribeFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }

    /**
        A gesture handler that moves the view around.
    */
    @IBAction func translateView(recognizer: UIPanGestureRecognizer) {
        if recognizer.state == .Began || recognizer.state == .Changed {
            let thing = recognizer.view!
            let translation = recognizer.translationInView(thing)

            // Move the view
            thing.transform = CGAffineTransformTranslate(thing.transform, translation.x, translation.y)

            // Reset the gesture recognizer
            recognizer.setTranslation(CGPointZero, inView: thing)
        }
    }

    /**
        A gesture handler that resizes the view.
    */
    @IBAction func scaleView(recognizer: UIPinchGestureRecognizer) {
        if recognizer.state == .Began || recognizer.state == .Changed {
            let thing = recognizer.view!
            let scale = recognizer.scale

            // Scale the view
            thing.transform = CGAffineTransformScale(thing.transform, scale, scale)

            // Reset the gesture recognizer
            recognizer.scale = 1
        }
    }

    /**
        A gesture handler that rotates the view.
    */
    @IBAction func rotateView(recognizer: UIRotationGestureRecognizer) {
        if recognizer.state == .Began || recognizer.state == .Changed {
            let thing = recognizer.view!
            let rotation = recognizer.rotation

            // Rotate the view
            thing.transform = CGAffineTransformRotate(thing.transform, rotation)

            // Reset the gesture recognizer
            recognizer.rotation = 0
        }
    }

}

