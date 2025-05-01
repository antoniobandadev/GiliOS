//
//  SignViewController.swift
//  Gil
//
//  Created by Antonio Banda  on 28/04/25.
//

import UIKit
import MaterialComponents

class SignViewController: KeyboardViewController, UITextFieldDelegate {
    
    @IBOutlet weak var lbRegister: UILabel!
    
    @IBOutlet weak var tfName: MDCOutlinedTextField!
    
    @IBOutlet weak var tfEmail: MDCOutlinedTextField!
    
    @IBOutlet weak var tfEmailConf: MDCOutlinedTextField!
    
    @IBOutlet weak var tfPassword: MDCOutlinedTextField!
    
    @IBOutlet weak var tfPasswordConf: MDCOutlinedTextField!
    
    @IBOutlet weak var btSignUp: UIButton!
    
    @IBAction func btCloseModalAction(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btSignUpAction(_ sender: UIButton) {
        [tfName, tfEmail, tfEmailConf, tfPassword, tfPasswordConf].forEach { $0?.clearTextFieldError() }
        if(isConnected){
            signUpUser()
        }else{
            Utils.Snackbar.snackbarNoAction(message: "Sin conexion", bgColor: Constants.Colors.red!, duration: 3.0)
        }
        
        
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Network
        observeConnectionChanges()
        
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
        
        
        Utils.TextField.config(tfName, label: NSLocalizedString("user".localized(), comment: ""), icon: "person.circle.fill", iconTrailing: "xmark.circle.fill")
        Utils.TextField.config(tfEmail, label: NSLocalizedString("email".localized(), comment: ""), icon: "envelope.circle.fill", iconTrailing: "xmark.circle.fill")
        Utils.TextField.config(tfEmailConf, label: NSLocalizedString("confirm_email".localized(), comment: ""), icon: "envelope.circle.fill", iconTrailing: "xmark.circle.fill")
        Utils.TextField.config(tfPassword, label: NSLocalizedString("password".localized(), comment: ""), icon: "key.fill", iconTrailing: "eye", password: true)
        Utils.TextField.config(tfPasswordConf, label: NSLocalizedString("confirm_password".localized(), comment: ""), icon: "key.fill", iconTrailing: "eye", password: true)
        
    }
    
    func validateinputs() -> Bool {
       
        var valid = true
       
        let valName = tfName.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let valEmail = tfEmail.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let valEmailConf = tfEmailConf.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let valPassword = tfPassword.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let valPasswordConf = tfPasswordConf.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
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
            Utils.Snackbar.snackbarNoAction(message: "Registro exitoso!!", bgColor: Constants.Colors.green!, duration: 3.0)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                [self.tfName, self.tfEmail, self.tfEmailConf, self.tfPassword, self.tfPasswordConf].forEach { $0?.clearText() }
                self.dismiss(animated: true)
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


