//
//  NotesCell.swift
//  ContactsAndNotes
//
//  Created by BarisOdabasi on 5.06.2021.
//

import UIKit

class NotesCell: UITableViewCell {
    @IBOutlet weak var noteName: UILabel!
    @IBOutlet weak var noteDescription: UILabel!
    @IBOutlet weak var forwardImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    

}
