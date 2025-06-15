//
//  AlertSettingsViewController.swift
//  Gil
//
//  Created by Antonio Banda  on 14/06/25.
//

import UIKit
import MaterialComponents

class AlertSettingsViewController:  KeyboardViewController, UITextFieldDelegate  {
    
    let serviceManager = ServiceManager.shared
    var userId: Int = 0
    var userName: String?
    var alertTitle: String?
    var onConfirm: (() -> Void)?
    var onCancel: (() -> Void)?
    
    @IBOutlet weak var lbTitle: UILabel!
    
    @IBOutlet weak var tfUserName: MDCOutlinedTextField!
    
    @IBAction func btnClose(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBAction func btnCancelAction(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBAction func btnUpdateAction(_ sender: UIButton) {
        
        if(isConnected){
            let alertLoading = Utils.LoadigAlert.showAlert(on: self)
            
            serviceManager.updateName(userId: userId, userName: self.tfUserName.text!){ result in
            
                switch result {
                    case .success(_):
                        alertLoading.dismiss(animated: true){
                            UserDefaults.standard.set(self.tfUserName.text!, forKey: "userName")
                            NotificationCenter.default.post(name: NSNotification.Name("UPDATE_NAME"), object:nil)
                            Utils.Snackbar.snackbarNoAction(message: "edit_name_success".localized(), bgColor: Constants.Colors.green!, duration: 5.0)
                        
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
            
            
        }else{
            dismiss(animated: true){
                Utils.Snackbar.snackbarWithAction(message: "no_internet_connection".localized(), bgColor: Constants.Colors.red!, titleAction: "close".localized(), duration: 5.0)
            }
        }
        
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tfUserName.delegate = self
        tfUserName.clearTextFieldError()

        // Do any additional setup after loading the view.
        
        initUI()

        // Do any additional setup after loading the view.
    }
    
    
    func initUI(){
        lbTitle.text = alertTitle
        Utils.TextField.config(tfUserName, label: NSLocalizedString("name".localized(), comment: ""), icon: "ic_user", iconTrailing: "xmark.circle.fill")
        tfUserName.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        tfUserName.text = userName
    }
    
    func validate() -> Bool{
        var valid = true
        let valName = tfUserName.text ?? ""
        
        if(valName.isEmpty || valName.count < 3){
            Utils.ValidTextField.error(textField: tfUserName, messageError: "invalid_name".localized())
            valid = false
        }
        return valid
    }
    

    
    @objc func textFieldDidChange(_ textField: MDCOutlinedTextField) {
        textField.applyValidStyle()
    }

}
