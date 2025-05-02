//
//  File.swift
//  Gil
//
//  Created by Antonio Banda  on 28/04/25.
//

import UIKit
import MaterialComponents

class Utils {
    
    class TextField {
        // Config MDCOutlinedTextField
        static func config(
            _ textField: MDCOutlinedTextField,
            label: String,
            icon: String? = nil,
            iconTrailing: String? = nil,
            password: Bool = false) {
                
                textField.label.text = label
                textField.setOutlineColor(Constants.Colors.secondary!, for: .normal)
                textField.setOutlineColor(Constants.Colors.secondary!, for: .editing)
                textField.setFloatingLabelColor(Constants.Colors.secondary!, for: .normal)
                textField.setFloatingLabelColor(Constants.Colors.secondary!, for: .editing)
                textField.setNormalLabelColor(Constants.Colors.secondary!, for: .normal)
                textField.setTextColor(Constants.Colors.accent!, for: .normal)
                textField.setTextColor(Constants.Colors.accent!, for: .editing)
                textField.tintColor = Constants.Colors.accent!
                
                // Config icon trailing
                if let iconNameT = iconTrailing, let image = UIImage(systemName: iconNameT) {
                    let button = UIButton(type: .custom)
                    button.setImage(image, for: .normal)
                    button.tintColor = Constants.Colors.accent!
                    button.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
                    
                    // Config to password secure textfields
                    if password {
                        textField.isSecureTextEntry = true
                        button.addTarget(self, action: #selector(togglePassword(_:)), for: .touchUpInside)
                        textField.trailingViewMode = .always
                    } else {
                        button.addTarget(self, action: #selector(clearTextField(_:)), for: .touchUpInside)
                        textField.trailingViewMode = .whileEditing
                    }
                    
                    textField.trailingView = button
                }
                
                // Config icon leading
                if let iconName = icon, let image = UIImage(systemName: iconName) {
                    let iconView = UIImageView(image: image)
                    iconView.tintColor = Constants.Colors.accent!
                    textField.leadingView = iconView
                    textField.leadingViewMode = .always
                }
            }
        
        // Change visibility password
        @objc static func togglePassword(_ sender: UIButton) {
            guard let textField = sender.superview as? MDCOutlinedTextField else { return }
            guard let button = textField.trailingView as? UIButton else { return }
            
            // Change visibility
            textField.isSecureTextEntry.toggle()
            
            // Change icon visible or invible
            let imageName = textField.isSecureTextEntry ? "eye" : "eye.slash"
            let image = UIImage(systemName: imageName)
            button.setImage(image, for: .normal)
        }
        
        // Clear text from TextField
        @objc static func clearTextField(_ sender: UIButton) {
            guard let textField = sender.superview as? MDCOutlinedTextField else { return }
            textField.text = ""
            textField.leadingAssistiveLabel.text = nil
        }
    }//TextFieldConfig
    
    class ValidTextField {
        
        static func error(textField: MDCOutlinedTextField, messageError: String){
            textField.leadingAssistiveLabel.text = messageError
            textField.leadingAssistiveLabel.font = Constants.Fonts.fontMini
            textField.leadingAssistiveLabel.adjustsFontSizeToFitWidth = true
            textField.setLeadingAssistiveLabelColor(Constants.Colors.red!, for: .normal)
            textField.setLeadingAssistiveLabelColor(Constants.Colors.red!, for: .editing)
            textField.setOutlineColor(Constants.Colors.red!, for: .normal)
            textField.setOutlineColor(Constants.Colors.red!, for: .editing)
            textField.setFloatingLabelColor(Constants.Colors.red!, for: .normal)
            textField.setFloatingLabelColor(Constants.Colors.red!, for: .editing)
            textField.setNormalLabelColor(Constants.Colors.red!, for: .normal)
        }
        
        
    }//Validate TextField
    
    class Snackbar {
        static func snackbarNoAction(message:String, bgColor:UIColor, duration:Double) {
            
            let snackMessage = MDCSnackbarMessage()
            snackMessage.text = message
            snackMessage.duration = duration
            
            let snackManager = MDCSnackbarManager.default
            snackManager.snackbarMessageViewBackgroundColor = bgColor
            MDCSnackbarMessageView.appearance().messageTextColor = Constants.Colors.accent
            MDCSnackbarMessageView.appearance().messageFont = Constants.Fonts.fontMini
            MDCSnackbarMessageView.appearance().setButtonTitleColor(Constants.Colors.accent, for: .normal)
            MDCSnackbarMessageView.appearance().buttonFont = Constants.Fonts.fontMini
            
            snackManager.show(snackMessage)
        }//SnackBar
        
        static func snackbarWithAction(message:String, bgColor:UIColor, titleAction:String, duration:Double) {
            
            let snackMessage = MDCSnackbarMessage()
            snackMessage.text = message
            
            let action = MDCSnackbarMessageAction()
            action.title = titleAction
            action.handler = {
                
            }
            
            snackMessage.action = action
            snackMessage.duration = duration
            
            let snackManager = MDCSnackbarManager.default
            snackManager.snackbarMessageViewBackgroundColor = bgColor
            MDCSnackbarMessageView.appearance().messageTextColor = Constants.Colors.accent
            MDCSnackbarMessageView.appearance().messageFont = Constants.Fonts.fontMini
            MDCSnackbarMessageView.appearance().setButtonTitleColor(Constants.Colors.accent, for: .normal)
            MDCSnackbarMessageView.appearance().buttonFont = Constants.Fonts.fontMini
            snackManager.show(snackMessage)
        }
    }
    
    
    
}

extension String {
    func localized() -> String {
        return NSLocalizedString(
            self,
            tableName: "Localizable",
            bundle: .main,
            value:self,
            comment: self
        )
    }
}

extension MDCOutlinedTextField {
    func clearTextFieldError() {
        self.leadingAssistiveLabel.text = nil
        
        self.setOutlineColor(Constants.Colors.secondary!, for: .normal)
        self.setOutlineColor(Constants.Colors.secondary!, for: .editing)
        self.setFloatingLabelColor(Constants.Colors.secondary!, for: .normal)
        self.setFloatingLabelColor(Constants.Colors.secondary!, for: .editing)
        self.setNormalLabelColor(Constants.Colors.secondary!, for: .normal)
        self.setTextColor(Constants.Colors.accent!, for: .normal)
        self.setTextColor(Constants.Colors.accent!, for: .editing)
        self.tintColor = Constants.Colors.accent!
    }
    func clearText() {
        self.leadingAssistiveLabel.text = nil
        
        self.setOutlineColor(Constants.Colors.secondary!, for: .normal)
        self.setOutlineColor(Constants.Colors.secondary!, for: .editing)
        self.setFloatingLabelColor(Constants.Colors.secondary!, for: .normal)
        self.setFloatingLabelColor(Constants.Colors.secondary!, for: .editing)
        self.setNormalLabelColor(Constants.Colors.secondary!, for: .normal)
        self.setTextColor(Constants.Colors.accent!, for: .normal)
        self.setTextColor(Constants.Colors.accent!, for: .editing)
        self.tintColor = Constants.Colors.accent!
        self.text = ""
    }
}

extension String {
    func isValidEmail() -> Bool {
        let emailRegEx =
        "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        
        let emailPredicate = NSPredicate(format: "SELF MATCHES[c] %@", emailRegEx)
        return emailPredicate.evaluate(with: self)
    }
}

extension String {
    func isSecurePassword(minLength: Int = 8) -> Bool {
        let regex =
        "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[!@#\\$%^&*()_+\\-=\\[\\]{};':\"\\\\|,.<>/?]).{\(minLength),}$"
        
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return predicate.evaluate(with: self)
    }
}
