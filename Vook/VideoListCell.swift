//
//  VideoListCell.swift
//  Vook
//
//  Created by Jonathon Fishman on 10/22/16.
//  Copyright © 2016 VookClub. All rights reserved.
//

import UIKit

class VideoListCell: UITableViewCell {
    
    @IBOutlet weak var broadcasterImageView: UIImageView!
    @IBOutlet weak var broadcastNameLabel: UILabel!
    @IBOutlet weak var isLiveLabel: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
