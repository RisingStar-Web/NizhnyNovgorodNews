//
//  NewImageTableViewCell.swift
//  KrasnoyarskNews
//
//  Created by Anton on 20.11.2018.
//  Copyright © 2018 Home. All rights reserved.
//

import UIKit

class NewImageTableViewCell: UITableViewCell {

    @IBOutlet weak var newsImage: UIImageView!
    @IBOutlet weak var newsBackButton: UIButton!
    
    @IBOutlet weak var topGradientLayer: UIView!
    @IBOutlet weak var bottomGradientLayer: UIView!
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        newsBackButton.setImage(UIImage(named: "ic_chevron_left_white")?.withRenderingMode(.alwaysOriginal), for: .normal)
        
        let screenSize: CGRect = UIScreen.main.bounds
        
        let gradientLayer2 = CAGradientLayer()
        gradientLayer2.colors = [UIColor.black.cgColor, UIColor.clear.cgColor]
        gradientLayer2.locations = [0.0, 1.0]
        gradientLayer2.frame = CGRect (x: 0, y: 0, width: screenSize.width, height: 90)
        topGradientLayer.layer.addSublayer(gradientLayer2)
        topGradientLayer.alpha = 0.6
        
//        let gradientLayer = CAGradientLayer()
//        gradientLayer.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
//        gradientLayer.locations = [0.0, 1.5]
//        gradientLayer.frame = CGRect (x: 0, y: 0, width: screenSize.width, height: 50)
//        bottomGradientLayer.layer.addSublayer(gradientLayer)
//        bottomGradientLayer.alpha = 0.7
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
