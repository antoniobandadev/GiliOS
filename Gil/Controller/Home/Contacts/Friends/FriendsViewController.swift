//
//  MyContactsViewController.swift
//  Gil
//
//  Created by Antonio Banda  on 01/05/25.
//

import UIKit
import MaterialComponents
import SkeletonView

class FriendsViewController: KeyboardViewController , SkeletonTableViewDataSource, UITableViewDelegate , UITextFieldDelegate {
    
    let serviceManager = ServiceManager.shared
    
    var friends = [FriendDto]()
    var friendsPendings = [FriendDto]()
    var searchFriends = [FriendDto]()
    
    let fastShimmer = SkeletonAnimationBuilder()
           .makeSlidingAnimation(withDirection: .leftRight, duration: 0.5)
    let skeletonColor = SkeletonGradient(baseColor: UIColor.darkGray)
    
    let floatingButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = Constants.Colors.secondary
        button.setTitle("+", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 30)
        button.tintColor = .white
        button.layer.cornerRadius = 20
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.3
        button.layer.shadowOffset = CGSize(width: 0, height: 3)
        button.layer.shadowRadius = 3
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let friendsLabel: UILabel = {
        let label = UILabel()
        label.text = "no_friends_found".localized()
        label.textAlignment = .center
        label.textColor = .gray
        label.font = Constants.Fonts.fontBold
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        return label
    }()
    

    @IBOutlet weak var tfFriendSearch: MDCOutlinedTextField!
    
    @IBOutlet weak var tvFriends: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tvFriends.dataSource = self
        tvFriends.delegate = self
        tfFriendSearch.delegate = self

        tvFriends.isSkeletonable = true

        // Do any additional setup after loading the view.
        initUI()
        //Observo los cambios de internet
        self.tvFriends.showAnimatedGradientSkeleton(usingGradient: skeletonColor,animation: fastShimmer, transition: .none)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.observeConnectionChanges { [weak self] isConnected in
                self?.updateGetFriends()
            }
        }
        
        
        
        NotificationCenter.default.addObserver(self, selector:#selector(getFriends), name: NSNotification.Name("DELETE_FRIEND"), object:nil)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //Observo los cambios de internet
        self.tvFriends.showAnimatedGradientSkeleton(usingGradient: skeletonColor,animation: fastShimmer, transition: .none)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.updateGetFriends()
        }
    }
    
    
    
    
    func initUI(){
        Utils.TextField.config(tfFriendSearch, label: NSLocalizedString("search".localized(), comment: ""), icon: "ic_search_color", iconTrailing: "xmark.circle.fill")
        
        view.addSubview(floatingButton)

        NSLayoutConstraint.activate([
           floatingButton.widthAnchor.constraint(equalToConstant: 60),
           floatingButton.heightAnchor.constraint(equalToConstant: 60),
           floatingButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
           floatingButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])

        floatingButton.addTarget(self, action: #selector(floatingButtonTapped), for: .touchUpInside)
        
        view.addSubview(friendsLabel)

        NSLayoutConstraint.activate([
            friendsLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            friendsLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func numberOfSections(in tableView: UITableView) -> Int {
       // #warning Incomplete implementation, return the number of sections
       return 1
   }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       // #warning Incomplete implementation, return the number of rows
        return searchFriends.count
        //return isLoading ? 5 : data.count
        
   }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       //performSegue(withIdentifier: menuOptions[indexPath.row].segue, sender: nil)
       //if let cell = tableView.cellForRow(at: indexPath) as? CustomTableViewCell {
        let friend = searchFriends[indexPath.row]
        Utils.AlertFriendsUtils.showAlert(on: self, title: "delete_friend".localized(), friend: friend)
      //  Utils.AlertCustomUtils.showEditCustomAlert(on: self, title: "update_contact".localized(), newContact:false, contact: contact)
           // cell.lbName.textColor = Constants.Colors.secondary
     //   }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellFriend", for: indexPath) as! FriendTableViewCell
       
        let friend = searchFriends[indexPath.row]
        cell.lbFriendName.text = friend.contactName
        
      //  cell.lbName.text = "Mi contacto"
       return cell
   }
    
    func collectionSkeletonView(_ skeletonView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 15
    }
    
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return "cellFriend"
    }
    
    @objc func floatingButtonTapped(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1, animations: {
            sender.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
            sender.alpha = 0.3
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                sender.transform = CGAffineTransform.identity
                sender.alpha = 1.0
            }
        }
        print("Botón tocado")
        Utils.AlertFriendsUtils.showAddFriendAlert(on: self, title: "add_friend".localized())
    }
    
    @objc
    func getFriends(completion: @escaping () -> Void) {
        
        floatingButton.isHidden = true

        let userId = UserDefaults.standard.integer(forKey: "userId")

        serviceManager.getFriends(userId: userId, friendStatus: "A") { result in
            DispatchQueue.main.async {
                switch result {
                    case .success(let friendsApi):
                        self.friends = friendsApi
                        self.searchFriends = friendsApi
                        self.tvFriends.reloadData()
                        print(friendsApi)

                    case .failure(let error):
                    
                    if let apiError = error as? APIError {
                        switch apiError {
                        case .notFound:
                            self.friends = [FriendDto]()
                            self.searchFriends = [FriendDto]()
                            self.tvFriends.reloadData()
                            print("Sin amigos o Error al obtener friends desde el API: \(error)")
                            
                        default:
                            self.friends = [FriendDto]()
                            self.searchFriends = [FriendDto]()
                            self.tvFriends.reloadData()
                            Utils.Snackbar.snackbarNoAction(message: "server_error".localized(), bgColor: Constants.Colors.red!, duration: 5.0)
                        }
                    }
                }

                self.tvFriends.stopSkeletonAnimation()
                self.tvFriends.hideSkeleton(reloadDataAfter: true)
                self.floatingButton.isHidden = false
                completion()
            }
        }
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
       
        let searchText = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() ?? ""
        print(searchText)
        if searchText.isEmpty {
            searchFriends = friends
        } else {
            
            searchFriends = friends.filter {
                $0.contactName?.lowercased().contains(searchText) ?? false
            }
        }

        tvFriends.reloadData()
        let noResultVal = String(format: NSLocalizedString("no_results_for".localized(), comment: ""), searchText)
        friendsLabel.text = noResultVal
        friendsLabel.isHidden = !searchFriends.isEmpty
        tvFriends.isHidden = searchFriends.isEmpty
    }
    
    
    
    func updateGetFriends() {
        
        if(isConnected){
           // Utils.Snackbar.snackbarNoAction(message: "conectado", bgColor: Constants.Colors.green! ,duration: 5.0)
            getFriends{
                self.tfFriendSearch.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
                
                if self.searchFriends.isEmpty {
                    self.friendsLabel.isHidden = false
                    self.tvFriends.isHidden = true
                } else {
                    self.friendsLabel.isHidden = true
                    self.tvFriends.isHidden = false
                }
                self.floatingButton.isHidden = false
            }
        }else{
            self.tvFriends.showAnimatedGradientSkeleton(usingGradient: skeletonColor, animation: fastShimmer, transition: .none)
            Utils.Snackbar.snackbarWithAction(message: "no_internet_connection".localized(), bgColor: Constants.Colors.red!, titleAction:"close".localized() ,duration: 5.0)
            floatingButton.isHidden = true
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeNetworkObserver()
    }
    
    deinit {
        removeNetworkObserver()
    }

}
