//
//  InviteDetViewController.swift
//  Gil
//
//  Created by Antonio Banda  on 21/06/25.
//

import UIKit
import SkeletonView
import Kingfisher

class InviteDetViewController: UIViewController {
    
    var eventRecived: EventDto?
    
    var myGuest : [EventGuestDto]?
    
    let fastShimmer = SkeletonAnimationBuilder()
           .makeSlidingAnimation(withDirection: .leftRight, duration: 0.5)
    let skeletonColor = SkeletonGradient(baseColor: UIColor.darkGray)
    
    let serviceManager = ServiceManager.shared
    
    @IBAction func btnCloseAction(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    
    @IBOutlet weak var lbTitle: UILabel!
    
    @IBOutlet weak var ivQR: UIImageView!
    
    @IBOutlet weak var lbEventName: UILabel!
    
    @IBOutlet weak var lbTitleDesc: UILabel!
    
    @IBOutlet weak var ivDesc: UIImageView!
    
    @IBOutlet weak var lbTitleType: UILabel!
    
    @IBOutlet weak var ivType: UIImageView!
    
    @IBOutlet weak var lbEventDesc: UILabel!
    
    @IBOutlet weak var lbEventType: UILabel!
    
    @IBOutlet weak var lbTitleDate: UILabel!
    
    @IBOutlet weak var ivDateStart: UIImageView!
    
    @IBOutlet weak var lbEventDateStart: UILabel!
    
    @IBOutlet weak var ivDateEnd: UIImageView!
    
    @IBOutlet weak var lbEventDateEnd: UILabel!
    
    @IBOutlet weak var lbTitleAdress: UILabel!
    
    @IBOutlet weak var ivStreet: UIImageView!
    
    @IBOutlet weak var lbEventStreet: UILabel!
    
    @IBOutlet weak var ivCity: UIImageView!
    
    @IBOutlet weak var lbEventCity: UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadSkeleton()
        getGuestDet()
        
    }
    
    
    func loadSkeleton(){
        lbTitle.isSkeletonable = true
        ivQR.isSkeletonable = true
        lbEventName.isSkeletonable = true
        
        lbTitleDesc.isSkeletonable = true
        ivDesc.isSkeletonable = true
        lbEventDesc.isSkeletonable = true
        
        lbTitleType.isSkeletonable = true
        ivType.isSkeletonable = true
        lbEventType.isSkeletonable = true
        
        lbTitleDate.isSkeletonable = true
        ivDateStart.isSkeletonable = true
        lbEventDateStart.isSkeletonable = true
        ivDateEnd.isSkeletonable = true
        lbEventDateEnd.isSkeletonable = true
        
        lbTitleAdress.isSkeletonable = true
        ivStreet.isSkeletonable = true
        lbEventStreet.isSkeletonable = true
        ivCity.isSkeletonable = true
        lbEventCity.isSkeletonable = true
        
        self.lbTitle.showAnimatedGradientSkeleton(usingGradient: skeletonColor, animation: fastShimmer, transition: .none)
        self.ivQR.showAnimatedGradientSkeleton(usingGradient: skeletonColor, animation: fastShimmer, transition: .none)
        self.lbEventName.showAnimatedGradientSkeleton(usingGradient: skeletonColor, animation: fastShimmer, transition: .none)
       
        self.lbTitleDesc.showAnimatedGradientSkeleton(usingGradient: skeletonColor, animation: fastShimmer, transition: .none)
        self.ivDesc.showAnimatedGradientSkeleton(usingGradient: skeletonColor, animation: fastShimmer, transition: .none)
        self.lbEventDesc.showAnimatedGradientSkeleton(usingGradient: skeletonColor, animation: fastShimmer, transition: .none)
        
        self.lbTitleType.showAnimatedGradientSkeleton(usingGradient: skeletonColor, animation: fastShimmer, transition: .none)
        self.ivType.showAnimatedGradientSkeleton(usingGradient: skeletonColor, animation: fastShimmer, transition: .none)
        self.lbEventType.showAnimatedGradientSkeleton(usingGradient: skeletonColor, animation: fastShimmer, transition: .none)
        
        self.lbTitleDate.showAnimatedGradientSkeleton(usingGradient: skeletonColor, animation: fastShimmer, transition: .none)
        self.ivDateStart.showAnimatedGradientSkeleton(usingGradient: skeletonColor, animation: fastShimmer, transition: .none)
        self.lbEventDateStart.showAnimatedGradientSkeleton(usingGradient: skeletonColor, animation: fastShimmer, transition: .none)
        self.ivDateEnd.showAnimatedGradientSkeleton(usingGradient: skeletonColor, animation: fastShimmer, transition: .none)
        self.lbEventDateEnd.showAnimatedGradientSkeleton(usingGradient: skeletonColor, animation: fastShimmer, transition: .none)
        
        self.lbTitleAdress.showAnimatedGradientSkeleton(usingGradient: skeletonColor, animation: fastShimmer, transition: .none)
        self.ivStreet.showAnimatedGradientSkeleton(usingGradient: skeletonColor, animation: fastShimmer, transition: .none)
        self.lbEventStreet.showAnimatedGradientSkeleton(usingGradient: skeletonColor, animation: fastShimmer, transition: .none)
        self.ivCity.showAnimatedGradientSkeleton(usingGradient: skeletonColor, animation: fastShimmer, transition: .none)
        self.lbEventCity.showAnimatedGradientSkeleton(usingGradient: skeletonColor, animation: fastShimmer, transition: .none)
    }
    
