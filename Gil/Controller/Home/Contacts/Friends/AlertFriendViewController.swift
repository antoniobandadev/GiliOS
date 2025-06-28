//
//  AlertFriendViewController.swift
//  Gil
//
//  Created by Antonio Banda  on 13/06/25.
//

import UIKit
import MaterialComponents

class AlertFriendViewController: KeyboardViewController, UITextFieldDelegate {
    
    let serviceManager = ServiceManager.shared
    
    var alertTitle: String?
    var confirmButtonTitle: String?
    var cancelButtonTitle: String? = nil
    var onConfirm: (() -> Void)?
    var onCancel: (() -> Void)?
    var message: String?
    var confirmCancel: Bool = false
    var myFriend: FriendDto?
    var newFriend: Bool = true
    var sentFriend: Bool = false
    var recivedFriend: Bool = false
    
    //Si vamos a cancelar amistad
    var successVal = "delete_friend_success".localized()
    var titleVal = "delete_friend".localized()
    var messageVal = "confirm_delete_friend".localized()
    var buttonVal = "delete".localized()
    
    
    @IBOutlet weak var lbFriendTitle: UILabel!
    
    @IBOutlet weak var lbFriendMessage: UILabel!

    @IBOutlet weak var tfFriendName: MDCOutlinedTextField!
    
    @IBOutlet weak var tfFriendEmail: MDCOutlinedTextField!
    
    @IBOutlet weak var btnNegative: UIButton!
    
    @IBOutlet weak var btnPositive: UIButton!
    
    @IBOutlet weak var alertContainer: UIView!
    
