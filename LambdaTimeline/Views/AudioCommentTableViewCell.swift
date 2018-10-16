//
//  AudioCommentTableViewCell.swift
//  LambdaTimeline
//
//  Created by De MicheliStefano on 16.10.18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit
import AVFoundation

protocol AudioCommentTableViewCellProtocol {
    func play(withUrl url: URL)
}

class AudioCommentTableViewCell: UITableViewCell {

    var delegate: AudioCommentTableViewCellProtocol?
    var comment: Comment? {
        didSet {
            updateViews()
        }
    }
    private var playButton: UIButton!
    private var nameLabel: UILabel!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateViews()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    @objc func play(_ sender: Any) {
        if let comment = comment, let audioURL = comment.audioURL {
            delegate?.play(withUrl: audioURL)
        }
    }
    
    private func updateViews() {
        playButton = UIButton(type: .system)
        nameLabel = UILabel()
        playButton.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(playButton)
        contentView.addSubview(nameLabel)
        
        playButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8).isActive = true
        playButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8).isActive = true
        playButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 8).isActive = true
        
        nameLabel.leadingAnchor.constraint(equalTo: playButton.trailingAnchor, constant: -8).isActive = true
        nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8).isActive = true
        nameLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 8).isActive = true
        nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8).isActive = true
        
        playButton.setTitle("Play", for: .normal)
        playButton.addTarget(self, action: #selector(play(_:)), for: .touchUpInside)
        playButton.tag = 1
        
        nameLabel.text = "fridolin"
    }

}
