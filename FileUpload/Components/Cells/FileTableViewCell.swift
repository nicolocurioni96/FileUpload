//
//  FileTableViewCell.swift
//  FileUpload
//
//  Created by nicolocurioni on 08/02/23.
//

import UIKit

class FileTableViewCell: UITableViewCell {
    
    @IBOutlet weak var imageViewIcon: UIImageView!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelSubtitle: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
     
    }
}
