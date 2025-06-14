//
//  SettingsViewController.swift
//  Gil
//
//  Created by Antonio Banda  on 01/05/25.
//

import UIKit
import MaterialComponents
import Kingfisher

class SettingsViewController: KeyboardViewController, UITextFieldDelegate {
    
    let userName = UserDefaults.standard.string(forKey: "userName")
    let userEmail = UserDefaults.standard.string(forKey: "userEmail")
    let userProfile = UserDefaults.standard.string(forKey: "userProfile")
    
    @IBOutlet weak var ivPhoto: UIImageView!
    
    @IBOutlet weak var btnAddPhoto: UIButton!
    
    @IBOutlet weak var tfUserName: MDCOutlinedTextField!
    
    @IBOutlet weak var tfUserEmail: MDCOutlinedTextField!
    
    @IBOutlet weak var btnEditName: UIButton!
    
    
    @IBAction func closeSession(_ sender: UIButton) {
        UserDefaults.standard.removeObject(forKey: "isLogged")
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginNavigationController")

        
        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate,
           let window = sceneDelegate.window {
            
            UIView.transition(with: window, duration: 0.3, options: .transitionFlipFromLeft, animations: {
                window.rootViewController = loginVC
            }, completion: nil)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tfUserName.delegate = self
        tfUserEmail.delegate = self
        
        
        initUI()
        // Do any additional setup after loading the view.
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
       
        if(userProfile!.count > 0){
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
    
    
    
    
    
    @objc func textFieldDidChange(_ textField: MDCOutlinedTextField) {
        textField.applyValidStyle()
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
