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
    
    var event: EventDto?
    
    let fastShimmer = SkeletonAnimationBuilder()
           .makeSlidingAnimation(withDirection: .leftRight, duration: 0.5)
    let skeletonColor = SkeletonGradient(baseColor: UIColor.darkGray)
    
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
