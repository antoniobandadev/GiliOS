//
//  SettingsViewController.swift
//  Gil
//
//  Created by Antonio Banda  on 01/05/25.
//

import UIKit
import MaterialComponents
import Kingfisher
import AVFoundation

class SettingsViewController: KeyboardViewController, UITextFieldDelegate, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    let userId = UserDefaults.standard.integer(forKey: "userId")
    var userName = UserDefaults.standard.string(forKey: "userName")
    let userEmail = UserDefaults.standard.string(forKey: "userEmail")
    let userProfile = UserDefaults.standard.string(forKey: "userProfile")
    let imagePicker = UIImagePickerController()
    let serviceManager = ServiceManager.shared
    let context = DataManager.shared.persistentContainer.viewContext
    
    @IBOutlet weak var ivPhoto: UIImageView!
    
    @IBOutlet weak var btnAddPhoto: UIButton!
    
    @IBOutlet weak var tfUserName: MDCOutlinedTextField!
    
    @IBOutlet weak var tfUserEmail: MDCOutlinedTextField!
    
    @IBOutlet weak var btnEditName: UIButton!
    
    
 
    @IBAction func btnAddPhotoAction(_ sender: UIButton) {
        
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true)
    }
    
    
    @IBAction func btnEditNameAction(_ sender: UIButton) {
        Utils.AlertSettingsUtils.showAlert(on: self, title: "edit_name".localized(), userId: userId, userName: userName!)
    }
    
    
    @IBAction func closeSession(_ sender: UIButton) {
        
        let deleteAlert = AlertCustomViewController(title: "logOut".localized(), message: "logout_message".localized())
        deleteAlert.modalPresentationStyle = .overFullScreen
        
        deleteAlert.addAction(title: "no".localized(), style: .filled(), color: Constants.Colors.red!){
           // deleteAlert.dismissAlert()
            deleteAlert.dismiss(animated: true)
        }
        
        deleteAlert.addAction(title: "yes".localized(), style: .filled(), color: Constants.Colors.green!){
            deleteAlert.dismiss(animated: true)
            _ = Utils.LoadigAlert.showAlert(on: self)
            
            UserDefaults.standard.removeObject(forKey: "isLogged")
            DataManager.shared.deleteAllEvents(context: self.context)
            DataManager.shared.deleteAllContacts(context: self.context)
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginNavigationController")

            
            if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate,
               let window = sceneDelegate.window {
                
                UIView.transition(with: window, duration: 0.3, options: .transitionFlipFromLeft, animations: {
                    window.rootViewController = loginVC
                }, completion: nil)
            }
        }
        
        present(deleteAlert, animated: true)
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tfUserName.delegate = self
        tfUserEmail.delegate = self
        
        
        initUI()
        print(userProfile ?? "No Profile")
        NotificationCenter.default.addObserver(self, selector:#selector(updateName), name: NSNotification.Name("UPDATE_NAME"), object:nil)
       
    }
    
    func initUI(){
        ivPhoto.layer.cornerRadius = ivPhoto.frame.width / 2
        ivPhoto.layer.masksToBounds = true
        ivPhoto.layer.borderWidth = 3
        ivPhoto.layer.borderColor = UIColor.white.cgColor
        
        tfUserName.isEnabled = false
        tfUserEmail.isEnabled = false
        
        tfUserName.text = userName
        tfUserEmail.text = userEmail
        
        Utils.TextField.config(tfUserName, label: NSLocalizedString("name".localized(), comment: ""), icon: "ic_user", iconTrailing: "xmark.circle.fill")
        Utils.TextField.config(tfUserEmail, label: NSLocalizedString("email".localized(), comment: ""), icon: "ic_email", iconTrailing: "xmark.circle.fill")
       
        if userProfile != nil{
            if(userProfile?.count ?? 0 > 0){
                let url = URL(string: userProfile!)
                let placeholder = UIImage(named: "ic_no_photo")
                
                ivPhoto.kf.setImage(
                    with: url,
                    placeholder: placeholder,
                    options: [
                        .transition(.fade(0.3)),
                        .cacheOriginalImage
                    ])
            }
        }
        
        /*if(userProfile!.count > 0){
            let sess = URLSession(configuration: .default)
            if let url = URL(string: userProfile!){
                let task = sess.dataTask(with: URLRequest(url: url)){
                    bytes, response, error in
                    if error == nil,
                       let b = bytes{
                        DispatchQueue.main.async{
                            self.ivPhoto.image = UIImage(data: b)
                        }
                    }
                }
                task.resume()
            }
        }*/
        
        
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if(isConnected){
            if let imgProfile = info[.editedImage] as? UIImage{
                ivPhoto.image = imgProfile
                serviceManager.uploadProfileImage(image: imgProfile, fileName: "profileImge.jpg", userId: userId){ result in
                    
                    switch result {
                        case .success(let userApi):
                            picker.dismiss(animated: true){
                                UserDefaults.standard.set(userApi.userProfile, forKey: "userProfile")
                                Utils.Snackbar.snackbarNoAction(message: "image_updated_success".localized(), bgColor: Constants.Colors.green!, duration: 3.0)
                                print("Nuevo URL: \(self.userProfile ?? "-")")
                            }
                        default:
                            picker.dismiss(animated: true){
                                Utils.Snackbar.snackbarNoAction(message: "server_error".localized(), bgColor: Constants.Colors.red!, duration: 5.0)
                            }
                    }
                    
                }
                //userProfile UIImageWriteToSavedPhotosAlbum(imgProfile, nil, nil, nil)
                
            }
        }else{
            picker.dismiss(animated: true){
                Utils.Snackbar.snackbarWithAction(message: "no_internet_connection".localized(), bgColor: Constants.Colors.red!, titleAction: "close".localized() , duration: 5.0)
            }
        }
        
        
        
        //let URL = info[.imageURL] ?? ""
        //print(URL)
        //UserDefaults.standard.set(URL, forKey: "userProfile")
        
    }
    
    @objc func updateName(){
        tfUserName.text = UserDefaults.standard.string(forKey: "userName")
        userName = UserDefaults.standard.string(forKey: "userName")
    }
    
    
    
    
    @objc func textFieldDidChange(_ textField: MDCOutlinedTextField) {
        textField.applyValidStyle()
    }
    

}
