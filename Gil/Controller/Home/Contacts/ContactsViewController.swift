//
//  ContactsViewController.swift
//  Gil
//
//  Created by Antonio Banda  on 10/06/25.
//

import UIKit
import MaterialComponents
import SkeletonView

class ContactsViewController: KeyboardViewController , SkeletonTableViewDataSource, UITableViewDelegate , UITextFieldDelegate{
    
    let serviceManager = ServiceManager.shared
    let context = DataManager.shared.persistentContainer.viewContext
    
    var contacts = [ContactEntity]()
    var contactsPendings = [ContactEntity]()
    var searchContacts = [ContactEntity]()
    
    let skeletonColor = SkeletonGradient(baseColor: UIColor.darkGray)
    
    let fastShimmer = SkeletonAnimationBuilder()
           .makeSlidingAnimation(withDirection: .leftRight, duration: 0.5)
    
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
        self.tvContacts.showAnimatedGradientSkeleton(usingGradient: skeletonColor, animation: fastShimmer, transition: .none)
        // Do any additional setup after loading the view.
        initUI()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.updateGetContacts()
        }
        NotificationCenter.default.addObserver(self, selector:#selector(updateGetContacts), name: NSNotification.Name("ADD_CONTACT"), object:nil)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tfShearchC.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    
    func initUI(){
        Utils.TextField.config(tfShearchC, label: NSLocalizedString("search".localized(), comment: ""), icon: "ic_search_color", iconTrailing: "xmark.circle.fill")
        
        view.addSubview(floatingButton)

        NSLayoutConstraint.activate([
           floatingButton.widthAnchor.constraint(equalToConstant: 60),
           floatingButton.heightAnchor.constraint(equalToConstant: 60),
           floatingButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
           floatingButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])

        floatingButton.addTarget(self, action: #selector(floatingButtonTapped), for: .touchUpInside)
        
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
        Utils.AlertCustomUtils.showEditCustomAlert(on: self, title: "update_contact".localized(), newContact:false, contact: contact)
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
        Utils.AlertCustomUtils.showCustomAlert(on: self, title: "add_contact".localized()
        , onConfirm: {
            print("aceptado")
        }, onCancel: {
            print("cancel")
        })
    }
    
    
    @objc
    func updateContacts(completion: @escaping () -> Void) {
        DispatchQueue.main.async{
            self.contacts = DataManager.shared.getContacts()
            self.searchContacts = DataManager.shared.getContacts()
            self.tvContacts.reloadData()
            self.tvContacts.stopSkeletonAnimation()
            self.tvContacts.hideSkeleton(reloadDataAfter: true)
            completion()
        }
        
        
        
    }
    
    
    @objc
    func updateContactsApi(completion: @escaping () -> Void) {
       
        
        let userId = UserDefaults.standard.integer(forKey: "userId")
        
        DataManager.shared.deleteAllContacts(context: self.context)
        
        serviceManager.getContacts(userId: userId) { result in
            DispatchQueue.main.async{
                switch result {
                    case .success(let contacts):
                    var contactsApiArray: [ContactEntity] = []
                    
                        for contactDto in contacts {
                            let contactsApi = ContactEntity(context: self.context)
                            contactsApi.contactId = contactDto.contactId
                            contactsApi.userId = Int16(contactDto.userId!)
                            contactsApi.contactName = contactDto.contactName
                            contactsApi.contactEmail = contactDto.contactEmail
                            contactsApi.contactStatus = contactDto.contactStatus
                            contactsApi.contactType = contactDto.contactType
                            contactsApi.contactSync = 1
                            contactsApiArray.append(contactsApi)
                        }
                    
                        DataManager.shared.insertContacts(contactsApiArray)
                        self.contacts = DataManager.shared.getContacts()
                        self.searchContacts = DataManager.shared.getContacts()
                        self.tvContacts.reloadData()
                        self.tvContacts.stopSkeletonAnimation()
                        self.tvContacts.hideSkeleton(reloadDataAfter: true)
                    print("Actualizados")
                    case .failure(let error):
                    print("Error al actualizar desde el api : \(error)")
                }
                self.tvContacts.stopSkeletonAnimation()
                self.tvContacts.hideSkeleton(reloadDataAfter: true)
                completion()
            }
            
        }
       
    }
    
    @objc
    func pendingContactsApi(completion: @escaping () -> Void) {
        contactsPendings = DataManager.shared.getContactsPending()
        if(!contactsPendings.isEmpty){
            for contactEntity in contactsPendings {
                
                let contactDto = ContactDto(entity: contactEntity)
                
                if(contactEntity.contactStatus == "P"){
                    
                    serviceManager.createContact(contact: contactDto) { result in
                        switch result {
                        case .success(_):
                            if(contactEntity.contactStatus == "C"){
                                contactEntity.contactSync = 1
                                
                            }else {
                                contactEntity.contactStatus = "A"
                                contactEntity.contactSync = 1
                                
                            }
                            
                            do {
                                try self.context.save()

                            } catch {
                                print("Error al guardar contactos pendientes: \(error)")
                            }
                            
                        case .failure(let error):
                            print("Error al enviar contactos pendientes: \(error)")
                        }
                    }
                    
                }else{
                        
                    serviceManager.updateContact(contact: contactDto) { result in
                        switch result {
                        case .success(_):
                            
                            contactEntity.contactSync = 1
                                
                            do {
                                try self.context.save()

                            } catch {
                                print("Error al guardar contactos pendientes: \(error)")
                            }
                            
                        case .failure(let error):
                            print("Error al enviar contactos pendientes: \(error)")
                        }
                    }
                }
            }
        }
        completion()
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
        print("getcontacts")
        if(isConnected){
            print("getcontacts_conectado")
            let contactsApiSelect = UserDefaults.standard.bool(forKey: "contactTable")
            if(contactsApiSelect){
                print("contactsApiSelect")
                pendingContactsApi{
                    print("updateContacts")
                    self.updateContacts{
                        print("pendingContactsApi")
                       /* if self.searchContacts.isEmpty {
                            self.contactsLabel.isHidden = false
                            self.tvContacts.isHidden = true
                        } else {
                            print("ElsependingContactsApi")
                            self.contactsLabel.isHidden = true
                            self.tvContacts.isHidden = false
                        }*/
                    }
                }
                
            }else{
                
                pendingContactsApi{
                    print("getcontacts_no_sinc")
                    self.updateContactsApi{
                        /*if self.searchContacts.isEmpty {
                            self.contactsLabel.isHidden = false
                            self.tvContacts.isHidden = true
                        } else {
                            self.contactsLabel.isHidden = true
                            self.tvContacts.isHidden = false
                        }*/
                    }
                }
                
                UserDefaults.standard.set(true, forKey: "contactTable")
            }
        }else{
            updateContacts{
                print("getcontacts_no_conectado")
           
                if self.searchContacts.isEmpty {
                    self.contactsLabel.isHidden = false
                    self.tvContacts.isHidden = true
                } else {
                    self.contactsLabel.isHidden = true
                    self.tvContacts.isHidden = false
                }
            }
        }
        
    }

    
       /*
        NotificationCenter.default.addObserver(self, selector: #selector(onNetworkStatusChanged), name: .networkStatusChanged, object: nil)
        @objc func onNetworkStatusChanged() {
            let isConnected = NetworkMonitor.shared.isConnected
            let message = isConnected ? "Conectado" : "Sin conexión"
            let color: UIColor = isConnected ? .green : .red
        
            if( isConnected){
                Utils.Snackbar.snackbarNoAction(message: "no_internet_connection".localized(), bgColor: Constants.Colors.green! ,duration: 5.0)
            }else{
                Utils.Snackbar.snackbarWithAction(message: "no_internet_connection".localized(), bgColor: Constants.Colors.red!, titleAction:"close".localized() ,duration: 5.0)
            }
        }

        deinit {
            NotificationCenter.default.removeObserver(self, name: .networkStatusChanged, object: nil)
        }*/
}
