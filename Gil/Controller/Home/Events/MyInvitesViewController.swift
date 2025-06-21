//
//  MyGuestViewController.swift
//  Gil
//
//  Created by Antonio Banda  on 20/06/25.
//


import UIKit
import SkeletonView
import Kingfisher

class MyInvitesViewController: UIViewController, SkeletonTableViewDataSource, UITableViewDelegate , UITextFieldDelegate {
    
    let fastShimmer = SkeletonAnimationBuilder()
           .makeSlidingAnimation(withDirection: .leftRight, duration: 0.5)
    let skeletonColor = SkeletonGradient(baseColor: UIColor.darkGray)
    
    let serviceManager = ServiceManager.shared
    
    var events: [EventDto] = []
    
    var eventImage : UIImage?

    @IBOutlet weak var tvInvites: UITableView!
    
    let invitesLabel: UILabel = {
        let label = UILabel()
        label.text = "no_invites_found".localized()
        label.textAlignment = .center
        label.textColor = .gray
        label.font = Constants.Fonts.fontBold
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        return label
    }()
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tvInvites.dataSource = self
        tvInvites.delegate = self
        
        tvInvites.isSkeletonable = true
       
        
        self.tvInvites.showAnimatedGradientSkeleton(usingGradient: skeletonColor, animation: fastShimmer, transition: .none)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.observeConnectionChanges { [weak self] isConnected in
                self?.initUI()
            }
        }
        
        /*NotificationCenter.default.addObserver(self, selector:#selector(initUI), name: NSNotification.Name("EVENT_S"), object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(initUI), name: NSNotification.Name("UPDATE_CONTACT"), object:nil)*/
       
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.invitesLabel.isHidden = true
        self.tvInvites.showAnimatedGradientSkeleton(usingGradient: skeletonColor,animation: fastShimmer, transition: .none)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.initUI()
        }
    }
    
    @objc func initUI(){
        self.invitesLabel.isHidden = true
        self.tvInvites.showAnimatedGradientSkeleton(usingGradient: skeletonColor, animation: fastShimmer, transition: .none)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if(self.isConnected){
                self.getInvites()
            }else{
                //self.tvInvites.showAnimatedGradientSkeleton(usingGradient: self.skeletonColor, animation: self.fastShimmer, transition: .none)
                Utils.Snackbar.snackbarWithAction(message: "no_internet_connection".localized(), bgColor: Constants.Colors.red!, titleAction: "close".localized() , duration: 5.0)
            }
        }
        
        view.addSubview(invitesLabel)

        NSLayoutConstraint.activate([
            invitesLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            invitesLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    
    @objc
    func myInvitesApi(completion: @escaping () -> Void) {
        let userId = UserDefaults.standard.integer(forKey: "userId")
        
        serviceManager.getInvites(userId: userId) { result in
            DispatchQueue.main.async {
                switch result {
                    case .success(let myEvents):
                    self.events = myEvents
                    case .failure(let error):
                    if let apiError = error as? APIError {
                        switch apiError {
                        case .notFound:
                            Utils.Snackbar.snackbarNoAction(message: "no_pending_events".localized(), bgColor: Constants.Colors.green!, duration: 5.0)
                        default:
                            Utils.Snackbar.snackbarNoAction(message: "server_error".localized(), bgColor: Constants.Colors.red!, duration: 5.0)
                        }
                    } else {
                        Utils.Snackbar.snackbarNoAction(message: "server_error".localized(), bgColor: Constants.Colors.red!, duration: 5.0)
                        // Si es otro tipo de error
                        print("Error al actualizar invitaciones desde el api : \(error)")
                    }
                    
                }
                completion()
            }
            
        }
       
    }
    
    
    
    
    //MARK: Events
    
    func getInvites(){
        DispatchQueue.main.async{
            self.myInvitesApi(){
                self.tvInvites.reloadData()
               
                self.tvInvites.stopSkeletonAnimation()
                self.tvInvites.hideSkeleton()
                    
                if(self.events.count > 0){
                    self.invitesLabel.isHidden = true
                }else{
                    self.invitesLabel.isHidden = false
                }
                
            }
        }
    }
    
    
    
    
    
    // MARK: - TableView
    
    func numberOfSections(in tableView: UITableView) -> Int {
       // #warning Incomplete implementation, return the number of sections
       return 1
   }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       // #warning Incomplete implementation, return the number of rows
        return events.count
        //return isLoading ? 5 : data.count
        // orka
        //
        
   }
    
    var eventSelected : EventDto?

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        eventSelected = events[indexPath.row]
        performSegue(withIdentifier: "inviteSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "inviteSegue" {
            if let eventDestino = segue.destination as? InviteDetViewController {
                eventDestino.eventRecived = eventSelected
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellEvent", for: indexPath) as! EventTableViewCell
        
        
        let event = events[indexPath.row]
       
            let currentLocale = Locale.current
            let fromFormat = "yyyy-MM-dd HH:mm"
            var toFormat = ""
            
            if(currentLocale.identifier == "en_MX"){
                toFormat = "dd/MM/yyyy"
            }else{
                toFormat = "MM/dd/yyyy"
            }
            
            let dateStart = Utils.dateFormatString(date: event.eventDateStart ?? "", fromFormat: fromFormat, toFormat: toFormat)
            let dateEnd = Utils.dateFormatString(date: event.eventDateEnd ?? "", fromFormat: fromFormat, toFormat: toFormat)
            
            cell.ivEventImage.image = nil
            cell.lbEventTitle.text = event.eventName
            cell.lbEventDesc.text = event.eventDesc
            cell.lbEventDate.text = dateStart! + " - " + dateEnd!
            
           if let imageUrl = event.eventImg {
                
                let url = URL(string: imageUrl)
                let placeholder = UIImage(named: "ic_event_img")
                
                cell.ivEventImage.kf.setImage(
                    with: url,
                    placeholder: placeholder,
                    options: [
                        .transition(.fade(0.3)),
                        .cacheOriginalImage
                    ])
            } else {
                cell.ivEventImage.image = UIImage(named: "ic_event_img")
            }
        
       return cell
   }
    
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? EventTableViewCell {
            UIView.animate(withDuration: 0.1) {
                cell.eventCardView.backgroundColor = Constants.Colors.gray
            }
        }
    }

    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? EventTableViewCell{
            UIView.animate(withDuration: 0.2) {
                cell.eventCardView.backgroundColor = Constants.Colors.primaryLigth
            }
        }
    }
    
    func collectionSkeletonView(_ skeletonView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 15
    }
    
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return "cellEvent"
    }

}
