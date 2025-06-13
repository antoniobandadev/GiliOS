//
//  ReceivedTableViewCell.swift
//  Gil
//
//  Created by Antonio Banda  on 13/06/25.
//

import UIKit

class ReceivedTableViewCell: UITableViewCell {
    
    @IBOutlet weak var receivedCardView: UIView!
    
    @IBOutlet weak var lbReceivedName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        receivedCardView.layer.cornerRadius = 12
        receivedCardView.layer.shadowColor = UIColor.black.cgColor
        receivedCardView.layer.shadowOpacity = 0.1
        receivedCardView.layer.shadowOffset = CGSize(width: 0, height: 2)
        receivedCardView.layer.shadowRadius = 4
        receivedCardView.layer.masksToBounds = false
        receivedCardView.backgroundColor = Constants.Colors.primaryLigth
        
        isSkeletonable = true
        receivedCardView.isSkeletonable = true
        receivedCardView.skeletonCornerRadius = 12
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        lbReceivedName.textColor = highlighted ? Constants.Colors.secondary : Constants.Colors.accent
        
        let scale: CGFloat = highlighted ? 0.96 : 1.0
        let duration: TimeInterval = 0.1

        UIView.animate(withDuration: duration) {
            self.transform = CGAffineTransform(scaleX: scale, y: scale)
        }
    }

}
