//
//  TabContactsViewController.swift
//  Gil
//
//  Created by Antonio Banda  on 01/05/25.
//

import UIKit
import MaterialComponents

class TabContactsViewController: UIViewController {

    @IBOutlet weak var lbTitle: UILabel!
    
    var containerScheme: MDCContainerScheme = MDCContainerScheme()
    
    lazy var tabBar: MDCTabBarView = {
        let tabBar = MDCTabBarView()
        tabBar.items = self.tabBarItems
        tabBar.tabBarDelegate = self
        tabBar.translatesAutoresizingMaskIntoConstraints = false
        tabBar.contentAlignmentPoint = .init(x: 10.0, y: 0.5)
        return tabBar
    }()
    
    let myContacts = "my_friends".localized()
    let recivedRequest = "received_request".localized()
    let sentRequest = "sent_request".localized()
    
    let itemTitles = ["my_friends".localized(), "received_request".localized(), "sent_request".localized()]
    
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
        viewControllers[myContacts] = storyboard.instantiateViewController(withIdentifier: "MyContacts")
        viewControllers[recivedRequest] = storyboard.instantiateViewController(withIdentifier: "Received")
        viewControllers[sentRequest] = storyboard.instantiateViewController(withIdentifier: "Sent")
        
        // Set Init View
        displaySelectedViewController(for: myContacts)
        
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
    
    // Change View
    private func displaySelectedViewController(for identifier: String) {
        guard let selectedViewController = viewControllers[identifier] else {
            return
        }
        
        // Change view exists
        for subview in containerView.subviews {
            subview.removeFromSuperview()
        }
        
        // Add new controller view
        addChild(selectedViewController)
        selectedViewController.view.frame = containerView.bounds
        containerView.addSubview(selectedViewController.view)
        selectedViewController.didMove(toParent: self)
    }
    
    
}

extension TabContactsViewController: MDCTabBarViewDelegate {
    func tabBarView(_ tabBarView: MDCTabBarView, didSelect item: UITabBarItem) {
        print("Item \(item.title!) was selected.")
        displaySelectedViewController(for: item.title ?? myContacts)
    }
}


/*
 let itemIcons = [
 UIImage(systemName: "house.fill")?.withRenderingMode(.alwaysTemplate),
 UIImage(systemName: "star.fill")?.withRenderingMode(.alwaysTemplate)
 ]
 
 lazy var tabBarItems: [UITabBarItem] = {
 return zip(itemTitles, itemIcons)
 .enumerated()
 .map { (index, titleIconPair) in
 let (title, icon) = titleIconPair
 return UITabBarItem(title: title, image: icon, tag: index)
 }
 }()
 
 /*func tabBarView(_ tabBarView: MDCTabBarView, shouldSelect item: UITabBarItem) -> Bool {
  return (tabBar.items.firstIndex(of: item) != nil)
  // return tabBar.items.firstIndex(of: item) != 0
  }*/
 
 */
