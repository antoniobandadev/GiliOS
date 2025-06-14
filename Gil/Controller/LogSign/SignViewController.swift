//
//  SignViewController.swift
//  Gil
//
//  Created by Antonio Banda  on 28/04/25.
//

import UIKit
import MaterialComponents

class SignViewController: KeyboardViewController, UITextFieldDelegate {
    
    let serviceManager = ServiceManager.shared
    
    
    @IBOutlet weak var lbRegister: UILabel!
    
    @IBOutlet weak var tfName: MDCOutlinedTextField!
    
    @IBOutlet weak var tfEmail: MDCOutlinedTextField!
    
    @IBOutlet weak var tfEmailConf: MDCOutlinedTextField!
    
    @IBOutlet weak var tfPassword: MDCOutlinedTextField!
    
    @IBOutlet weak var tfPasswordConf: MDCOutlinedTextField!
    
    @IBOutlet weak var btSignUp: UIButton!
    
    @IBOutlet weak var btTermCond: UIButton!
    
    @IBOutlet weak var btnAcepTermCon: UIButton!
    
    @IBAction func btTermCondAction(_ sender: UIButton) {
    }
    
    var isChecked = false
    @IBAction func btnAcpTermAction(_ sender: UIButton) {
        isChecked.toggle()
        let imageName = isChecked ? "checkmark.square" : "square"
        btnAcepTermCon.setImage(UIImage(systemName: imageName), for: .normal)
        
        btSignUp.isEnabled = isChecked
        
    }
    
    
    @IBAction func btCloseModalAction(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btSignUpAction(_ sender: UIButton) {
        [tfName, tfEmail, tfEmailConf, tfPassword, tfPasswordConf].forEach { $0?.clearTextFieldError() }
        if(isConnected){
            signUpUser()
        }else{
            Utils.Snackbar.snackbarWithAction(message: "no_internet_connection".localized(), bgColor: Constants.Colors.red!, titleAction:"close".localized() ,duration: 5.0)
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Network
        //observeConnectionChanges()
        
        // Do any additional setup after loading the view.
        tfName.delegate = self
        tfEmail.delegate = self
        tfEmailConf.delegate = self
        tfPassword.delegate = self
        tfPasswordConf.delegate = self

        initUI()
    }
    
    
    func initUI(){
        
        lbRegister.text = "sign_up".localized()
        lbRegister.font = Constants.Fonts.fontBold
        
        
        
        //btSignUp.setTitle("sign_up".localized(), for: .normal)
        //btSignUp.titleLabel?.font = Constants.Fonts.fontBold
        
        
        Utils.TextField.config(tfName, label: NSLocalizedString("user".localized(), comment: ""), icon: "ic_user", iconTrailing: "xmark.circle.fill")
        Utils.TextField.config(tfEmail, label: NSLocalizedString("email".localized(), comment: ""), icon: "ic_email", iconTrailing: "xmark.circle.fill")
        Utils.TextField.config(tfEmailConf, label: NSLocalizedString("confirm_email".localized(), comment: ""), icon: "ic_email", iconTrailing: "xmark.circle.fill")
        Utils.TextField.config(tfPassword, label: NSLocalizedString("password".localized(), comment: ""), icon: "ic_password_color", iconTrailing: "eye.fill", password: true)
        Utils.TextField.config(tfPasswordConf, label: NSLocalizedString("confirm_password".localized(), comment: ""), icon: "ic_password_color", iconTrailing: "eye.fill", password: true)
        
    }
    
    func validateinputs() -> Bool {
        let valName = tfName.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let valEmail = tfEmail.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let valEmailConf = tfEmailConf.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let valPassword = tfPassword.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let valPasswordConf = tfPasswordConf.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        var valid = true
        
        if(valName.isEmpty || valName.count < 3){
            Utils.ValidTextField.error(textField: tfName, messageError: "invalid_name".localized())
            valid = false
        }
        
        if (valEmail.isEmpty) {
            Utils.ValidTextField.error(textField: tfEmail, messageError: "not_valid_email".localized())
            valid = false
        }
        
        if (valEmailConf.isEmpty) {
            Utils.ValidTextField.error(textField: tfEmailConf, messageError: "not_valid_email".localized())
            valid = false
        }
        
        if (!valEmail.isValidEmail()){
            Utils.ValidTextField.error(textField: tfEmail, messageError: "not_valid_email".localized())
            valid = false
        }else if(valEmail != valEmailConf) {
            Utils.ValidTextField.error(textField: tfEmail, messageError: "not_same_value".localized())
            Utils.ValidTextField.error(textField: tfEmailConf, messageError: "not_same_value".localized())
            valid = false
        }
        
        if (valPassword.isEmpty) {
            Utils.ValidTextField.error(textField: tfPassword, messageError: "invalid_password".localized())
            valid = false
        }
        
        if (valPasswordConf.isEmpty) {
            Utils.ValidTextField.error(textField: tfPasswordConf, messageError: "invalid_password".localized())
            valid = false
        }
        
        if (!valPassword.isSecurePassword()){
            Utils.ValidTextField.error(textField: tfPassword, messageError: "invalid_password".localized())
            valid = false
        }else if(valPassword != valPasswordConf) {
            Utils.ValidTextField.error(textField: tfPassword, messageError: "not_same_value".localized())
            Utils.ValidTextField.error(textField: tfPasswordConf, messageError: "not_same_value".localized())
            valid = false
        }
        
        return valid
        
    }
    
    func signUpUser() {
        
        if (validateinputs()){
            let valName = tfName.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let valEmail = tfEmail.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let valPassword = tfPassword.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let valUserCreatedAt = dateFormatter.string(from: Date())
            let valDeviceID = UIDevice.current.identifierForVendor?.uuidString
            
            let newUser = UserDto(userId: nil, userName: valName, userEmail: valEmail, userDeviceId: valDeviceID, userPassword: valPassword, userProfile: nil, userStatus: nil, userCreatedAt: valUserCreatedAt)
            
            /*Utils.Snackbar.snackbarNoAction(message: "registration_success".localized(), bgColor: Constants.Colors.green!, duration: 5.0)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                [self.tfName, self.tfEmail, self.tfEmailConf, self.tfPassword, self.tfPasswordConf].forEach { $0?.clearText() }
                self.dismiss(animated: true)
            }*/
            
            
             serviceManager.createUser(user: newUser) { result in
                 switch result {
                     case .success(let user):
                     Utils.Snackbar.snackbarNoAction(message: "registration_success".localized(), bgColor: Constants.Colors.green!, duration: 5.0)
                         DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                             [self.tfName, self.tfEmail, self.tfEmailConf, self.tfPassword, self.tfPasswordConf].forEach { $0?.clearText() }
                             self.dismiss(animated: true)
                         }
                     print(user)
                     print(result)
                         
                     case .failure(let error):
                         if let apiError = error as? APIError {
                             switch apiError {
                             case .unauthorized:
                                 Utils.Snackbar.snackbarWithAction(message: "user_exists".localized(), bgColor: Constants.Colors.red!, titleAction: "close".localized() , duration: 5.0)
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
            
            
        }else{
            
        }
    }
    
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if let mdcTextField = textField as? MDCOutlinedTextField {
            mdcTextField.clearTextFieldError()
        }
    }
    
}


