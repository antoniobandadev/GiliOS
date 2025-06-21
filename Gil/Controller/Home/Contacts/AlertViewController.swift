//
//  AlertViewController.swift
//  Gil
//
//  Created by Antonio Banda  on 10/06/25.
//

import UIKit
import MaterialComponents

class AlertViewController: KeyboardViewController, UITextFieldDelegate {
    
    let serviceManager = ServiceManager.shared
    let context = DataManager.shared.persistentContainer.viewContext
    let attributes: [NSAttributedString.Key: Any] = [.font: Constants.Fonts.font16]
    
    var alertTitle: String?
    var confirmButtonTitle: String?
    var cancelButtonTitle: String? = nil
    var onConfirm: (() -> Void)?
    var onCancel: (() -> Void)?
    var message: String?
    var newContact: Bool = true
    var myContact: ContactEntity?
    
    var confirmCancel: Bool = false
    

    @IBOutlet weak var lbTitle: UILabel!
    
    @IBOutlet weak var etValue1: MDCOutlinedTextField!
    
    @IBOutlet weak var etValue2: MDCOutlinedTextField!
    
    @IBOutlet weak var lbMessage: UILabel!
    
    @IBOutlet weak var btnNegative: UIButton!
    
    @IBOutlet weak var btnPositive: UIButton!
    
    @IBOutlet weak var alertContainer: UIView!
    
