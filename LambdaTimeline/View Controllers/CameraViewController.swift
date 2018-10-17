//
//  CameraViewController.swift
//  LambdaTimeline
//
//  Created by De MicheliStefano on 17.10.18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

class CameraViewController: UIViewController, AVCaptureFileOutputRecordingDelegate {
    
    // MARK: - Properties
    let postController = PostController()
    private var captureSession: AVCaptureSession!
    private var recordOutput: AVCaptureMovieFileOutput!
    
    @IBOutlet weak var spinnerView: UIView!
    
    @IBOutlet weak var previewView: CameraPreviewView!
    @IBOutlet weak var recordButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCapture()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        captureSession.startRunning()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        captureSession.stopRunning()
    }
    
    @IBAction func toggleRecord(_ sender: Any) {
        if recordOutput.isRecording {
            recordOutput.stopRecording()
        } else {
            recordOutput.startRecording(to: newRecordingURL(), recordingDelegate: self)
        }
    }
    
    // MARK: - AVCaptureFileOutputRecordingDelegate
    
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        // Check if recording has actually started (.startRecording in toggleRecord is run asynchronuously and may take some time to actually start recording
        // AVCaptureFileOutputRecordingDelegate methods can be called in a background queue
        DispatchQueue.main.async {
            self.updateViews()
        }
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        DispatchQueue.main.async {
            self.updateViews()
            
            
            let alert = UIAlertController(title: "Save video", message: "Which kind of post do you want to create?", preferredStyle: .alert)
            
            alert.addTextField(configurationHandler: { (textField) in
                textField.placeholder = "Enter a video title"
            })
            
            let savePostAction = UIAlertAction(title: "Save", style: .default) { (_) in
                // Save video and store in in Firebase
                self.runActivityIndicator()
                do {
                    let videoData = try Data(contentsOf: outputFileURL)
                    let videoTitle = alert.textFields![0].text ?? ""
                    self.postController.createPost(with: videoTitle, ofType: .video, mediaData: videoData, ratio: nil, completion: { (success) in
                        NSLog("Saved to Firebase store")
                        // TODO: Delete video from file manager
                        self.navigationController?.popViewController(animated: true)
                    })
                } catch {
                    NSLog("Error generating video data \(error)")
                    let errorAlert = UIAlertController(title: "Error", message: "Error generating video data", preferredStyle: .alert)
                    
                    let okAction = UIAlertAction(title: "Ok", style: .cancel) { (_) in
                        self.navigationController?.popViewController(animated: true)
                    }
                    
                    errorAlert.addAction(okAction)
                    self.present(errorAlert, animated: true, completion: nil)
                }
                
            }
            
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
                self.navigationController?.popViewController(animated: true)
            }
            
            alert.addAction(savePostAction)
            alert.addAction(cancelAction)
            
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    // MARK: - Private
    
    private func updateViews() {
        guard isViewLoaded else { return }
        
        let recordButtonImageName = recordOutput.isRecording ? "Stop" : "Record"
        recordButton.setImage(UIImage(named: recordButtonImageName), for: .normal)
    }
    
    private func setupCapture() {
        // Session will hold all the components needed for video (input, output)
        let captureSession = AVCaptureSession()
        let device = bestCamera()
        guard let videoDeviceInput = try? AVCaptureDeviceInput(device: device),
            captureSession.canAddInput(videoDeviceInput) else { // check if it can be added or not
                fatalError()
        }
        captureSession.addInput(videoDeviceInput)
        
        // Setup video output to disk
        let fileOutput = AVCaptureMovieFileOutput()
        guard captureSession.canAddOutput(fileOutput) else { fatalError() }
        captureSession.addOutput(fileOutput)
        recordOutput = fileOutput
        
        captureSession.sessionPreset = .hd1920x1080
        captureSession.commitConfiguration() // Save all configurations and set up captureSession
        
        self.captureSession = captureSession
        
        // Assign captureSession to the VideoPreviewLayer
        previewView.videoPreviewLayer.session = captureSession
    }
    
    private func newRecordingURL() -> URL {
        let fm = FileManager.default
        let documentsDir = try! fm.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        
        return documentsDir.appendingPathComponent(UUID().uuidString).appendingPathExtension("mov")
    }
    
    // Camera's nowadays have a variety of cameras, so this function takes the best camera on the device
    // Could also let the user choose
    private func bestCamera() -> AVCaptureDevice {
        if let device = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back) {
            return device
        } else if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
            return device
        } else {
            fatalError("Missing expected back camera device")
        }
    }
    
    private func runActivityIndicator() {
        self.spinnerView.isHidden = false
        self.spinnerView.layer.cornerRadius = 15
        self.spinnerView.layer.masksToBounds = true
        self.previewView.alpha = 0.5
    }
    

}
