//
//  AlertCustomViewController.swift
//  Gil
//
//  Created by Antonio Banda  on 20/06/25.
//

import UIKit

class AlertCustomViewController: UIViewController {
    
    private let containerView = UIView()
    private let titleLabel = UILabel()
    private let messageLabel = UILabel()
    private let stackView = UIStackView()
    
    init (title: String, message: String) {
        super.init(nibName: nil, bundle: nil)
        initUI()
        self.titleLabel.text = title
        self.messageLabel.text = message
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black.withAlphaComponent(0.5)
        animateAlertIn()
        
        // Do any additional setup after loading the view.
    }
    
    
    private func initUI(){
        containerView.backgroundColor = Constants.Colors.primaryLigth
        containerView.layer.cornerRadius = 20
        containerView.clipsToBounds = true
        containerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerView)
        
        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.widthAnchor.constraint(equalToConstant: 300)
           // containerView.heightAnchor.constraint(equalToConstant: 300)
        ])
            
        titleLabel.font = Constants.Fonts.fontBold18
        titleLabel.textAlignment = .center
        titleLabel.textColor = Constants.Colors.secondary
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20)
        ])
        
        
        messageLabel.font = Constants.Fonts.font16
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        messageLabel.translatesAutoresizingMaskIntoConstraints  = false
        messageLabel.textColor = Constants.Colors.accent
        containerView.addSubview(messageLabel)
        
        NSLayoutConstraint.activate([
            messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            messageLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            messageLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20)
        ])
        
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints  = false
        containerView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 20),
            stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -20),
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            //stackView.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    func addAction(title: String, style: UIButton.Configuration = .filled(), color:UIColor, action: @escaping () -> Void){
        
        let button = UIButton(type: .system)
        button.setAttributedTitle(NSAttributedString(string: title, attributes: [.font: Constants.Fonts.font16 ]), for: .normal)
        
        var config = style
        config.buttonSize = .medium
        config.baseBackgroundColor = color
        config.cornerStyle = .capsule
        button.configuration = config
        
        button.addAction(UIAction{
            _ in
            action()
            //self.dismissAlert()
        } , for: .touchUpInside)
        stackView.addArrangedSubview(button)
    }
    
    private func animateAlertIn() {
        containerView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        containerView.alpha = 0
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1.0, options: .curveEaseInOut, animations: {
            self.containerView.transform = .identity
            self.containerView.alpha = 1
        }, completion: nil)
    }
    
     func dismissAlert() {
        UIView.animate(withDuration: 0.2, animations: {
            self.containerView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            self.containerView.alpha = 0
        }) {_ in
            self.dismiss(animated: false)
        }
    }
    
    
    
    
    
    
}
