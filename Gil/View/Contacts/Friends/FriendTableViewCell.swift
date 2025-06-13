//
//  FriendTableViewCell.swift
//  Gil
//
//  Created by Antonio Banda  on 12/06/25.
//

import UIKit

class FriendTableViewCell: UITableViewCell {
    
    

    @IBOutlet weak var friendCardView: UIView!
    
    @IBOutlet weak var lbFriendName: UILabel!
    
    
    
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        friendCardView.layer.cornerRadius = 12
        friendCardView.layer.shadowColor = UIColor.black.cgColor
        friendCardView.layer.shadowOpacity = 0.1
        friendCardView.layer.shadowOffset = CGSize(width: 0, height: 2)
        friendCardView.layer.shadowRadius = 4
        friendCardView.layer.masksToBounds = false
        friendCardView.backgroundColor = Constants.Colors.primaryLigth
        
        isSkeletonable = true
        friendCardView.isSkeletonable = true
        friendCardView.skeletonCornerRadius = 12
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        lbFriendName.textColor = highlighted ? Constants.Colors.secondary : Constants.Colors.accent
        
        let scale: CGFloat = highlighted ? 0.96 : 1.0
        let duration: TimeInterval = 0.1

        UIView.animate(withDuration: duration) {
            self.transform = CGAffineTransform(scaleX: scale, y: scale)
        }
    }

}
