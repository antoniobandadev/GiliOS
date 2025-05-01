//
//  EventsViewController.swift
//  Gil
//
//  Created by Antonio Banda  on 29/04/25.
//

import UIKit

class EventsViewController: UIViewController {

    @IBOutlet weak var tbItemEvent: UITabBarItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tbItemEvent.imageInsets = UIEdgeInsets(top: 4, left: 0, bottom: -4, right: 0)
        // Do any additional setup after loading the view.
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
