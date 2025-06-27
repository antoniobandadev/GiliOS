//
//  AlertGuestViewController.swift
//  Gil
//
//  Created by Antonio Banda  on 23/06/25.
//

import UIKit
import MaterialComponents

class AlertGuestViewController: KeyboardViewController, UITextFieldDelegate {
    
    let serviceManager = ServiceManager.shared
    
    var alertTitle: String?
    var confirmButtonTitle: String?
    var onConfirm: (() -> Void)?
    var onCancel: (() -> Void)?
    var myFriend: FriendDto?
    var myContact: ContactDto?
    var guestsType: Int?
    var eventId: Int?
    
    @IBOutlet weak var lbFriendTitle: UILabel!
    
    @IBOutlet weak var tfInviteName: MDCOutlinedTextField!
    
    @IBOutlet weak var tfFriendName: MDCOutlinedTextField!
    
    @IBOutlet weak var tfFriendEmail: MDCOutlinedTextField!
    
    @IBOutlet weak var btnPositive: UIButton!
    
    @IBOutlet weak var alertContainer: UIView!
    
    @IBOutlet weak var btnCloseAlert: UIButton!
    
    
    @IBAction func btnClose(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    
    @IBAction func btnPositiveAction(_ sender: UIButton) {
        self.onConfirm?()
        if(validate()){
            sendInvite(){
                NotificationCenter.default.post(name: NSNotification.Name("UPDATE_GUESTS_FRIENDS"), object:nil)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        [tfFriendName, tfFriendEmail, tfInviteName].forEach { $0?.clearTextFieldError() }
        
        tfFriendName.delegate = self
        tfFriendEmail.delegate = self
        tfInviteName.delegate = self

        if guestsType == 0{
            initUIC()
        }else{
            initUIF()
        }
                
        // Do any additional setup after loading the view.
    }
    
    
    func initUIF(){
        
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        alertContainer.layer.cornerRadius = 16
        alertContainer.clipsToBounds = true
        
        lbFriendTitle.text = alertTitle
        tfInviteName.text = myFriend?.contactName
        tfFriendName.text = myFriend?.contactName
        tfFriendEmail.text = myFriend?.contactEmail
        
        tfFriendName.isEnabled = false
        tfFriendEmail.isEnabled = false
       
        Utils.TextField.config(tfInviteName, label: NSLocalizedString("invitation_name_label".localized(), comment: ""), icon: "ic_invitation_qr", iconTrailing: "xmark.circle.fill")
        tfInviteName.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        Utils.TextField.config(tfFriendName, label: NSLocalizedString("name".localized(), comment: ""), icon: "ic_user", iconTrailing: "xmark.circle.fill")
        tfFriendName.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        Utils.TextField.config(tfFriendEmail, label: NSLocalizedString("email".localized(), comment: ""), icon: "ic_email", iconTrailing: "xmark.circle.fill")
        tfFriendEmail.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        if let currentPositiveTitle = btnPositive.title(for: .normal) {
            let attributedTitle = NSAttributedString(
                string: currentPositiveTitle,
                attributes: [
                    .font: Constants.Fonts.font16
                ]
            )
            btnPositive.setAttributedTitle(attributedTitle, for: .normal)
        }
        
    }
    
    func initUIC(){
        
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        alertContainer.layer.cornerRadius = 16
        alertContainer.clipsToBounds = true
        
        lbFriendTitle.text = alertTitle
        tfInviteName.text = myContact?.contactName
        tfFriendName.text = myContact?.contactName
        tfFriendEmail.text = myContact?.contactEmail
        
        tfFriendName.isEnabled = false
        tfFriendEmail.isEnabled = false
       
        Utils.TextField.config(tfInviteName, label: NSLocalizedString("invitation_name_label".localized(), comment: ""), icon: "ic_invitation_qr", iconTrailing: "xmark.circle.fill")
        tfInviteName.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        Utils.TextField.config(tfFriendName, label: NSLocalizedString("name".localized(), comment: ""), icon: "ic_user", iconTrailing: "xmark.circle.fill")
        tfFriendName.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        Utils.TextField.config(tfFriendEmail, label: NSLocalizedString("email".localized(), comment: ""), icon: "ic_email", iconTrailing: "xmark.circle.fill")
        tfFriendEmail.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        if let currentPositiveTitle = btnPositive.title(for: .normal) {
            let attributedTitle = NSAttributedString(
                string: currentPositiveTitle,
                attributes: [
                    .font: Constants.Fonts.font16
                ]
            )
            btnPositive.setAttributedTitle(attributedTitle, for: .normal)
        }
        
    }
    
    func sendInvite(completion: @escaping () -> Void){
        let alert = Utils.LoadigAlert.showAlert(on: self)
        let userId = UserDefaults.standard.integer(forKey: "userId")
        let guestInvNameVal = tfInviteName.text ?? ""
        
        let idioma = Locale.current.language.languageCode?.identifier
        let userLanguage = (idioma == "es") ? "es" : "en"
        
        let myInvite: InviteDto
        
        if guestsType == 1 {
             myInvite = InviteDto(eventId: eventId!, guestInvName: guestInvNameVal , guestsType: 1, contactId: nil, userId: myFriend?.contactId , userSendId: userId, userLanguage: userLanguage)
        }else{
            myInvite = InviteDto(eventId: eventId!, guestInvName: guestInvNameVal , guestsType: 0, contactId: myContact?.contactId, userId: nil , userSendId: userId, userLanguage: userLanguage)
        }
       
        serviceManager.newGuest(invite: myInvite){ result in
           
            switch result {
                
                case .success(_):
                    alert.dismiss(animated: true){
                        Utils.Snackbar.snackbarNoAction(message: "send_invitation_success".localized(), bgColor: Constants.Colors.green!, duration: 3.0)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            self.dismiss(animated: true){
                                completion()
                            }
                        }
                    }
                
                case .failure(let error):
                    alert.dismiss(animated: true){
                        if let apiError = error as? APIError {
                            
                            alert.dismiss(animated: true){
                                self.dismiss(animated: true){
                                    Utils.Snackbar.snackbarNoAction(message: "server_error".localized(), bgColor: Constants.Colors.red!, duration: 5.0)
                                }
                            }
                            
                        } else {
                            alert.dismiss(animated: true){
                                self.dismiss(animated: true){
                                    Utils.Snackbar.snackbarNoAction(message: "server_error".localized(), bgColor: Constants.Colors.red!, duration: 5.0)
                                    print(error.localizedDescription)
                                }
                            }
                        }
                    }
            }
        }
    }
    
    func validate() -> Bool{
        var valid = true
        let valInviteName = tfInviteName.text ?? ""
        
        if (valInviteName.isEmpty || valInviteName.count < 3) {
            Utils.ValidTextField.error(textField: tfInviteName, messageError: "required_field".localized())
            valid = false
        }
        
        return valid
    }
    
    
    @objc func textFieldDidChange(_ textField: MDCOutlinedTextField) {
        textField.applyValidStyle()
    }
    
    
    
}
