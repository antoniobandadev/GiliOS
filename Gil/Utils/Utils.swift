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
                textField.setOutlineColor(Constants.Colors.secondary!, for: .disabled)
                textField.setFloatingLabelColor(Constants.Colors.secondary!, for: .normal)
                textField.setFloatingLabelColor(Constants.Colors.secondary!, for: .editing)
                textField.setFloatingLabelColor(Constants.Colors.secondary!, for: .disabled)
                textField.setNormalLabelColor(Constants.Colors.secondary!, for: .normal)
                textField.setTextColor(Constants.Colors.accent!, for: .normal)
                textField.setTextColor(Constants.Colors.accent!, for: .editing)
                textField.setTextColor(Constants.Colors.accent!, for: .disabled)
                textField.tintColor = Constants.Colors.accent!                
                
                // Config icon trailing
                if let iconNameT = iconTrailing, let image = UIImage(systemName: iconNameT) {
                    let button = UIButton(type: .custom)
                    button.setImage(image, for: .normal)
                    button.tintColor = Constants.Colors.accent!
                    button.frame = CGRect(x: 0, y: 0, width: 34, height: 34)
                    
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
                if let iconName = icon, let image = UIImage(named: iconName) {
                    let iconView = UIImageView(image: image)
                    iconView.tintColor = Constants.Colors.accent!
                    // Configurar tamaño del icono
                    iconView.frame = CGRect(x: 0, y: 0, width: 34, height: 34) // Ajusta el tamaño según necesites
                    iconView.contentMode = .scaleAspectFit
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
            let imageName = textField.isSecureTextEntry ? "eye.fill" : "eye.slash.fill"
            let image = UIImage(systemName: imageName)
            button.setImage(image, for: .normal)
        }
        
        // Clear text from TextField
        @objc static func clearTextField(_ sender: UIButton) {
            guard let textField = sender.superview as? MDCOutlinedTextField else { return }
            textField.text = ""
            textField.sendActions(for: .editingChanged)
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
    }//SnackBar
    
    
    class LoadigAlert{
        static func showAlert(on viewController: UIViewController) -> UIAlertController {
            let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)

          
            if let backgroundView = alert.view.subviews.first?.subviews.first?.subviews.first {
                backgroundView.backgroundColor = Constants.Colors.secondary
                backgroundView.layer.cornerRadius = 12
            }

           
            let widthConstraint = NSLayoutConstraint(item: alert.view!,
                                                     attribute: .width,
                                                     relatedBy: .equal,
                                                     toItem: nil,
                                                     attribute: .notAnAttribute,
                                                     multiplier: 1,
                                                     constant: 300)

            let heightConstraint = NSLayoutConstraint(item: alert.view!,
                                                      attribute: .height,
                                                      relatedBy: .equal,
                                                      toItem: nil,
                                                      attribute: .notAnAttribute,
                                                      multiplier: 1,
                                                      constant: 100)

            alert.view.addConstraint(widthConstraint)
            alert.view.addConstraint(heightConstraint)

            
            let loadingIndicator = UIActivityIndicatorView(style: .large)
            loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
            loadingIndicator.color = .white
            loadingIndicator.startAnimating()
            alert.view.addSubview(loadingIndicator)

           
            let messageLabel = UILabel()
            messageLabel.text = "loading".localized()
            messageLabel.textColor = .white
            messageLabel.font = Constants.Fonts.font
            messageLabel.textAlignment = .center
            messageLabel.translatesAutoresizingMaskIntoConstraints = false
            messageLabel.numberOfLines = 0
            alert.view.addSubview(messageLabel)
            
            NSLayoutConstraint.activate([
                loadingIndicator.centerXAnchor.constraint(equalTo: alert.view.centerXAnchor),
                loadingIndicator.topAnchor.constraint(equalTo: alert.view.topAnchor, constant: 30),

                messageLabel.topAnchor.constraint(equalTo: loadingIndicator.bottomAnchor, constant: 15),
                messageLabel.leadingAnchor.constraint(equalTo: alert.view.leadingAnchor, constant: 16),
                messageLabel.trailingAnchor.constraint(equalTo: alert.view.trailingAnchor, constant: -16),
                messageLabel.bottomAnchor.constraint(lessThanOrEqualTo: alert.view.bottomAnchor, constant: -20)
            ])

            viewController.present(alert, animated: true)
            return alert
        }
        
        static func dismissAlert(_ alert: UIAlertController) {
            alert.dismiss(animated: true)
        }
        
    }//LoadingAlert
    
    class AlertConfirmUtils {
        static func showCustomAlert(
                on viewController: UIViewController,
                title: String,
                message: String,
                confirmTitle: String = "accept".localized(),
                cancelTitle: String? = nil,
                confirmColor: UIColor? = nil,
                cancelColor: UIColor? = nil,
                onConfirm: (() -> Void)? = nil
               // onCancel: (() -> Void)? = nil
            ) {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                if let alertVC = storyboard.instantiateViewController(withIdentifier: "AlertConfViewController") as? AlertConfViewController {
                    alertVC.modalPresentationStyle = .overFullScreen
                    alertVC.modalTransitionStyle = .crossDissolve
                    alertVC.alertTitle = title
                    alertVC.alertMessage = message
                    alertVC.confirmButtonTitle = confirmTitle
                    alertVC.cancelButtonTitle = cancelTitle
                   // alertVC.confirmButtonColor = confirmColor
                   // alertVC.cancelButtonColor = cancelColor
                    alertVC.onConfirm = onConfirm
                    //alertVC.onCancel = onCancel
                    viewController.present(alertVC, animated: true)
                }
            }
    }
    
    class AlertCustomUtils {
        static func showCustomAlert(
                on viewController: UIViewController,
                title: String,
                confirmTitle: String = "save".localized(),
                cancelTitle: String? = nil,
                onConfirm: (() -> Void)? = nil,
                onCancel: (() -> Void)? = nil,
                message: String? = nil
                
        ) {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                if let alertVC = storyboard.instantiateViewController(withIdentifier: "AlertViewController") as? AlertViewController {
                    alertVC.modalPresentationStyle = .overFullScreen
                    alertVC.modalTransitionStyle = .crossDissolve
                    alertVC.alertTitle = title
                    alertVC.confirmButtonTitle = confirmTitle
                    alertVC.cancelButtonTitle = cancelTitle
                   // alertVC = confirmColor
                   // alertVC.cancelButtonColor = cancelColor
                    alertVC.onConfirm = onConfirm
                    alertVC.onCancel = onCancel
                    viewController.present(alertVC, animated: true)
                }
            }
        
        static func showEditCustomAlert(
                on viewController: UIViewController,
                title: String,
                confirmTitle: String = "update".localized(),
                newContact: Bool,
                contact: ContactEntity,
                cancelTitle: String? = "delete".localized(),
                onConfirm: (() -> Void)? = nil,
                onCancel: (() -> Void)? = nil,
                message: String? = nil
        ) {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                if let alertVC = storyboard.instantiateViewController(withIdentifier: "AlertViewController") as? AlertViewController {
                    alertVC.modalPresentationStyle = .overFullScreen
                    alertVC.modalTransitionStyle = .crossDissolve
                    alertVC.alertTitle = title
                    alertVC.confirmButtonTitle = confirmTitle
                    alertVC.cancelButtonTitle = cancelTitle
                    alertVC.newContact = newContact
                    alertVC.myContact = contact
                   // alertVC = confirmColor
                   // alertVC.cancelButtonColor = cancelColor
                    alertVC.onConfirm = onConfirm
                    alertVC.onCancel = onCancel
                    viewController.present(alertVC, animated: true)
                }
            }
        
        static func showConfirmCustomAlert(
                on viewController: UIViewController,
                title: String,
                message: String,
                confirmTitle: String = "yes".localized(),
                cancelTitle: String? = "no".localized(),
                onConfirm: (() -> Void)? = nil,
                onCancel: (() -> Void)? = nil
                
        ) {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                if let alertVC = storyboard.instantiateViewController(withIdentifier: "AlertViewController") as? AlertViewController {
                    alertVC.modalPresentationStyle = .overFullScreen
                    alertVC.modalTransitionStyle = .crossDissolve
                    alertVC.alertTitle = title
                    alertVC.confirmButtonTitle = confirmTitle
                    alertVC.cancelButtonTitle = cancelTitle
                    alertVC.onConfirm = onConfirm
                    alertVC.onCancel = onCancel
                    alertVC.message = message
                    viewController.present(alertVC, animated: true)
                }
            }
    }
    
    class AlertFriendsUtils {
        static func showAlert(
            on viewController: UIViewController,
            title: String,
            confirmTitle: String? = "delete".localized(),
            cancelTitle: String? = nil,
            friend: FriendDto,
            newFriend: Bool = false,
            onConfirm: (() -> Void)? = nil,
            onCancel: (() -> Void)? = nil,
            message: String? = nil,
            sentFriend: Bool = false,
            recivedFriend: Bool = false
            
        ) {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let alertVC = storyboard.instantiateViewController(withIdentifier: "AlertFriendViewController") as? AlertFriendViewController {
                alertVC.modalPresentationStyle = .overFullScreen
                alertVC.modalTransitionStyle = .crossDissolve
                alertVC.alertTitle = title
                alertVC.confirmButtonTitle = confirmTitle
                alertVC.cancelButtonTitle = cancelTitle
                alertVC.myFriend = friend
                alertVC.newFriend = newFriend
                alertVC.onConfirm = onConfirm
                alertVC.onCancel = onCancel
                alertVC.sentFriend = sentFriend
                alertVC.recivedFriend = recivedFriend
                viewController.present(alertVC, animated: true)
            }
        }
        static func showAddFriendAlert(
            on viewController: UIViewController,
            title: String,
            confirmTitle: String? = "add".localized(),
            cancelTitle: String? = nil,
            onConfirm: (() -> Void)? = nil,
            onCancel: (() -> Void)? = nil,
            message: String? = nil
            
        ) {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let alertVC = storyboard.instantiateViewController(withIdentifier: "AlertFriendViewController") as? AlertFriendViewController {
                alertVC.modalPresentationStyle = .overFullScreen
                alertVC.modalTransitionStyle = .crossDissolve
                alertVC.alertTitle = title
                alertVC.confirmButtonTitle = confirmTitle
                alertVC.cancelButtonTitle = cancelTitle
                alertVC.onConfirm = onConfirm
                alertVC.onCancel = onCancel
                viewController.present(alertVC, animated: true)
            }
        }
        
        static func showConfirmFriendAlert(
                on viewController: UIViewController,
                title: String,
                message: String,
                confirmTitle: String = "yes".localized(),
                cancelTitle: String? = "no".localized(),
                onConfirm: (() -> Void)? = nil,
                onCancel: (() -> Void)? = nil
                
        ) {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                if let alertVC = storyboard.instantiateViewController(withIdentifier: "AlertFriendViewController") as? AlertFriendViewController {
                    alertVC.modalPresentationStyle = .overFullScreen
                    alertVC.modalTransitionStyle = .crossDissolve
                    alertVC.alertTitle = title
                    alertVC.confirmButtonTitle = confirmTitle
                    alertVC.cancelButtonTitle = cancelTitle
                    alertVC.onConfirm = onConfirm
                    alertVC.onCancel = onCancel
                    alertVC.message = message
                    viewController.present(alertVC, animated: true)
                }
            }
    }
    
    class AlertSettingsUtils {
        static func showAlert(
            on viewController: UIViewController,
            title: String,
            userId: Int,
            userName: String,
            onConfirm: (() -> Void)? = nil,
            onCancel: (() -> Void)? = nil
        ) {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let alertVC = storyboard.instantiateViewController(withIdentifier: "AlertSettingsViewController") as? AlertSettingsViewController{
                alertVC.modalPresentationStyle = .overFullScreen
                alertVC.modalTransitionStyle = .crossDissolve
                alertVC.title = title
                alertVC.userId = userId
                alertVC.userName = userName
                alertVC.onConfirm = onConfirm
                alertVC.onCancel = onCancel
                viewController.present(alertVC, animated: true)
            }
        }
    }
    
    static let eventCategories = ["event_category_social".localized(), "event_category_corporate".localized(), "event_category_academic".localized(), "event_category_other".localized()]
    
    
    static func dateFormatString(date: String, fromFormat: String, toFormat: String) -> String? {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = fromFormat
        inputFormatter.locale = Locale(identifier: "en_US_POSIX")
        let currentLocale = Locale.current

        if let date = inputFormatter.date(from: date) {
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = toFormat
            outputFormatter.locale = Locale(identifier: currentLocale.identifier)
            return outputFormatter.string(from: date)
        }

        return nil
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
