//
//  HomeTabBarController.swift
//  Gil
//
//  Created by Antonio Banda  on 29/04/25.
//

import UIKit

/*class CustomTabBar: UITabBar {
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var sizeThatFits = super.sizeThatFits(size)
        sizeThatFits.height = 70 // altura personalizada
        return sizeThatFits
    }
}*/

class HomeTabBarController: UITabBarController {

    @IBOutlet weak var homeTabBar: UITabBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        homeTabBar.unselectedItemTintColor = Constants.Colors.accent
        
        
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
