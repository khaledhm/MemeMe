//
//  ViewController.swift
//  MemeMe
//
//  Created by Khaled H on 28/12/2018.
//  Copyright © 2018 Khaled H. All rights reserved.
//

import UIKit

class MemeEditorViewController: UIViewController{

    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var navBar: UINavigationBar!
    
    let topText = "TOP"
    let bottomText = "BOTTOM"
    
    let add = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: nil)
    let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
    
    
    let memeTextAttributes: [NSAttributedString.Key: Any] = [
        .strokeColor: UIColor.black,
        .foregroundColor: UIColor.white,
        .font: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        .strokeWidth: -2]
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setTextField(textfield: topTextField, withText: "TOP")
        setTextField(textfield: bottomTextField, withText: "BOTTOM")
        
        shareButton.isEnabled = false
        
        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    //MARK:- setting text fields method
    func setTextField(textfield: UITextField, withText: String) {
        
        textfield.delegate = self
        textfield.defaultTextAttributes = memeTextAttributes
        textfield.textAlignment = .center
        textfield.text = withText
        
    }
    
    //MARK:- Buttons

    func presentImagePickerWith(sourceType: UIImagePickerController.SourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = sourceType
        present(imagePicker, animated:true, completion:nil)
    }

    
    
    //Album button
    @IBAction func pickFromAlbum(_ sender: Any) {
        presentImagePickerWith(sourceType: UIImagePickerController.SourceType.photoLibrary)
        
    }
    
    //Camera Button
    @IBAction func pickFromCamera(_ sender: Any) {
        presentImagePickerWith(sourceType: UIImagePickerController.SourceType.camera)
    }
  
    //Share Button
    @IBAction func ShareAction(_ sender: Any) {
        
        let memedImg = generateMemedImage()
        let shareView = UIActivityViewController(activityItems: [memedImg], applicationActivities: nil)
        
        shareView.completionWithItemsHandler = {
            (activity, completed, items, error) in
            if (completed){
                self.save()
            }
        }
            
        present(shareView, animated: true)
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        
        self.tabBarController?.tabBar.isHidden = false
        self.navigationController?.navigationBar.isHidden = false
        navigationController?.popViewController(animated: true)
    }
    
    //MARK:- Keyboard shifting methods
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification:Notification) {
        if bottomTextField.isEditing {
            view.frame.origin.y -= getKeyboardHeight(notification)
        }
        
    }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    @objc func keyboardWillHide(_ notification:Notification) {
        view.frame.origin.y = 0
    }
    
    
    //MARK:- Saving meme
    
    func save() {
        let meme = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, originalImg: imagePickerView.image!, memeImg: generateMemedImage())
        
        // Add it to the memes array in the Application Delegate
        let object = UIApplication.shared.delegate
        let appDelegate = object as! AppDelegate
        appDelegate.memes.append(meme)
        
        //print("Save " + String(appDelegate.memes.count))
        cancelAction(self)
    }
    
    
    func generateMemedImage() -> UIImage {
        
        // TODO: Hide toolbar and navbar
        configureBars(true)
        
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        // TODO: Show toolbar and navbar
        configureBars(false)
        
        return memedImage
    }
        
    func configureBars(_ isHidden: Bool) {
        
        toolBar.isHidden = isHidden
        navBar.isHidden = isHidden
        
    }
    
    
}

extension MemeEditorViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    //MARK:- ImagePicker Delegate Methods
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        //print("Picked!!")
        
        if let img = info[.originalImage] as? UIImage{
            imagePickerView.image = img
            shareButton.isEnabled = true
        }
        
        dismiss(animated: true, completion: nil)
        
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

extension MemeEditorViewController: UITextFieldDelegate {
    //MARK:- Text fields methods
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.text == topText || textField.text == bottomText{
            textField.text = ""
        }
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true;
    }
}

