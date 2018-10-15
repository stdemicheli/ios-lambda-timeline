//
//  ImageFilterCollectionViewCell.swift
//  LambdaTimeline
//
//  Created by De MicheliStefano on 15.10.18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit

class ImageFilterCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var filterImageView: UIImageView!
    @IBOutlet weak var filterDescriptionLabel: UILabel!
    var image: (String, UIImage?)? {
        didSet {
            updateViews()
        }
    }
    
    private func updateViews() {
        filterImageView?.image = image?.1
        filterDescriptionLabel?.text = image?.0
    }
    
}
