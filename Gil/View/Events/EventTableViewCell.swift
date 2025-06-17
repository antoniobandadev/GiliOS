//
//  EventTableViewCell.swift
//  Gil
//
//  Created by Antonio Banda  on 16/06/25.
//

import UIKit

class EventTableViewCell: UITableViewCell {
    
    @IBOutlet weak var eventCardView: UIView!
    
    @IBOutlet weak var ivEventImage: UIImageView!
    
    @IBOutlet weak var lbEventTitle: UILabel!
    
    @IBOutlet weak var lbEventDesc: UILabel!
    
    @IBOutlet weak var lbEventDate: UILabel!
    
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        eventCardView.layer.cornerRadius = 12
        eventCardView.layer.shadowColor = UIColor.black.cgColor
        eventCardView.layer.shadowOpacity = 0.1
        eventCardView.layer.shadowOffset = CGSize(width: 0, height: 2)
        eventCardView.layer.shadowRadius = 4
        eventCardView.layer.masksToBounds = false
        eventCardView.backgroundColor = Constants.Colors.primaryLigth
        
        isSkeletonable = true
        eventCardView.isSkeletonable = true
        eventCardView.skeletonCornerRadius = 12
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
       /* if selected {
            self.contentView.layer.shadowColor = UIColor.systemBlue.cgColor
            self.contentView.layer.shadowOpacity = 0.5
            self.contentView.layer.shadowOffset = CGSize(width: 0, height: 2)
            self.contentView.layer.shadowRadius = 4
            self.contentView.backgroundColor = UIColor.systemGray6
        } else {
            self.contentView.layer.shadowOpacity = 0
            self.contentView.backgroundColor = UIColor.white
        }*/
        // Configure the view for the selected state
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        //lbFriendName.textColor = highlighted ? Constants.Colors.secondary : Constants.Colors.accent
        // eventCardView.backgroundColor = highlighted ? Constants.Colors.gray : Constants.Colors.primaryLigth
        let scale: CGFloat = highlighted ? 0.96 : 1.0
        let duration: TimeInterval = 0.1
        
        UIView.animate(withDuration: duration) {
           // self.contentView.backgroundColor = highlighted ? UIColor.systemGray5 : UIColor.black
            self.transform = CGAffineTransform(scaleX: scale, y: scale)
        }

        /*UIView.animate(withDuration: duration) {
            self.transform = CGAffineTransform(scaleX: scale, y: scale)
        }*/
    }

}
