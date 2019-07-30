//
//  WidgetTableViewCell.swift
//  Widget
//
//  Created by Carl Henningsson on 2019-07-19.
//  Copyright © 2019 Carl Henningsson. All rights reserved.
//

import UIKit

class WidgetTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        backgroundColor = .blue
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
