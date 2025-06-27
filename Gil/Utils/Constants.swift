//
//  Constants.swift
//  Gil
//
//  Created by Antonio Banda  on 27/04/25.
//

import UIKit

struct Constants {
    struct Colors {
        static let primary = UIColor(named: "primary")
        static let secondary = UIColor(named: "secondary")
        static let accent = UIColor(named: "accent")
        static let red = UIColor(named: "red")
        static let green = UIColor(named: "green")
        static let greenLigth = UIColor(named: "greenLight")
        static let primaryLigth = UIColor(named: "primaryLight")
        static let gray = UIColor(named: "gray")
        static let grayDark = UIColor(named: "grayDark")
    }
    
    struct Fonts {
        static let font = UIFont(name: "parkinsans", size: 17)!
        static let font16 = UIFont(name: "parkinsans", size: 16)!
        static let fontMini = UIFont(name: "parkinsans", size: 13)!
        static let fontBold = UIFont(name: "parkinsans-bold", size: 17)!
        static let fontBold18 = UIFont(name: "parkinsans-bold", size: 18)!
        static let fontTitle = UIFont(name: "parkinsans", size: 24)!
        static let fontTitleBold = UIFont(name: "parkinsans-bold", size: 24)!
       
    }
    
    struct URLs {
        static let eventApi = "https://app.fipros.com/api/events/"
    }
    
    

   /* struct Identifiers {
        static let homeVC = "Home"
        static let sendVC = "Send"
        static let historyVC = "His"
    }*/

    
}