    @IBOutlet weak var btnCloseAlert: UIButton!
    
    
    @IBAction func btnClose(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    
    @IBAction func btnPositiveAction(_ sender: UIButton) {
        self.onConfirm?()
        if(recivedFriend){
            updateSolFriendsAcept()
           // self.dismiss(animated: true)
               // sendFriendRequest()
           
        }else if(newFriend){
            if(validate()){
                sendFriendRequest()
            }
        }else{
            if(confirmCancel){
                
            }else{
                Utils.AlertFriendsUtils.showConfirmFriendAlert(on: self, title: titleVal, message: messageVal ,
                onConfirm: {
                       
                        if(self.isConnected){
                            self.updateSolFriends()
                        }else{
                            self.dismiss(animated: true)
                        }
                    
                }, onCancel: {
                    self.dismiss(animated: true)
                    self.confirmCancel = false
                })
                confirmCancel = true
            }
        }
    }
    
    
    
    @IBAction func btnNegativeAction(_ sender: UIButton) {
        self.onCancel?()
        
        if(recivedFriend){
            Utils.AlertFriendsUtils.showConfirmFriendAlert(on: self, title: titleVal, message: messageVal ,
            onConfirm: {
                   
                    if(self.isConnected){
                        self.updateSolFriends()
                    }else{
                        self.dismiss(animated: true)
                    }
                
            }, onCancel: {
                self.dismiss(animated: true)
                self.confirmCancel = false
            })
            confirmCancel = true
            
        }else{
            dismiss(animated: true)
        }
       
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tfFriendName.delegate = self
        tfFriendEmail.delegate = self
        
        [tfFriendName, tfFriendEmail].forEach { $0?.clearTextFieldError() }

        initUI()
        
        
        // Do any additional setup after loading the view.
    }
    
    
    func initUI(){
        
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        alertContainer.layer.cornerRadius = 16
        alertContainer.clipsToBounds = true
        
        lbFriendTitle.text = alertTitle
        tfFriendName.text = myFriend?.contactName
        tfFriendEmail.text = myFriend?.contactEmail
        tfFriendName.isEnabled = false
        tfFriendEmail.isEnabled = false

        
        if let messageTitle = message {
            lbFriendMessage.isHidden = false
            lbFriendMessage.text = messageTitle
            tfFriendName.isHidden = true
            tfFriendEmail.isHidden = true
            btnCloseAlert.isHidden = true
        }else{
            lbFriendMessage.isHidden = true
        }

        // Configurar botón Cancelar
        if let cancelTitle = cancelButtonTitle {
            btnNegative.setTitle(cancelTitle, for: .normal)
            btnNegative.setTitleColor(.white, for: .normal)
            btnNegative.layer.cornerRadius = 8
            btnNegative.isHidden = false
        } else {
            btnNegative.isHidden = true
        }
        
        Utils.TextField.config(tfFriendName, label: NSLocalizedString("name".localized(), comment: ""), icon: "ic_user", iconTrailing: "xmark.circle.fill")
        tfFriendName.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        Utils.TextField.config(tfFriendEmail, label: NSLocalizedString("email".localized(), comment: ""), icon: "ic_email", iconTrailing: "xmark.circle.fill")
        tfFriendEmail.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        if(newFriend){
            tfFriendName.isHidden = true
            tfFriendEmail.isEnabled = true
            // Configurar botón Confirmar
            btnPositive.setTitle(confirmButtonTitle, for: .normal)
            btnPositive.layer.cornerRadius = 16
            btnPositive.backgroundColor = Constants.Colors.green
        }else{
            // Configurar botón Confirmar
            btnPositive.setTitle(confirmButtonTitle, for: .normal)
            btnPositive.layer.cornerRadius = 16
            btnPositive.backgroundColor = Constants.Colors.red
        }
        
        if(sentFriend){
             successVal = "friend_request_cancelled_success".localized()
             titleVal = "cancel_request".localized()
             messageVal = "confirm_cancel_request".localized()
             buttonVal = "cancel".localized()
             btnPositive.setTitle(buttonVal, for: .normal)
        }
        
        if(recivedFriend){
             successVal = "friend_request_rejected_success".localized()
             titleVal = "reject_friend".localized()
             messageVal = "confirm_reject_friend".localized()
             buttonVal = "accept".localized()
             cancelButtonTitle = "reject".localized()
             btnPositive.setTitle(buttonVal, for: .normal)
             btnPositive.layer.cornerRadius = 16
             btnPositive.backgroundColor = Constants.Colors.green
             btnNegative.isHidden = false
             btnNegative.setTitle(cancelButtonTitle, for: .normal)
        }
        
        if let currentPositiveTitle = btnPositive.title(for: .normal) {
            let attributedTitle = NSAttributedString(
                string: currentPositiveTitle,
                attributes: [
                    .font: Constants.Fonts.font16
                ]
            )
            btnPositive.setAttributedTitle(attributedTitle, for: .normal)
        }
        
        if let currentNegativeTitle = btnNegative.title(for: .normal) {
            let attributedTitle = NSAttributedString(
                string: currentNegativeTitle,
                attributes: [
                    .font: Constants.Fonts.font16
                ]
            )
            btnNegative.setAttributedTitle(attributedTitle, for: .normal)
        }
        
        
    }
    
    func sendFriendRequest(){
        let alert = Utils.LoadigAlert.showAlert(on: self)
        let userId = UserDefaults.standard.integer(forKey: "userId")
        let friend: FriendDto = FriendDto(contactId: nil, userId: userId, contactName:nil, contactEmail: tfFriendEmail.text!, contactStatus: nil, contactType: nil)
        serviceManager.newFriends(friend: friend) { result in
           
            switch result {
                
            case .success(_):
                alert.dismiss(animated: true){
                    Utils.Snackbar.snackbarNoAction(message: "sol_friend_send".localized(), bgColor: Constants.Colors.green!, duration: 3.0)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        self.dismiss(animated: true)
                    }
                    
                }
            
            case .failure(let error):
                alert.dismiss(animated: true){
                    if let apiError = error as? APIError {
                        switch apiError {
                        case .notFound:
                            Utils.ValidTextField.error(textField: self.tfFriendEmail, messageError: "sol_no_friend_found".localized())
                        case .unauthorized:
                            Utils.ValidTextField.error(textField: self.tfFriendEmail, messageError: "sol_friend_pending".localized())
                        case .process:
                            Utils.ValidTextField.error(textField: self.tfFriendEmail, messageError: "sol_friend_pending".localized())
                        default:
                            alert.dismiss(animated: true){
                                Utils.Snackbar.snackbarNoAction(message: "server_error".localized(), bgColor: Constants.Colors.red!, duration: 5.0)
                            }
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
    
    func validate() -> Bool{
        var valid = true
        let valEmail = tfFriendEmail.text ?? ""
        
        if (valEmail.isEmpty) {
            Utils.ValidTextField.error(textField: tfFriendEmail, messageError: "not_valid_email".localized())
            valid = false
        }
        
        if (!valEmail.isValidEmail()){
            Utils.ValidTextField.error(textField: tfFriendEmail, messageError: "not_valid_email".localized())
            valid = false
        }
        return valid
    }
    
    func updateSolFriends(){
        let alertLoading = Utils.LoadigAlert.showAlert(on: self)
        let solFriend = SolFriendDto(
            userId: myFriend?.userId, friendId: myFriend?.contactId, friendStatus: "C"
            )
        
        serviceManager.solFriends(solFriend: solFriend){ result in
            switch result {
                
            case .success(_):
                alertLoading.dismiss(animated: true){
                    
                    Utils.Snackbar.snackbarNoAction(message: self.successVal, bgColor: Constants.Colors.green!, duration: 3.0)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        self.dismiss(animated: true){
                            self.dismiss(animated: true)
                        }
                    }
                    NotificationCenter.default.post(name: NSNotification.Name("DELETE_FRIEND"), object:nil)
                }
            
            case .failure(let error):
                alertLoading.dismiss(animated: true){
                    if let apiError = error as? APIError {
                        switch apiError {
                        default:
                            
                            Utils.Snackbar.snackbarNoAction(message: "server_error".localized(), bgColor: Constants.Colors.red!, duration: 5.0)
                            
                        }
                    } else {
                        Utils.Snackbar.snackbarNoAction(message: "server_error".localized(), bgColor: Constants.Colors.red!, duration: 5.0)
                        print(error.localizedDescription)
                    }
                }
            }
        }
    }
    
    func updateSolFriendsAcept(){
        let alertLoading = Utils.LoadigAlert.showAlert(on: self)
        let solFriend = SolFriendDto(
            userId: myFriend?.userId, friendId: myFriend?.contactId, friendStatus: "A"
            )
        
        serviceManager.solFriends(solFriend: solFriend){ result in
            switch result {
                
            case .success(_):
                alertLoading.dismiss(animated: true){
                    
                    Utils.Snackbar.snackbarNoAction(message: self.successVal, bgColor: Constants.Colors.green!, duration: 3.0)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        self.dismiss(animated: true){
                            self.dismiss(animated: true)
                        }
                    }
                    NotificationCenter.default.post(name: NSNotification.Name("DELETE_FRIEND"), object:nil)
                }
            
            case .failure(let error):
                alertLoading.dismiss(animated: true){
                    if let apiError = error as? APIError {
                        switch apiError {
                        default:
                            
                            Utils.Snackbar.snackbarNoAction(message: "server_error".localized(), bgColor: Constants.Colors.red!, duration: 5.0)
                            
                        }
                    } else {
                        Utils.Snackbar.snackbarNoAction(message: "server_error".localized(), bgColor: Constants.Colors.red!, duration: 5.0)
                        print(error.localizedDescription)
                    }
                }
            }
        }
    }
    
    
    
    @objc func textFieldDidChange(_ textField: MDCOutlinedTextField) {
        textField.applyValidStyle()
    }
    
    
    
}
