//
//  ContFriendTabViewCell.swift
//  Gil
//
//  Created by Antonio Banda  on 13/05/25.
//

import UIKit

class ContFriendTabViewCell: UITableViewCell {

    @IBOutlet weak var lbCellOption: UILabel!
    
    @IBOutlet weak var imgCelloption: UIImageView!
    
    @IBOutlet weak var imgCellNav: UIImageView!
    
    @IBOutlet weak var cardView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        cardView.layer.cornerRadius = 12
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.1
        cardView.layer.shadowOffset = CGSize(width: 0, height: 2)
        cardView.layer.shadowRadius = 4
        cardView.layer.masksToBounds = false
        cardView.backgroundColor = Constants.Colors.primaryLigth
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        lbCellOption.textColor = highlighted ? Constants.Colors.secondary : Constants.Colors.accent
        let scale: CGFloat = highlighted ? 0.96 : 1.0
        let duration: TimeInterval = 0.1

        UIView.animate(withDuration: duration) {
            self.transform = CGAffineTransform(scaleX: scale, y: scale)
        }
    }

}
