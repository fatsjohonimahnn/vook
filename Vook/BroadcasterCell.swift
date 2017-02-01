//
//  BroadcasterCell.swift
//  Vook
//
//  Created by Jonathon Fishman on 10/7/16.
//  Copyright © 2016 VookClub. All rights reserved.
//

import UIKit

class BroadcasterCell: UITableViewCell {
    
    @IBOutlet weak var isLiveLabel: UILabel!
    @IBOutlet weak var viewersCount: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var userNickName: UILabel!
    @IBOutlet weak var userDescription: UILabel!
    @IBOutlet weak var spinner: UIActivityIndicatorView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
