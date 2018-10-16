//
//  ImagePostDetailTableViewController.swift
//  LambdaTimeline
//
//  Created by Spencer Curtis on 10/14/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit
import AVFoundation

class ImagePostDetailTableViewController: UITableViewController, AudioCommentTableViewCellProtocol, AVAudioPlayerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews()
    }
    
    func updateViews() {
        
        guard let imageData = imageData,
            let image = UIImage(data: imageData) else { return }
        
        title = post?.title
        
        imageView.image = image
        
        titleLabel.text = post.title
        authorLabel.text = post.author.displayName
        
        let recorderLabel = recorder?.isRecording ?? false ? "Recording" : "Record"
        recordButton.title = recorderLabel
    }
    
    func play(withUrl url: URL) {
        let isPlaying = audioPlayer?.isPlaying ?? false
        if isPlaying {
            audioPlayer?.pause()
        } else {
            if audioPlayer == nil {
                audioPlayer = try! AVAudioPlayer(contentsOf: url)
                audioPlayer?.delegate = self
            }
            audioPlayer?.play()
        }
    }
    
    @IBAction func record(_ sender: Any) {
        let isRecording = recorder?.isRecording ?? false
        if isRecording {
            recorder?.stop()
            if let url = recorder?.url {
                audioPlayer = try! AVAudioPlayer(contentsOf: url)
                audioPlayer?.delegate = self
                postController.addComment(with: url, to: &post!)
                self.tableView.reloadData()
                play(withUrl: url)
                recorder = nil
            }
        } else {
            if recorder ==  nil {
                let format = AVAudioFormat(standardFormatWithSampleRate: 44100.0, channels: 1)!
                recorder = try! AVAudioRecorder(url: newRecordingURL(), format: format)
                recorder?.record()
            }
        }
        updateViews()
    }
    
    private func newRecordingURL() -> URL {
        let fm = FileManager.default
        let documentsDir = try! fm.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        return documentsDir.appendingPathComponent(UUID().uuidString).appendingPathExtension("caf")
    }
    
    
    // MARK: - Table view data source
    
    @IBAction func createComment(_ sender: Any) {
        
        let alert = UIAlertController(title: "Add a comment", message: "Write your comment below:", preferredStyle: .alert)
        
        var commentTextField: UITextField?
        
        alert.addTextField { (textField) in
            textField.placeholder = "Comment:"
            commentTextField = textField
        }
        
        let addCommentAction = UIAlertAction(title: "Add Comment", style: .default) { (_) in
            
            guard let commentText = commentTextField?.text else { return }
            
            self.postController.addComment(with: commentText, to: &self.post!)
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(addCommentAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (post?.comments.count ?? 0) - 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath)
        
        let comment = post?.comments[indexPath.row + 1]
        
        cell.textLabel?.text = comment?.text
        cell.detailTextLabel?.text = comment?.author.displayName
        
        return cell
    }
    
    var post: Post!
    var postController: PostController!
    var imageData: Data?
    var recorder: AVAudioRecorder?
    var audioPlayer: AVAudioPlayer?
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var imageViewAspectRatioConstraint: NSLayoutConstraint!
    @IBOutlet weak var recordButton: UIBarButtonItem!
}
