//
//  CreateMemeViewController.swift
//  MemeMe
//
//  Created by Matt Curtis on 4/04/2015.
//  Copyright (c) 2015 Matt Curtis. All rights reserved.
//

import UIKit

class CreateMemeViewController: UIViewController {

    var selectedImage: UIImage!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    var originalFrameOriginY: CGFloat!

    override func viewWillAppear(animated: Bool) {
        var outlineParagraphStyle = NSMutableParagraphStyle()
        outlineParagraphStyle.alignment = .Center

        let outlineTextAttributes = [
            NSFontAttributeName: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40.0)!,
            NSParagraphStyleAttributeName: outlineParagraphStyle,
            NSStrokeColorAttributeName: UIColor.blackColor(),
            NSForegroundColorAttributeName: UIColor.whiteColor(),
            NSStrokeWidthAttributeName: -3.0,
            ]
        topTextField.defaultTextAttributes = outlineTextAttributes
        bottomTextField.defaultTextAttributes = outlineTextAttributes
        originalFrameOriginY = view.frame.origin.y
        subscribeToKeyboardNotifications()
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = selectedImage

//        addPan(topTextField)
//        addPan(bottomTextField)
//        addPan(imageView)
//        addPinch(imageView)
//        addRotation(imageView)
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
//
//    func addPan(view: UIView) {
//        let pan = UIPanGestureRecognizer(target: self, action: "thingDragged:")
//        pan.minimumNumberOfTouches = 2
//        pan.maximumNumberOfTouches = 2
//        view.addGestureRecognizer(pan)
//    }
//
//    func addPinch(view: UIView) {
//        let pinch = UIPinchGestureRecognizer(target: self, action: "thingPinched:")
//        view.addGestureRecognizer(pinch)
//    }
//
//    func addRotation(view: UIView) {
//        let rotate = UIRotationGestureRecognizer(target: self, action: "thingRotated:")
//        view.addGestureRecognizer(rotate)
//    }

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

