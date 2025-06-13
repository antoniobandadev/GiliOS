//
//  SentTableViewCell.swift
//  Gil
//
//  Created by Antonio Banda  on 13/06/25.
//

import UIKit

class SentTableViewCell: UITableViewCell {

    @IBOutlet weak var sentCardView: UIView!
    
    @IBOutlet weak var lbSentName: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        sentCardView.layer.cornerRadius = 12
        sentCardView.layer.shadowColor = UIColor.black.cgColor
        sentCardView.layer.shadowOpacity = 0.1
        sentCardView.layer.shadowOffset = CGSize(width: 0, height: 2)
        sentCardView.layer.shadowRadius = 4
        sentCardView.layer.masksToBounds = false
        sentCardView.backgroundColor = Constants.Colors.primaryLigth
        
        isSkeletonable = true
        sentCardView.isSkeletonable = true
        sentCardView.skeletonCornerRadius = 12
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        lbSentName.textColor = highlighted ? Constants.Colors.secondary : Constants.Colors.accent
        
        let scale: CGFloat = highlighted ? 0.96 : 1.0
        let duration: TimeInterval = 0.1

        UIView.animate(withDuration: duration) {
            self.transform = CGAffineTransform(scaleX: scale, y: scale)
        }
    }

}