    @IBOutlet weak var btnCloseAlert: UIButton!
    
    
    @IBAction func btnClose(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBAction func btnOnCancel(_ sender: UIButton) {
        self.onCancel?()
        
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
        
        
        
        if(confirmCancel){
            
        }else{
            Utils.AlertCustomUtils.showConfirmCustomAlert(on: self, title: "delete_contact".localized(), message: "confirm_delete_contact".localized() ,
            onConfirm: {
                self.dismiss(animated: true)
               
                   // let alertLoading = Utils.LoadigAlert.showAlert(on: self)
                    if(self.isConnected){
                        self.updateContact(name: self.etValue1.text ?? "", email: self.etValue2.text ?? "", status: "C", contact: self.myContact!)
                    }else{
                        self.updateContactDB(name: self.etValue1.text ?? "", email: self.etValue2.text ?? "", status: "C", contact: self.myContact!)
                    }
                
                //alertLoading.dismiss(animated: true)
            }, onCancel: {
                self.dismiss(animated: true)
                self.confirmCancel = false
            })
            confirmCancel = true
        }
    }
    
    @IBAction func btnOnConfirm(_ sender: UIButton) {
        self.onConfirm?()
        if(validate()){
            if(newContact){
                if(isConnected){
                    saveContact(name: self.etValue1.text ?? "", email: self.etValue2.text ?? "", status:"A")
                }else{
                   saveContactDB(name: self.etValue1.text ?? "", email: self.etValue2.text ?? "", status:"P")
                }
            }else{
                if(isConnected){
                    updateContact(name: self.etValue1.text ?? "", email: self.etValue2.text ?? "", status: "A", contact: myContact!)
                }else{
                    updateContactDB(name: self.etValue1.text ?? "", email: self.etValue2.text ?? "", status: "A", contact: myContact!)
                }
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        etValue1.delegate = self
        etValue2.delegate = self
        
        [etValue1, etValue2].forEach { $0?.clearTextFieldError() }
        
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        alertContainer.layer.cornerRadius = 16
        alertContainer.clipsToBounds = true
        
        lbTitle.text = alertTitle
        etValue1.text = myContact?.contactName
        etValue2.text = myContact?.contactEmail

        // Configurar botón Confirmar
        let attributedTitle = NSAttributedString(string: confirmButtonTitle!, attributes: attributes)
        btnPositive.setAttributedTitle(attributedTitle, for: .normal)
        //btnPositive.setTitle(confirmButtonTitle, for: .normal)
        btnPositive.setTitleColor(.white, for: .normal)
        //btnPositive.backgroundColor = confirmButtonColor
        btnPositive.layer.cornerRadius = 8
        
        if let messageTitle = message {
            lbMessage.isHidden = false
            lbMessage.text = messageTitle
            etValue1.isHidden = true
            etValue2.isHidden = true
            btnCloseAlert.isHidden = true
        }else{
            lbMessage.isHidden = true
        }

        // Configurar botón Cancelar
        if let cancelTitle = cancelButtonTitle {
            let attributedTitle = NSAttributedString(string: cancelTitle, attributes: attributes)
            btnNegative.setAttributedTitle(attributedTitle, for: .normal)
            //btnNegative.setTitle(cancelTitle, for: .normal)
            btnNegative.setTitleColor(.white, for: .normal)
            btnNegative.layer.cornerRadius = 8
            btnNegative.isHidden = false
        } else {
            btnNegative.isHidden = true
        }
        
        initUI()

        // Do any additional setup after loading the view.
    }
    
    
    func initUI(){
        Utils.TextField.config(etValue1, label: NSLocalizedString("name".localized(), comment: ""), icon: "ic_user", iconTrailing: "xmark.circle.fill")
        etValue1.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        Utils.TextField.config(etValue2, label: NSLocalizedString("email".localized(), comment: ""), icon: "ic_email", iconTrailing: "xmark.circle.fill")
        etValue2.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    func validate() -> Bool{
        var valid = true
        let valName = etValue1.text ?? ""
        let valEmail = etValue2.text ?? ""
        
        if(valName.isEmpty || valName.count < 3){
            Utils.ValidTextField.error(textField: etValue1, messageError: "invalid_name".localized())
            valid = false
        }
        
        if (valEmail.isEmpty) {
            Utils.ValidTextField.error(textField: etValue2, messageError: "not_valid_email".localized())
            valid = false
        }
        
        
        if (!valEmail.isValidEmail()){
            Utils.ValidTextField.error(textField: etValue2, messageError: "not_valid_email".localized())
            valid = false
        }
        return valid
    }
    
    
    //MARK: SAVE
    func saveContact(name: String, email: String, status: String) {
        let alertLoading = Utils.LoadigAlert.showAlert(on: self)

        // Crear una nueva instancia de Contact
        let newContact = ContactEntity(context: context)
            newContact.contactId = UUID().uuidString
            newContact.contactName = name
            newContact.contactEmail = email
            newContact.contactStatus = status
            newContact.contactType = "C"
            let userId = UserDefaults.standard.integer(forKey: "userId")
            newContact.userId = Int16(userId)
            newContact.contactSync = 1
        
        let newContactDto = ContactDto(entity: newContact)

        do {
            try context.save()
            serviceManager.createContact(contact: newContactDto)  { result in
                switch result {
                case .success(_):
                    alertLoading.dismiss(animated: true){
                        Utils.Snackbar.snackbarNoAction(message: "contact_save_successful".localized(), bgColor: Constants.Colors.green!, duration: 5.0)
                    
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            self.dismiss(animated: true)
                        }
                        print("Contacto guardado exitosamente.")
                        
                        NotificationCenter.default.post(name: NSNotification.Name("ADD_CONTACT"), object:nil)
                    }
                    default:
                    alertLoading.dismiss(animated: true){
                        Utils.Snackbar.snackbarNoAction(message: "server_error".localized(), bgColor: Constants.Colors.red!, duration: 5.0)
                    }
                }
            }
           
        } catch {
            alertLoading.dismiss(animated: true){
                Utils.Snackbar.snackbarNoAction(message: "server_error".localized(), bgColor: Constants.Colors.red!, duration: 5.0)
            }
            print("Error al guardar contacto: \(error.localizedDescription)")
        }
    }
    
    func saveContactDB(name: String, email: String, status: String) {
        let alertLoading = Utils.LoadigAlert.showAlert(on: self)

        // Crear una nueva instancia de Contact
        let newContact = ContactEntity(context: context)
            newContact.contactId = UUID().uuidString
            newContact.contactName = name
            newContact.contactEmail = email
            newContact.contactStatus = status
            newContact.contactType = "C"
            let userId = UserDefaults.standard.integer(forKey: "userId")
            newContact.userId = Int16(userId)
            newContact.contactSync = 0

        do {
            try context.save()
            alertLoading.dismiss(animated: true){
                Utils.Snackbar.snackbarNoAction(message: "contact_save_successful".localized(), bgColor: Constants.Colors.green!, duration: 5.0)
            
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.dismiss(animated: true)
                }
                print("Contacto guardado exitosamente.")
                
                NotificationCenter.default.post(name: NSNotification.Name("ADD_CONTACT"), object:nil)
            }
        } catch {
            alertLoading.dismiss(animated: true){
                Utils.Snackbar.snackbarNoAction(message: "server_error".localized(), bgColor: Constants.Colors.red!, duration: 5.0)
            }
            print("Error al guardar contacto: \(error.localizedDescription)")
        }
    }
    
    // MARK: UPDATE
    func updateContact(name: String, email: String, status: String, contact: ContactEntity) {
        let alertLoading = Utils.LoadigAlert.showAlert(on: self)

        contact.contactName = name
        contact.contactEmail = email
        contact.contactStatus = status
        contact.contactSync = 1
        
        let contactDto = ContactDto(entity: contact)

        do {
            try context.save()
            serviceManager.updateContact(contact: contactDto)  { result in
                switch result {
                case .success(_):
                    alertLoading.dismiss(animated: true){
                        
                        if(status == "C"){
                            Utils.Snackbar.snackbarNoAction(message: "contact_delete_successful".localized(), bgColor: Constants.Colors.green!, duration: 5.0)
                        }else{
                            Utils.Snackbar.snackbarNoAction(message: "contact_update_successful".localized(), bgColor: Constants.Colors.green!, duration: 5.0)
                        }
                    
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            self.dismiss(animated: true){
                                self.dismiss(animated: true)
                            }
                        }
                        print("Contacto actualizado exitosamente.")
                        
                        NotificationCenter.default.post(name: NSNotification.Name("ADD_CONTACT"), object:nil)
                    }
                    default:
                    alertLoading.dismiss(animated: true){
                        Utils.Snackbar.snackbarNoAction(message: "server_error".localized(), bgColor: Constants.Colors.red!, duration: 5.0)
                    }
                }
            }
           
        } catch {
            alertLoading.dismiss(animated: true){
                Utils.Snackbar.snackbarNoAction(message: "server_error".localized(), bgColor: Constants.Colors.red!, duration: 5.0)
            }
            print("Error al guardar contacto: \(error.localizedDescription)")
        }
    }
    
    func updateContactDB(name: String, email: String, status: String, contact: ContactEntity) {
        let alertLoading = Utils.LoadigAlert.showAlert(on: self)

        // Crear una nueva instancia de Contact
        
        contact.contactName = name
        contact.contactEmail = email
        contact.contactStatus = status
        contact.contactSync = 0

        do {
            try context.save()
            alertLoading.dismiss(animated: true){
                if(status == "C"){
                    Utils.Snackbar.snackbarNoAction(message: "contact_delete_successful".localized(), bgColor: Constants.Colors.green!, duration: 5.0)
                }else{
                    Utils.Snackbar.snackbarNoAction(message: "contact_update_successful".localized(), bgColor: Constants.Colors.green!, duration: 5.0)
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.dismiss(animated: true){
                        self.dismiss(animated: true)
                    }
                }
                print("Contacto actualizado exitosamente.")
                
                NotificationCenter.default.post(name: NSNotification.Name("ADD_CONTACT"), object:nil)
            }
        } catch {
            alertLoading.dismiss(animated: true){
                Utils.Snackbar.snackbarNoAction(message: "server_error".localized(), bgColor: Constants.Colors.red!, duration: 5.0)
            }
            print("Error al guardar contacto: \(error.localizedDescription)")
        }
    }
    
    
    
    
    
    
    
    @objc func textFieldDidChange(_ textField: MDCOutlinedTextField) {
        textField.applyValidStyle()
    }

}
