//
//  ContactCell.swift
//  ContactsAndNotes
//
//  Created by BarisOdabasi on 1.06.2021.
//

import UIKit

class ContactCell: UITableViewCell {
    @IBOutlet weak var contactImageView: UIImageView!
    @IBOutlet weak var contactLabel: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if self.traitCollection.userInterfaceStyle == .dark {
            contentView.backgroundColor = .quaternaryLabel
            contactLabel.textColor = .label
                }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
      
        // Configure the view for the selected state
    }

}
