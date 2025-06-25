//
//  GuestCViewController.swift
//  Gil
//
//  Created by Antonio Banda  on 23/06/25.
//

import UIKit
import MaterialComponents
import SkeletonView

class GuestCViewController: KeyboardViewController , SkeletonTableViewDataSource, UITableViewDelegate , UITextFieldDelegate{
    
    var eventId : Int?
    
    let serviceManager = ServiceManager.shared
    
    var contacts = [ContactDto]()
    var contactsPendings = [ContactDto]()
    var searchContacts = [ContactDto]()
    
    let skeletonColor = SkeletonGradient(baseColor: UIColor.darkGray)
    
    let fastShimmer = SkeletonAnimationBuilder()
           .makeSlidingAnimation(withDirection: .leftRight, duration: 0.5)
    
    let contactsLabel: UILabel = {
        let label = UILabel()
        label.text = "no_contacts_found".localized()
        label.textAlignment = .center
        label.textColor = .gray
        label.font = Constants.Fonts.fontBold
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        return label
    }()
    
    @IBOutlet weak var tfShearchC: MDCOutlinedTextField!
    
    @IBOutlet weak var tvContacts: UITableView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        tvContacts.dataSource = self
        tvContacts.delegate = self
        tfShearchC.delegate = self

        tvContacts.isSkeletonable = true
        // Do any additional setup after loading the view.
        initUI()
        
        self.tvContacts.showAnimatedGradientSkeleton(usingGradient: skeletonColor,animation: fastShimmer, transition: .none)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.observeConnectionChanges { [weak self] isConnected in
                self?.updateGetContacts()
            }
        }
        
        
        NotificationCenter.default.addObserver(self, selector:#selector(contactsApi), name: NSNotification.Name("ADD_CONTACT"), object:nil)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tfShearchC.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        self.tvContacts.showAnimatedGradientSkeleton(usingGradient: skeletonColor,animation: fastShimmer, transition: .none)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.updateGetContacts()
        }
    }
    
    
    func initUI(){
        Utils.TextField.config(tfShearchC, label: NSLocalizedString("search".localized(), comment: ""), icon: "ic_search_color", iconTrailing: "xmark.circle.fill")
       
        view.addSubview(contactsLabel)

        NSLayoutConstraint.activate([
            contactsLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            contactsLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    

   
    // MARK: - TableView
    
    func numberOfSections(in tableView: UITableView) -> Int {
       // #warning Incomplete implementation, return the number of sections
       return 1
   }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       // #warning Incomplete implementation, return the number of rows
        return searchContacts.count
        //return isLoading ? 5 : data.count
        
   }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let contact = searchContacts[indexPath.row]
       // Utils.AlertCustomUtils.showEditCustomAlert(on: self, title: "update_contact".localized(), newContact:false, contact: contact)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellContact", for: indexPath) as! CustomTableViewCell
       
        let contact = searchContacts[indexPath.row]
        cell.lbName.text = contact.contactName
        
       return cell
   }
    
    func collectionSkeletonView(_ skeletonView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 15
    }
    
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return "cellContact"
    }
    
    
    @objc
    func contactsApi(completion: @escaping () -> Void) {
        let userId = UserDefaults.standard.integer(forKey: "userId")
        
        serviceManager.getGuestContacts(userId: userId, eventId: eventId!){ result in
            DispatchQueue.main.async{
                switch result {
                    case .success(let contacts):
                    self.contacts = contacts
                        self.searchContacts = contacts
                        self.tvContacts.reloadData()
                        self.tvContacts.stopSkeletonAnimation()
                        self.tvContacts.hideSkeleton(reloadDataAfter: true)
                    case .failure(let error):
                    print("Error al actualizar desde el api : \(error)")
                }
                self.tvContacts.stopSkeletonAnimation()
                self.tvContacts.hideSkeleton(reloadDataAfter: true)
                completion()
            }
        }
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
       
        let searchText = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() ?? ""
        print(searchText)
        if searchText.isEmpty {
            searchContacts = contacts
        } else {
            
            searchContacts = contacts.filter {
                $0.contactName?.lowercased().contains(searchText) ?? false
            }
        }

        tvContacts.reloadData()
        let noResultVal = String(format: NSLocalizedString("no_results_for".localized(), comment: ""), searchText)
        contactsLabel.text = noResultVal
        contactsLabel.isHidden = !searchContacts.isEmpty
        tvContacts.isHidden = searchContacts.isEmpty
    }
    
    @objc func updateGetContacts(){
        if(isConnected){
            self.contactsApi{
            }
        }else{
            self.tvContacts.showAnimatedGradientSkeleton(usingGradient: skeletonColor, animation: fastShimmer, transition: .none)
            Utils.Snackbar.snackbarWithAction(message: "no_internet_connection".localized(), bgColor: Constants.Colors.red!, titleAction:"close".localized() ,duration: 5.0)
        }
        
    }
}
