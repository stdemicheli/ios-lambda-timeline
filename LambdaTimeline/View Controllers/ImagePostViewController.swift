//
//  ImagePostViewController.swift
//  LambdaTimeline
//
//  Created by Spencer Curtis on 10/12/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit
import Photos

class ImagePostViewController: ShiftableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setImageViewHeight(with: 1.0)
        
        updateViews()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
    }
    
    func updateViews() {
        
        guard let imageData = imageData,
            let image = UIImage(data: imageData) else {
                title = "New Post"
                return
        }
        
        title = post?.title
        
        setImageViewHeight(with: image.ratio)
        
        imageView.image = image
        
        chooseImageButton.setTitle("", for: [])
    }
    
    private func presentImagePickerController() {
        
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
            presentInformationalAlertController(title: "Error", message: "The photo library is unavailable")
            return
        }
        
        let imagePicker = UIImagePickerController()
        
        imagePicker.delegate = self
        
        imagePicker.sourceType = .photoLibrary

        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func createPost(_ sender: Any) {
        
        view.endEditing(true)
        
        guard let imageData = imageView.image?.jpegData(compressionQuality: 0.1),
            let title = titleTextField.text, title != "" else {
            presentInformationalAlertController(title: "Uh-oh", message: "Make sure that you add a photo and a caption before posting.")
            return
        }
        
        postController.createPost(with: title, ofType: .image, mediaData: imageData, ratio: imageView.image?.ratio) { (success) in
            guard success else {
                DispatchQueue.main.async {
                    self.presentInformationalAlertController(title: "Error", message: "Unable to create post. Try again.")
                }
                return
            }
            
            DispatchQueue.main.async {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    @IBAction func chooseImage(_ sender: Any) {
        
        let authorizationStatus = PHPhotoLibrary.authorizationStatus()
        
        switch authorizationStatus {
        case .authorized:
            presentImagePickerController()
        case .notDetermined:
            
            PHPhotoLibrary.requestAuthorization { (status) in
                
                guard status == .authorized else {
                    NSLog("User did not authorize access to the photo library")
                    self.presentInformationalAlertController(title: "Error", message: "In order to access the photo library, you must allow this application access to it.")
                    return
                }
                
                self.presentImagePickerController()
            }
            
        case .denied:
            self.presentInformationalAlertController(title: "Error", message: "In order to access the photo library, you must allow this application access to it.")
        case .restricted:
            self.presentInformationalAlertController(title: "Error", message: "Unable to access the photo library. Your device's restrictions do not allow access.")
            
        }
        presentImagePickerController()
    }
    
    func setImageViewHeight(with aspectRatio: CGFloat) {
        
        imageHeightConstraint.constant = imageView.frame.size.width * aspectRatio
        
        view.layoutSubviews()
    }
    @IBAction func toggleImageFilterType(_ sender: Any) {
        showEffectTypes = !showEffectTypes
        self.collectionView.reloadData()
    }
    
    func image(byFiltering image: UIImage, withEffect effect: String) -> UIImage? {
        guard let cgImage = image.cgImage else { return image }
        let ciImage = CIImage(cgImage: cgImage)

        let filter = CIFilter(name: "CIPhotoEffect\(effect)")
        filter?.setValue(ciImage, forKey: kCIInputImageKey)

        guard let outputCIImage = filter?.outputImage,
            let outputCGImage = context.createCGImage(outputCIImage, from: outputCIImage.extent) else {
                return nil
        }
        
        return UIImage(cgImage: outputCGImage)
    }
    
    private func image(byFiltering image: UIImage, withColorControl colorControl: String) -> UIImage? {
        // CIFilter only take in CIImage formats, so we need to convert the UIImage to a CIImage. image.cgImage is a wrapper
        guard let cgImage = image.cgImage else { return image }
        
        let ciImage = CIImage(cgImage: cgImage)
        
        let filter = CIFilter(name: "CIColorControls")!
        
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        filter.setValue(0, forKey: kCIInputBrightnessKey)
        filter.setValue(1, forKey: kCIInputContrastKey)
        filter.setValue(1, forKey: kCIInputSaturationKey)
        
        // Need to use key-value coding
        switch colorControl {
        case "Brightness":
            filter.setValue(colorControlSlider.value, forKey: kCIInputBrightnessKey)
        case "Contrast":
            filter.setValue(colorControlSlider.value, forKey: kCIInputContrastKey)
        case "Saturation":
            filter.setValue(colorControlSlider.value, forKey: kCIInputSaturationKey)
        default:
            break
        }
        
        
        // Render CIImage back to a CGImage
        guard let outputCIImage = filter.outputImage,
            let outputCGImage = context.createCGImage(outputCIImage, from: outputCIImage.extent) // .extent is the whole image
            else {
                return nil
        }
        
        return UIImage(cgImage: outputCGImage)
    }
    
    var postController: PostController!
    var post: Post?
    var imageData: Data?
    var image: UIImage?
    private let context = CIContext(options: nil)
    @IBOutlet weak var filterSettingsView: UIView!
    var colorControlSlider = UISlider(frame: CGRect.zero)
    
    var imageEffectTypes: [(String, UIImage?)] = [("Chrome", nil), ("Fade", nil), ("Instant", nil), ("Mono", nil), ("Noir", nil), ("Process", nil), ("Tonal", nil), ("Transfer", nil)]
    var imageColorControlTypes: [(String, UIImage?)] = [("Saturation", UIImage(named: "saturation")), ("Brightness", UIImage(named: "brightness")), ("Contrast", UIImage(named: "contrast"))]
    var showEffectTypes = true
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var chooseImageButton: UIButton!
    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var postButton: UIBarButtonItem!
    @IBOutlet weak var collectionView: UICollectionView!
}

extension ImagePostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        chooseImageButton.setTitle("", for: [])
        
        picker.dismiss(animated: true, completion: nil)
        
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
        
        imageView.image = image
        self.image = image
        self.imageEffectTypes = imageEffectTypes.map { (type) -> (String, UIImage?) in
            var newType = type
            let filteredImage = self.image(byFiltering: image, withEffect: newType.0)
            newType.1 = filteredImage
            return newType
        }
        
        collectionView.reloadData()
        
        setImageViewHeight(with: image.ratio)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

extension ImagePostViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return showEffectTypes ? imageEffectTypes.count : imageColorControlTypes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageFilterCell", for: indexPath) as! ImageFilterCollectionViewCell
        
        let filteredImage = showEffectTypes ? imageEffectTypes[indexPath.item] : imageColorControlTypes[indexPath.item]
        
        cell.image = (filteredImage.0, filteredImage.1)
        
        cell.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(chooseImageFilter(_:))))
        
        return cell
    }
    
    @objc func chooseImageFilter(_ sender: UITapGestureRecognizer) {
        if showEffectTypes {
            let location = sender.location(in: self.collectionView)
            guard let indexPath = self.collectionView.indexPathForItem(at: location) else { return }
            self.imageView.image = imageEffectTypes[indexPath.item].1
        } else {
            collectionView.isHidden = true
            let slider = UISlider(frame: CGRect.zero)
            slider.minimumValue = -1
            slider.maximumValue = 1
            slider.value = 0
            slider.addTarget(self, action: #selector(adjustSlider(_:)), for: .valueChanged)
            slider.translatesAutoresizingMaskIntoConstraints = false
            self.filterSettingsView.addSubview(slider)
            slider.centerXAnchor.constraint(equalTo: filterSettingsView.centerXAnchor).isActive = true
            slider.centerYAnchor.constraint(equalTo: filterSettingsView.centerYAnchor).isActive = true
            slider.leadingAnchor.constraint(equalTo: filterSettingsView.leadingAnchor, constant: 8).isActive = true
            slider.trailingAnchor.constraint(equalTo: filterSettingsView.trailingAnchor, constant: -8).isActive = true
        }
    }
    
    @objc func adjustSlider(_ sender: UISlider) {
        imageView.image = self.image(byFiltering: self.imageView.image!, withColorControl: "Brightness")
    }
    
}
