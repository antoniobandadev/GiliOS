//
//  ReceivedViewController.swift
//  Gil
//
//  Created by Antonio Banda  on 01/05/25.
//

import UIKit
import MaterialComponents
import SkeletonView

class ReceivedViewController: KeyboardViewController , SkeletonTableViewDataSource, UITableViewDelegate , UITextFieldDelegate {
    
    let serviceManager = ServiceManager.shared
    
    var friends = [FriendDto]()
    var searchFriends = [FriendDto]()
    
    let fastShimmer = SkeletonAnimationBuilder()
           .makeSlidingAnimation(withDirection: .leftRight, duration: 0.5)
    
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
    
    @IBOutlet weak var tfReceivedSearch: MDCOutlinedTextField!
    
    @IBOutlet weak var tvReceived: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tvReceived.dataSource = self
        tvReceived.delegate = self
        tfReceivedSearch.delegate = self

        tvReceived.isSkeletonable = true

        // Do any additional setup after loading the view.
        initUI()
        
        //Observo los cambios de internet
        observeConnectionChanges { [weak self] isConnected in
            self?.updateGetFriends()
        }
        
      
        NotificationCenter.default.addObserver(self, selector:#selector(updateGetFriends), name: NSNotification.Name("DELETE_FRIEND"), object:nil)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateGetFriends()
    }
    
    
    
    
    func initUI(){
        Utils.TextField.config(tfReceivedSearch, label: NSLocalizedString("search".localized(), comment: ""), icon: "ic_search_color", iconTrailing: "xmark.circle.fill")
        
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
        Utils.AlertFriendsUtils.showAlert(on: self, title: "add_friend".localized(), friend: friend, recivedFriend: true)
      //  Utils.AlertCustomUtils.showEditCustomAlert(on: self, title: "update_contact".localized(), newContact:false, contact: contact)
           // cell.lbName.textColor = Constants.Colors.secondary
     //   }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellReceived", for: indexPath) as! ReceivedTableViewCell
       
        let friend = searchFriends[indexPath.row]
        cell.lbReceivedName.text = friend.contactName
        
      //  cell.lbName.text = "Mi contacto"
       return cell
   }
    
    func collectionSkeletonView(_ skeletonView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 15
    }
    
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return "cellReceived"
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
        self.tvReceived.showAnimatedGradientSkeleton(animation: fastShimmer, transition: .none)
      
        let userId = UserDefaults.standard.integer(forKey: "userId")

        serviceManager.getFriends(userId: userId, friendStatus: "R") { result in
            DispatchQueue.main.async {
                switch result {
                    case .success(let friendsApi):
                        self.friends = friendsApi
                        self.searchFriends = friendsApi
                        self.tvReceived.reloadData()
                        print(friendsApi)

                    case .failure(let error):
                    
                    if let apiError = error as? APIError {
                        switch apiError {
                        case .notFound:
                            self.friends = [FriendDto]()
                            self.searchFriends = [FriendDto]()
                            self.tvReceived.reloadData()
                            print("Sin amigos o Error al obtener friends desde el API: \(error)")
                            
                        default:
                            self.friends = [FriendDto]()
                            self.searchFriends = [FriendDto]()
                            self.tvReceived.reloadData()
                            Utils.Snackbar.snackbarNoAction(message: "server_error".localized(), bgColor: Constants.Colors.red!, duration: 5.0)
                        }
                    }
                }

                self.tvReceived.stopSkeletonAnimation()
                self.tvReceived.hideSkeleton(reloadDataAfter: true)
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

        tvReceived.reloadData()
        let noResultVal = String(format: NSLocalizedString("no_results_for".localized(), comment: ""), searchText)
        friendsLabel.text = noResultVal
        friendsLabel.isHidden = !searchFriends.isEmpty
        tvReceived.isHidden = searchFriends.isEmpty
    }
    
    
    @objc
    func updateGetFriends() {
        
        if(isConnected){
           // Utils.Snackbar.snackbarNoAction(message: "conectado", bgColor: Constants.Colors.green! ,duration: 5.0)
            getFriends{
                self.tfReceivedSearch.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
                
                if self.searchFriends.isEmpty {
                    self.friendsLabel.isHidden = false
                    self.tvReceived.isHidden = true
                } else {
                    self.friendsLabel.isHidden = true
                    self.tvReceived.isHidden = false
                }
               
            }
        }else{
            self.tvReceived.showAnimatedGradientSkeleton(animation: fastShimmer, transition: .none)
            Utils.Snackbar.snackbarWithAction(message: "no_internet_connection".localized(), bgColor: Constants.Colors.red!, titleAction:"close".localized() ,duration: 5.0)
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
