//
//  VideoPostDetailViewController.swift
//  LambdaTimeline
//
//  Created by De MicheliStefano on 17.10.18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit
import AVFoundation

class VideoPostDetailViewController: UIViewController {

    var post: Post!
    var avPlayer: AVPlayer?
    var videoData: Data?
    @IBOutlet weak var videoPlayerView: VideoPlayerView!
    @IBOutlet weak var videoTitleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPlayer()
    }
    
    func setupPlayer() {
        let urlpath = Bundle.main.path(forResource: "sprint12", ofType: "any")
        let url = URL(string: urlpath!)!
        // let avPlayer = AVPlayer(url: post.mediaURL)
        let avPlayer = AVPlayer(url: url)
        videoPlayerView.player = avPlayer
        videoPlayerView.player?.play()
        
        videoTitleLabel?.text = post.title ?? ""
    }
    
    @IBAction func play(_ sender: Any) {
        videoPlayerView.player?.play()
    }
    
}
