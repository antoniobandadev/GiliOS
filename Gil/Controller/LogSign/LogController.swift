//
//  ViewController.swift
//  Gil
//
//  Created by Antonio Banda  on 26/03/25.
//

import UIKit
import MaterialComponents

class LogController: KeyboardViewController, UITextFieldDelegate {
    
    let serviceManager = ServiceManager.shared
    
    @IBOutlet weak var tfUserName: MDCOutlinedTextField!
    
    @IBOutlet weak var tfUserPassword: MDCOutlinedTextField!
    
    
    @IBOutlet weak var btLogin: UIButton!
    
    @IBOutlet weak var btNewSign: UIButton!
    
    @IBOutlet weak var btForgotPass: UIButton!
    
    
    @IBAction func btnRegister(_ sender: UIButton) {
        tfUserName.clearTextFieldError()
        tfUserPassword.clearTextFieldError()
        performSegue(withIdentifier: "signUpSegue", sender: self)
    }
    
    @IBAction func btnForgot(_ sender: UIButton) {
        tfUserName.clearTextFieldError()
        tfUserPassword.clearTextFieldError()
        performSegue(withIdentifier: "forgotSegue", sender: self)
        
    }
    
    
    @IBAction func btnLogin(_ sender: UIButton) {
        if(isConnected){
            logUser()
        }else{
            Utils.Snackbar.snackbarWithAction(message: "no_internet_connection".localized(), bgColor: Constants.Colors.red!, titleAction:"close".localized() ,duration: 5.0)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // Network
        observeConnectionChanges()
        tfUserName.delegate = self
        tfUserPassword.delegate = self
        
        //Init view
        DispatchQueue.main.async {
            self.initUI()
        }
        
        
        
    }
    
    
    func initUI(){
        //let alert = Utils.LoadigAlert.showAlert(on: self, message: "loading".localized())
        /*btLogin.setTitle("login".localized(), for: .normal)*/
        btNewSign.setTitle("sign_up_now".localized(), for: .normal)
        btNewSign.titleLabel?.font = Constants.Fonts.fontMini
        btNewSign.titleLabel?.textAlignment = .center
        
        
        Utils.TextField.config(tfUserName, label: NSLocalizedString("email".localized(), comment: ""), icon: "ic_email", iconTrailing: "xmark.circle.fill")
        tfUserName.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        Utils.TextField.config(tfUserPassword, label: NSLocalizedString("password".localized(), comment: ""), icon: "ic_password_color", iconTrailing: "eye.fill", password: true)
        tfUserPassword.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
    }
    
    func validateFields() -> Bool {
        var valid = true
        
        let valEmail = tfUserName.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let valPassword = tfUserPassword.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        if (valEmail.isEmpty) {
            Utils.ValidTextField.error(textField: tfUserName, messageError: "empty_email".localized())
            valid = false
        }
        
        if (valPassword.isEmpty) {
            Utils.ValidTextField.error(textField: tfUserPassword, messageError: "empty_password".localized())
            valid = false
        }
        
        return valid
    }
    
    func logUser() {
        if(validateFields()){
            
            let alert = Utils.LoadigAlert.showAlert(on: self)
            
            let valEmail = tfUserName.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let valPassword = tfUserPassword.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            
            let logUser = UserDto(userId: nil, userName: nil, userEmail: valEmail, userDeviceId: nil, userPassword: valPassword, userProfile: nil, userStatus: nil,  userCreatedAt: nil)
            
            serviceManager.loginUser(user: logUser) { result in
               
                switch result {
                    
                case .success(let user):
                    alert.dismiss(animated: true){
                        Utils.Snackbar.snackbarNoAction(message: "login_success".localized(), bgColor: Constants.Colors.green!, duration: 3.0)
                    
                    
                        UserDefaults.standard.set(true, forKey: "isLogged")
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let mainTabBarController = storyboard.instantiateViewController(identifier: "MainTabBarController")
                        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(mainTabBarController)
                    }
                                        
                   // print(user)
                   // print(result)
                    
                case .failure(let error):
                    alert.dismiss(animated: true){
                        if let apiError = error as? APIError {
                            switch apiError {
                            case .unauthorized:
                                Utils.Snackbar.snackbarWithAction(message: "invalid_data".localized(), bgColor: Constants.Colors.red!, titleAction: "close".localized() , duration: 5.0)
                            default:
                                Utils.Snackbar.snackbarNoAction(message: "server_error".localized(), bgColor: Constants.Colors.red!, duration: 5.0)
                            }
                        } else {
                            Utils.Snackbar.snackbarNoAction(message: "server_error".localized(), bgColor: Constants.Colors.red!, duration: 5.0)
                            // Si es otro tipo de error
                            print(error.localizedDescription)
                        }
                    }
                }
            }
            
            
            //Send log intent user@mail.com User123#
            /*if(tfUserName.text == "admin@mail.com" && tfUserPassword.text == "Contra123$"){
             Utils.Snackbar.snackbarNoAction(message: "login_success".localized(), bgColor: Constants.Colors.green!, duration: 3.0)
             UserDefaults.standard.set(true, forKey: "isLogged")
             let storyboard = UIStoryboard(name: "Main", bundle: nil)
             let mainTabBarController = storyboard.instantiateViewController(identifier: "MainTabBarController")
             (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(mainTabBarController)
             }else{
             Utils.Snackbar.snackbarWithAction(message: "invalid_data".localized(), bgColor: Constants.Colors.red!, titleAction:"close".localized() ,duration: 5.0)
             }*/
        }
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
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if let mdcTextField = textField as? MDCOutlinedTextField {
            mdcTextField.clearTextFieldError()
        }
    }
    
    
    
}

