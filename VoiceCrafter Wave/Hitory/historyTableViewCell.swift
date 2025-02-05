//
//  historyTableViewCell.swift
//  VoiceCrafter Wave
//
//  Created by UCF 2 on 24/01/2025.
//

import UIKit

class historyTableViewCell: UITableViewCell {

    
    @IBOutlet weak var fromCuntry:UILabel!
    @IBOutlet weak var toCountry:UILabel!
    @IBOutlet weak var fromText: UILabel!
    @IBOutlet weak var toText: UILabel!
    @IBOutlet weak var datelb: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
