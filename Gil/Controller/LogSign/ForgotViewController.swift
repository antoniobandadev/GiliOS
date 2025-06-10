//
//  ForgotViewController.swift
//  Gil
//
//  Created by Antonio Banda  on 06/06/25.
//

import UIKit
import MaterialComponents

class ForgotViewController: KeyboardViewController, UITextFieldDelegate {
    let serviceManager = ServiceManager.shared
    var codeUpdate : Int? = nil
    var userId : Int? = nil
    var codeSend : Bool = false
    
    @IBAction func btnClose(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBOutlet weak var lbTitle: UILabel!
    
    @IBOutlet weak var imgCheckMail: UIImageView!
    
    @IBOutlet weak var imgCheckCode: UIImageView!
    
    @IBOutlet weak var tfForgEmail: MDCOutlinedTextField!
    
    @IBOutlet weak var tfForgCode: MDCOutlinedTextField!
    
    @IBOutlet weak var tfForgPass: MDCOutlinedTextField!
    
    @IBOutlet weak var tfForgPassConf: MDCOutlinedTextField!
    
    @IBAction func btnContinue(_ sender: Any) {
        tfForgEmail.clearTextFieldError()
        tfForgCode.clearTextFieldError()
        let email = tfForgEmail.text ?? ""
        
        if(codeSend){
            if(validPassword()){
                updatePassword()
            }
            
        }else{
            if(valEmail(email: email)){
                sendCode()
            }
        }
        
    }
    
    @IBOutlet weak var btnContinueVal: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tfForgCode.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        tfForgEmail.delegate = self
        tfForgCode.delegate = self
        tfForgPass.delegate = self
        tfForgPassConf.delegate = self
       
    }
    
    func initUI(){
        
        [tfForgEmail, tfForgCode, tfForgPass, tfForgPassConf].forEach { $0?.clearTextFieldError() }
        
        lbTitle.text = "change_password".localized()
        lbTitle.font = Constants.Fonts.fontBold
        
        imgCheckMail.isHidden = true
        imgCheckCode.isHidden = true
        tfForgCode.isHidden = true
        tfForgPass.isHidden = true
        tfForgPassConf.isHidden = true
        
        Utils.TextField.config(tfForgEmail, label: NSLocalizedString("email".localized(), comment: ""), icon: "ic_email", iconTrailing: "xmark.circle.fill")
        Utils.TextField.config(tfForgCode, label: NSLocalizedString("forgot_code".localized(), comment: ""), icon: "ic_pass_code", iconTrailing: "xmark.circle.fill")
        Utils.TextField.config(tfForgPass, label: NSLocalizedString("new_password".localized(), comment: ""), icon: "ic_password_color", iconTrailing: "eye.fill", password: true)
        Utils.TextField.config(tfForgPassConf, label: NSLocalizedString("confirm_new_password".localized(), comment: ""), icon: "ic_password_color", iconTrailing: "eye.fill", password: true)
        
    }
    
    func sendCode(){
        let valEmail = tfForgEmail.text ?? ""
        let language = Locale.preferredLanguages.first ?? "en"
        let alertLoading = Utils.LoadigAlert.showAlert(on: self)
        
        let forgotPass = ForgotPassReqDto(userEmail: valEmail, userLanguage: language)
        
        serviceManager.forgotPass(forgotPass: forgotPass)  { result in
           
            switch result {
                
            case .success(let forgotPassDto):
                alertLoading.dismiss(animated: true)
                
                Utils.AlertConfirmUtils.showCustomAlert(
                    on: self,
                    title: "send_code".localized(),
                    message: "verification_code_sent".localized(),
                    confirmTitle: "ok".localized(),
                    cancelTitle: nil, // No muestra botón de cancelar
                    confirmColor: .systemGreen
                ){
                    self.imgCheckMail.isHidden = false
                    self.tfForgEmail.isEnabled = false
                    self.tfForgCode.isHidden = false
                    self.codeSend = true
                    self.codeUpdate = forgotPassDto.userPassCode
                    self.userId  = forgotPassDto.userId
                    self.btnContinueVal.isEnabled = false
                }
                    
                
                
                    /*UserDefaults.standard.set(true, forKey: "isLogged")
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let mainTabBarController = storyboard.instantiateViewController(identifier: "MainTabBarController")
                    (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(mainTabBarController)*/
                
                                    
               // print(user)
                print(result)
                
            case .failure(let error):
                alertLoading.dismiss(animated: true){
                    if let apiError = error as? APIError {
                        switch apiError {
                        case .unauthorized:
                            Utils.ValidTextField.error(textField: self.tfForgEmail, messageError: "no_email_found".localized())
                            /*Utils.Snackbar.snackbarWithAction(message: "no_email_found".localized(), bgColor: Constants.Colors.red!, titleAction: "close".localized() , duration: 5.0)*/
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
    }
    
    func updatePassword(){
        let valPassword: String = tfForgPass.text ?? ""
        let alertLoading = Utils.LoadigAlert.showAlert(on: self)
        
        let updatePass = UpdatePassDto(userId: userId, userPassword: valPassword)
        
        serviceManager.UpdatePassword(updatePass: updatePass)  { result in
            switch result {
            case .success(_):
                alertLoading.dismiss(animated: true){
                    Utils.Snackbar.snackbarNoAction(message: "password_changed_successfully".localized(), bgColor: Constants.Colors.green!, duration: 5.0)
                
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        self.dismiss(animated: true)
                    }
                }
                default:
                alertLoading.dismiss(animated: true){
                    Utils.Snackbar.snackbarNoAction(message: "server_error".localized(), bgColor: Constants.Colors.red!, duration: 5.0)
                }
            }
        }
        
    }
    
    func validPassword() -> Bool {
        var valid = true
        let valPassword: String = tfForgPass.text ?? ""
        let valPasswordConf: String = tfForgPassConf.text ?? ""
        
        if (valPassword.isEmpty) {
            Utils.ValidTextField.error(textField: tfForgPass, messageError: "invalid_password".localized())
            valid = false
        }
        
        if (valPasswordConf.isEmpty) {
            Utils.ValidTextField.error(textField: tfForgPassConf, messageError: "invalid_password".localized())
            valid = false
        }
        
        if (!valPassword.isSecurePassword()){
            Utils.ValidTextField.error(textField: tfForgPass, messageError: "invalid_password".localized())
            valid = false
        }else if(valPassword != valPasswordConf) {
            Utils.ValidTextField.error(textField: tfForgPass, messageError: "not_same_value".localized())
            Utils.ValidTextField.error(textField: tfForgPassConf, messageError: "not_same_value".localized())
            valid = false
        }
        
        return valid
    }
    
    
    func valEmail(email : String) -> Bool {
        if (!email.isValidEmail()){
            Utils.ValidTextField.error(textField: tfForgEmail, messageError: "not_valid_email".localized())
            return false
        }else{
            return true
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if let mdcTextField = textField as? MDCOutlinedTextField {
            mdcTextField.clearTextFieldError()
        }
    }
    
    
    

    @objc func textFieldDidChange(_ textField: UITextField) {
        print("Texto actual: \(textField.text ?? "")")
        if(Int(textField.text ?? "0" ) == codeUpdate){
            tfForgPass.isHidden = false
            tfForgPassConf.isHidden = false
            tfForgCode.isEnabled = false
            imgCheckCode.isHidden = false
            btnContinueVal.isEnabled = true
            tfForgCode.clearTextFieldError()
        }else{
            if(textField.text!.count > 5){
                Utils.ValidTextField.error(textField: tfForgCode, messageError: "incorrect_code".localized())
            }
        }
    }
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
