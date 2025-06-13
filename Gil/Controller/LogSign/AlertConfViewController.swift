//
//  AlertConfViewController.swift
//  Gil
//
//  Created by Antonio Banda  on 09/06/25.
//

import UIKit

class AlertConfViewController: UIViewController {
    @IBOutlet weak var lbTitle: UILabel!
    
    @IBOutlet weak var lbMessage: UILabel!
    
    @IBOutlet weak var btnCancel: UIButton!
    
    @IBAction func btnCancelAction(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var btnConfirm: UIButton!
    
    @IBAction func btnConfirmAction(_ sender: UIButton) {
        dismiss(animated: true) {
            self.onConfirm?()
        }
    }
    
    @IBOutlet weak var alertContainerView: UIView!
    
    
   
    var alertTitle: String?
    var alertMessage: String?
    var confirmButtonTitle: String?
    var cancelButtonTitle: String? = nil
    var confirmButtonColor: UIColor = .systemBlue
    var cancelButtonColor: UIColor = .systemGray

    var onConfirm: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        alertContainerView.layer.cornerRadius = 16
        alertContainerView.clipsToBounds = true

        lbTitle.text = alertTitle
        lbMessage.text = alertMessage

        // Configurar botón Confirmar
        btnConfirm.setTitle(confirmButtonTitle, for: .normal)
        btnConfirm.setTitleColor(.white, for: .normal)
       // btnConfirm.backgroundColor = confirmButtonColor
        btnConfirm.layer.cornerRadius = 8

        // Configurar botón Cancelar (opcional)
        if let cancelTitle = cancelButtonTitle {
            btnCancel.setTitle(cancelTitle, for: .normal)
            btnCancel.setTitleColor(.white, for: .normal)
            //btnCancel.backgroundColor = cancelButtonColor
            btnCancel.layer.cornerRadius = 8
            btnCancel.isHidden = false
        } else {
            btnCancel.isHidden = true
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
