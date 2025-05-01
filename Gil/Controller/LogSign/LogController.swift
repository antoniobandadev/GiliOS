//
//  ViewController.swift
//  Gil
//
//  Created by Antonio Banda  on 26/03/25.
//

import UIKit
import MaterialComponents

class LogController: KeyboardViewController {
    
    @IBOutlet weak var tfUserName: MDCOutlinedTextField!
    
    @IBOutlet weak var tfUserPassword: MDCOutlinedTextField!
    
    
    @IBOutlet weak var btLogin: UIButton!
    
    @IBOutlet weak var btNewSign: UIButton!
    
    @IBAction func btnRegister(_ sender: UIButton) {
        performSegue(withIdentifier: "signUpSegue", sender: self)
    }
    
    @IBAction func btnLogin(_ sender: UIButton) {
        
        /*let validEmail = Utils.ValidTextField.error(textField: tfUserName, messageError: "empty_email".localized())
        let validPassword = Utils.ValidTextField.error(textField: tfUserPassword, messageError: "empty_password".localized())

            if validEmail && validPassword {
                if(tfUserName.text == "admin" && tfUserPassword.text == "123"){
                    // Continuar con login
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let mainTabBarController = storyboard.instantiateViewController(identifier: "MainTabBarController")
                    
                    // This is to get the SceneDelegate object from your view controller
                    // then call the change root view controller function to change to main tab bar
                    (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(mainTabBarController)
                    
                }else{
                    Utils.Snackbar.snackbarNoAction(message: "invalid_data".localized(), bgColor: Constants.Colors.red!)
                }
                
            }*/
        
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //self.hideKeyboardOnTapAround()
        
        //Iniciamos la vista
        initUI()
        
    }
    
    
    func initUI(){
        /*btLogin.setTitle("login".localized(), for: .normal)*/
        btNewSign.setTitle("sign_up_now".localized(), for: .normal)
        btNewSign.titleLabel?.font = Constants.Fonts.fontMini
        btNewSign.titleLabel?.textAlignment = .center
        
        
        Utils.TextField.config(tfUserName, label: NSLocalizedString("email".localized(), comment: ""), icon: "person.circle.fill", iconTrailing: "xmark.circle.fill")
        tfUserName.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        Utils.TextField.config(tfUserPassword, label: NSLocalizedString("password".localized(), comment: ""), icon: "exclamationmark.lock", iconTrailing: "eye", password: true)
        tfUserPassword.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
    }
    
    @objc func textFieldDidChange(_ textField: MDCOutlinedTextField) {
        applyValidStyle(to: textField)
    }
    
    func applyValidStyle(to textField: MDCOutlinedTextField) {
        textField.leadingAssistiveLabel.text = nil
        textField.setOutlineColor(Constants.Colors.secondary!, for: .normal)
        textField.setOutlineColor(Constants.Colors.secondary!, for: .editing)
        textField.setFloatingLabelColor(Constants.Colors.secondary!, for: .normal)
        textField.setFloatingLabelColor(Constants.Colors.secondary!, for: .editing)
        textField.setNormalLabelColor(Constants.Colors.secondary!, for: .normal)
    }
    
    
    
}



