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

    var post: Post! {
        didSet {
            setupPlayer()
        }
    }
    var avPlayer: AVPlayer?
    var videoData: Data?
    @IBOutlet weak var videoPlayerView: VideoPlayerView!
    @IBOutlet weak var videoTitleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPlayer()
    }
    
    func setupPlayer() {
        
        avPlayer = AVPlayer(url: post.mediaURL)
        
        let playerLayer = AVPlayerLayer(player: avPlayer)
        playerLayer.frame = self.view.bounds
        self.view.layer.addSublayer(playerLayer)
        avPlayer?.play()
//        videoPlayerView?.player = avPlayer
//        videoPlayerView?.player?.play()
        
        videoTitleLabel?.text = post.title ?? ""
    }
    
    @IBAction func play(_ sender: Any) {
        
        avPlayer?.play()
        //videoPlayerView.player?.play()
    }
    
}
