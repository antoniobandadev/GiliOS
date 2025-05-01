//
//  KeyboardViewController.swift
//  Gil
//
//  Created by Antonio Banda  on 28/04/25.
//

import UIKit

class KeyboardViewController: UIViewController {

    private var originalY: CGFloat?

        override func viewDidLoad() {
            super.viewDidLoad()
            hideKeyboardOnTapAround()
        }

        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        }

        override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            NotificationCenter.default.removeObserver(self)
        }

        @objc func keyboardWillShow(notification: Notification) {
            guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }

            if originalY == nil {
                originalY = self.view.frame.origin.y
            }

            // Detect hidden field
            if let activeField = findFirstResponder(in: self.view) {
                let fieldFrame = activeField.convert(activeField.bounds, to: self.view)
                let overlap = fieldFrame.maxY - (self.view.frame.height - keyboardFrame.height)

                if overlap > 0 {
                    UIView.animate(withDuration: 0.3) {
                        self.view.frame.origin.y = (self.originalY ?? 0) - overlap - 20 // espacio extra
                    }
                }
            }
        }

        @objc func keyboardWillHide(notification: Notification) {
            guard let originalY = originalY else { return }

            UIView.animate(withDuration: 0.3) {
                self.view.frame.origin.y = originalY
            }
        }

        func hideKeyboardOnTapAround() {
            let tap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
            tap.cancelsTouchesInView = false
            self.view.addGestureRecognizer(tap)
        }

        @objc func hideKeyboard() {
            self.view.endEditing(true)
        }

        func findFirstResponder(in view: UIView) -> UIView? {
            for subview in view.subviews {
                if subview.isFirstResponder {
                    return subview
                } else if let responder = findFirstResponder(in: subview) {
                    return responder
                }
            }
            return nil
        }

}
