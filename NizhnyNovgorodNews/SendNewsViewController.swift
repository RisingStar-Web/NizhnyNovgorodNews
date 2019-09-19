//
//  SendNewsViewController.swift
//  KrasnoyarskNews
//
//  Created by Anton on 24.12.2018.
//  Copyright © 2018 Home. All rights reserved.
//

import UIKit
import JGProgressHUD

class SendNewsViewController: UIViewController {

    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var subtitleField: UITextField!
    @IBOutlet weak var bodyField: UITextView!
    @IBOutlet weak var sendRequestBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print ("SendNewsViewController ViewDidLoad")
        setupNavigationController()
        setupKeyboadDismissTapGesture()
        
        titleField.delegate = self
        subtitleField.delegate = self
        bodyField.delegate = self
        
        bodyField.textColor = UIColor.lightGray
        bodyField.text = "Описание Новости"
    }
        
    fileprivate func setupNavigationController() {
        navigationController?.navigationBar.isTranslucent = false;
        navigationController?.navigationBar.barTintColor = UIColor.color_redMain()
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        title = "Предложить Новость"
    }
    
    //MARK:- Keyboard
    
    fileprivate func setupKeyboadDismissTapGesture() {
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapDismiss)))
    }
    
    @objc fileprivate func handleTapDismiss() {
        view.endEditing(true)
    }
    
    //MARK:- Actions
    
    @IBAction func menuButtonDidClicked(_ sender: Any) {
        sideMenuController?.revealMenu()
    }

    let failHUD = JGProgressHUD(style: .dark)
    let loginHUD = JGProgressHUD(style: .dark)
    
    @IBAction func sendRequestButtonPressed(_ sender: UIButton) {
        if (titleField.text?.count)! < 1 || (subtitleField.text?.count)! < 1 || (bodyField.text?.count)! < 1 {
            self.failHUD.textLabel.text = "Необходиом указать все данные для отправки Новости"
            self.failHUD.indicatorView = nil
            self.failHUD.show(in: self.view)
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.failHUD.dismiss()
            }
        } else {
            self.loginHUD.textLabel.text = "Отправка данных..."
            self.loginHUD.show(in: self.view)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.7) {
                self.titleField.text = ""
                self.subtitleField.text = ""
                self.bodyField.textColor = UIColor.lightGray
                self.bodyField.text = "Описание Новости"
                self.loginHUD.dismiss()
            }
        }
    }
    
}

extension SendNewsViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) { }
    
}

extension SendNewsViewController: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Описание Новости"
            textView.textColor = UIColor.lightGray
        }
    }
    
}