    func getGuestDet(){
        if(isConnected){
            myGuestApi(){
                print(self.myGuest ?? "")
                self.showInvite()
            }
        }else{
            Utils.Snackbar.snackbarWithAction(message: "no_internet_connection".localized(), bgColor: Constants.Colors.red!, titleAction: "close".localized() , duration: 5.0)
        }
    }
    
    func showInvite(){
        
        DispatchQueue.main.async {
            
            self.lbTitle.text = self.myGuest?.first?.guestInvName
            if let imageUrl = self.myGuest?.first?.guestsQR {
                
                let url = URL(string: imageUrl)
                let placeholder = UIImage(named: "ic_event_img")
                
                self.ivQR.kf.setImage(
                    with: url,
                    placeholder: placeholder,
                    options: [
                        .transition(.fade(0.3)),
                        .cacheOriginalImage
                    ])
            } else {
                self.ivQR.image = UIImage(named: "ic_event_img")
            }
            self.lbEventName.text = self.myGuest?.first?.eventName
            self.lbEventDesc.text = self.myGuest?.first?.eventDesc
            
            self.lbEventType.text = self.myGuest?.first?.eventType
            
            let currentLocale = Locale.current
            let fromFormat = "yyyy-MM-dd HH:mm"
            var toFormat = ""
            
            if(currentLocale.identifier == "en_MX"){
                toFormat = "dd/MM/yyyy HH:mm"
            }else{
                toFormat = "MM/dd/yyyy HH:mm"
            }
            
            let dateStart = Utils.dateFormatString(date: self.myGuest?.first?.eventDateStart ?? "", fromFormat: fromFormat, toFormat: toFormat)
            let dateEnd = Utils.dateFormatString(date: self.myGuest?.first?.eventDateEnd ?? "", fromFormat: fromFormat, toFormat: toFormat)
            
            self.lbEventDateStart.text = dateStart
            self.lbEventDateEnd.text = dateEnd
            
            self.lbEventStreet.text = self.myGuest?.first?.eventStreet
            self.lbEventCity.text = self.myGuest?.first?.eventCity
        }
        
        stopSkeleton()
        
    }
    
    
    @objc
    func myGuestApi(completion: @escaping () -> Void) {
        let userId = UserDefaults.standard.integer(forKey: "userId")
        let eventId = eventRecived?.eventId
        print(userId)
        print(eventId!)
        serviceManager.getGuest(userId: userId, eventId: eventId!){ result in
            DispatchQueue.main.async {
                switch result {
                    case .success(let myGuestApi):
                    self.myGuest = myGuestApi
                    case .failure(let error):
                    if let apiError = error as? APIError {
                        switch apiError {
                        case .notFound:
                            Utils.Snackbar.snackbarNoAction(message: "server_error".localized(), bgColor: Constants.Colors.green!, duration: 5.0)
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
    
    func stopSkeleton(){
        
        self.lbTitle.stopSkeletonAnimation()
        self.lbTitle.hideSkeleton()
        self.ivQR.stopSkeletonAnimation()
        self.ivQR.hideSkeleton()
        self.lbEventName.stopSkeletonAnimation()
        self.lbEventName.hideSkeleton()
        
        self.lbTitleDesc.stopSkeletonAnimation()
        self.lbTitleDesc.hideSkeleton()
        self.ivDesc.stopSkeletonAnimation()
        self.ivDesc.hideSkeleton()
        self.lbEventDesc.stopSkeletonAnimation()
        self.lbEventDesc.hideSkeleton()
        
        self.lbTitleType.stopSkeletonAnimation()
        self.lbTitleType.hideSkeleton()
        self.ivType.stopSkeletonAnimation()
        self.ivType.hideSkeleton()
        self.lbEventType.stopSkeletonAnimation()
        self.lbEventType.hideSkeleton()
        
        self.lbTitleDate.stopSkeletonAnimation()
        self.lbTitleDate.hideSkeleton()
        self.ivDateStart.stopSkeletonAnimation()
        self.ivDateStart.hideSkeleton()
        self.lbEventDateStart.stopSkeletonAnimation()
        self.lbEventDateStart.hideSkeleton()
        self.ivDateEnd.stopSkeletonAnimation()
        self.ivDateEnd.hideSkeleton()
        self.lbEventDateEnd.stopSkeletonAnimation()
        self.lbEventDateEnd.hideSkeleton()
        
        self.lbTitleAdress.stopSkeletonAnimation()
        self.lbTitleAdress.hideSkeleton()
        self.ivStreet.stopSkeletonAnimation()
        self.ivStreet.hideSkeleton()
        self.lbEventStreet.stopSkeletonAnimation()
        self.lbEventStreet.hideSkeleton()
        self.ivCity.stopSkeletonAnimation()
        self.ivCity.hideSkeleton()
        self.lbEventCity.stopSkeletonAnimation()
        self.lbEventCity.hideSkeleton()
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
