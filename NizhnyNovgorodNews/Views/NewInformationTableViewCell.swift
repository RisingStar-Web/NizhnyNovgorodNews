//
//  NewInformationTableViewCell.swift
//  KrasnoyarskNews
//
//  Created by Anton on 20.11.2018.
//  Copyright © 2018 Home. All rights reserved.
//

import UIKit

class NewInformationTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var fullLabel: UILabel!
    @IBOutlet weak var dateAndTimeLAbel: UILabel!
    @IBOutlet weak var pressFavoriteBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
