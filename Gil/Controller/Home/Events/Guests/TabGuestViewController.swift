//
//  TabGuestViewController.swift
//  Gil
//
//  Created by Antonio Banda  on 23/06/25.
//

import UIKit
import MaterialComponents

class TabGuestViewController: UIViewController {
    
    var eventRecived : EventEntity?

    @IBOutlet weak var lbTitle: UILabel!
    
    @IBAction func btnClose(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    var containerScheme: MDCContainerScheme = MDCContainerScheme()
    
    lazy var tabBar: MDCTabBarView = {
        let tabBar = MDCTabBarView()
        tabBar.items = self.tabBarItems
        tabBar.tabBarDelegate = self
        tabBar.translatesAutoresizingMaskIntoConstraints = false
        tabBar.contentAlignmentPoint = .init(x: 10.0, y: 0.5)
        return tabBar
    }()
    
    let myGuest = "my_guests".localized()
    let myFriends = "my_friends".localized()
    let myContacts = "my_contacts".localized()
    
    let itemTitles = ["my_guests".localized(), "my_friends".localized(), "my_contacts".localized()]
    
    lazy var tabBarItems: [UITabBarItem] = {
        return itemTitles.enumerated().map { (index, title) in
            return UITabBarItem(title: title, image: nil, tag: index)
        }
    }()
    
    var containerView: UIView!
    var viewControllers: [String: UIViewController] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
        applyThemingToTabBarView()
        applyFixForInjectedAppBar()
        
       // print(eventRecived ?? "No recibi valor")
        lbTitle.text = eventRecived?.eventName
    }
    
    private func initUI(){
        // Inicialización y configuración de containerView
        containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerView)
        view.addSubview(tabBar)
        
        
        //Constrains TabBar
        NSLayoutConstraint.activate([
            tabBar.topAnchor.constraint(equalTo: lbTitle.bottomAnchor),
            tabBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            tabBar.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            // tabBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            //
        ])
        
        // Constrains ContainerView
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: tabBar.bottomAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        
        
        // Init ViewControllers
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let myGuestVC = storyboard.instantiateViewController(withIdentifier: "MyGuest") as! GuestViewController
        myGuestVC.eventId = Int(eventRecived?.eventId ?? 0)
        let myGuestFVC = storyboard.instantiateViewController(withIdentifier: "MyGuestF") as! GuestFViewController
        myGuestFVC.eventId = Int(eventRecived?.eventId ?? 0)
        let myGuestCVC = storyboard.instantiateViewController(withIdentifier: "MyGuestC") as! GuestCViewController
        myGuestCVC.eventId = Int(eventRecived?.eventId ?? 0)
        
        /*viewControllers[myGuest] = storyboard.instantiateViewController(withIdentifier: "MyGuest")
        viewControllers[myFriends] = storyboard.instantiateViewController(withIdentifier: "MyGuestF")
        viewControllers[myContacts] = storyboard.instantiateViewController(withIdentifier: "MyGuestC")*/
        
        viewControllers[myGuest] = myGuestVC
        viewControllers[myFriends] = myGuestFVC
        viewControllers[myContacts] = myGuestCVC
       
        // Set Init View
        displaySelectedViewController(for: myGuest)
        
    }
    
    private func applyThemingToTabBarView() {
        tabBar.selectedItem = tabBarItems[0] //View Default
        tabBar.barTintColor = Constants.Colors.primary //background tabBar
        tabBar.setTitleColor(Constants.Colors.accent,for: .normal)
        tabBar.setTitleColor(Constants.Colors.secondary, for: .selected)
        tabBar.setImageTintColor(Constants.Colors.accent, for: .normal)
        tabBar.setImageTintColor(Constants.Colors.secondary, for: .selected)
        tabBar.setTitleFont(Constants.Fonts.font, for: .normal)
        tabBar.setTitleFont(Constants.Fonts.font, for: .selected)
        tabBar.selectionIndicatorStrokeColor = Constants.Colors.secondary
        /*tabBar.rippleColor = containerScheme.colorScheme.primaryColor.withAlphaComponent(0.1)
         tabBar.bottomDividerColor = containerScheme.colorScheme.onSurfaceColor.withAlphaComponent(0.12)*/
    }
    
    private func applyFixForInjectedAppBar() {
        // The injected AppBar has a bug where it will attempt to manipulate the Tab bar. To prevent
        // that bug, we need to inject a scroll view into the view hierarchy before the tab bar. The App
        // Bar will manipulate with that one instead.
        let bugFixScrollView = UIScrollView()
        bugFixScrollView.isUserInteractionEnabled = false
        bugFixScrollView.isHidden = true
        view.addSubview(bugFixScrollView)
    }
    
    private var currentViewController: UIViewController?

    private func displaySelectedViewController(for identifier: String) {
        guard let selectedViewController = viewControllers[identifier] else {
            return
        }

        // Quitar el view controller anterior correctamente
        if let current = currentViewController {
            current.willMove(toParent: nil)
            current.view.removeFromSuperview()
            current.removeFromParent()
        }

        // Agregar nuevo controller
        addChild(selectedViewController)
        selectedViewController.view.frame = containerView.bounds
        containerView.addSubview(selectedViewController.view)
        selectedViewController.didMove(toParent: self)

        currentViewController = selectedViewController
    }
    
    
}

extension TabGuestViewController: MDCTabBarViewDelegate {
    func tabBarView(_ tabBarView: MDCTabBarView, didSelect item: UITabBarItem) {
        print("Item \(item.title!) was selected.")
        displaySelectedViewController(for: item.title ?? myGuest)
    }
}
