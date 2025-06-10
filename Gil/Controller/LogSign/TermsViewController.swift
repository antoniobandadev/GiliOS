//
//  TermsViewController.swift
//  Gil
//
//  Created by Antonio Banda  on 09/05/25.
//

import UIKit
import WebKit

class TermsViewController: UIViewController, WKNavigationDelegate {

    @IBOutlet weak var wkTermsCond: WKWebView!
    
    @IBOutlet weak var loadIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var lbTitle: UILabel!
    
    @IBAction func btCloseAction(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        wkTermsCond.navigationDelegate = self
        loadIndicator.style = .large
        loadIndicator.hidesWhenStopped = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadIndicator.startAnimating()
        
        let idioma = Locale.current.language.languageCode?.identifier
        let nameFile = (idioma == "es") ? "terms_es" : "terms_en"
        
        if let filePath = Bundle.main.path(forResource: nameFile, ofType: "html"){
            let localUrl = URL(fileURLWithPath: filePath)
            wkTermsCond.loadFileURL(localUrl, allowingReadAccessTo: localUrl)
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        loadIndicator.stopAnimating()
    }

}
