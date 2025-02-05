//
//  VisualReaderViewController.swift
//  VoiceCrafter Wave
//
//  Created by UCF 2 on 24/01/2025.
//

import UIKit
import AVFoundation
import Photos
import Vision

class VisualReaderViewController: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    @IBOutlet weak var addbtn: UIButton!
    @IBOutlet weak var coybtn: UIButton!
    
    @IBOutlet weak var sharebtn: UIButton!

    @IBOutlet weak var readerimage: UIImageView!
    @IBOutlet weak var textview: UITextView!
    @IBOutlet weak var scannerbtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
            roundCorner(button: addbtn)
        roundCorner(button: coybtn)
        roundCorner(button: sharebtn)
            self.textview.isHidden = true
            readerimage.image = UIImage(named: "placeholder")
            scannerbtn.isHidden = true
        // Do any additional setup after loading the view.
    }
    
    
    func showSourceSelection() {
        let actionSheet = UIAlertController(title: "Choose Source", message: nil, preferredStyle: .actionSheet)

        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default) { [weak self] _ in
            self?.openCamera()
        })

        actionSheet.addAction(UIAlertAction(title: "Gallery", style: .default) { [weak self] _ in
            self?.openGallery()
        })

        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        present(actionSheet, animated: true)
    }


    
    
    @IBAction func mediabtnPressed(_ sender:UIButton)
    {
        showSourceSelection()
    }
 
    func openCamera()
    {
        let activityIndicator = UIActivityIndicatorView(style: .medium)
           activityIndicator.center = view.center
           activityIndicator.startAnimating()
           view.addSubview(activityIndicator)
        
        let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch cameraAuthorizationStatus
        {
         case .authorized:
        DispatchQueue.main.async
        { [weak self] in
            activityIndicator.stopAnimating()
            activityIndicator.removeFromSuperview()
                self?.presentCamera()
        }
        case .notDetermined:
            
        AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
            
        DispatchQueue.main.async
        {
            if granted
            {
                activityIndicator.stopAnimating()
                activityIndicator.removeFromSuperview()
                self?.presentCamera()
            }
            else
            {
                self?.redirectToSettings()
            }
        }
        }
        case .denied, .restricted:
        redirectToSettings()
        @unknown default:
            break
        }
    }
        
    func openGallery()
    {
        let activityIndicator = UIActivityIndicatorView(style: .medium)
           activityIndicator.center = view.center
           activityIndicator.startAnimating()
           view.addSubview(activityIndicator)
        
        let photoLibraryAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        
        switch photoLibraryAuthorizationStatus {
        case .authorized:
            DispatchQueue.main.async { [weak self] in
                self?.presentImagePicker(with: activityIndicator)
            }
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { [weak self] status in
                DispatchQueue.main.async
                {
                    if status == .authorized
                    {
                        self?.presentImagePicker(with: activityIndicator)
                    } else {
                        self?.redirectToSettings()
                    }
                }
            }
        case .denied, .restricted:
            redirectToSettings()
        case .limited:
            // Handle limited photo library access if needed
            break
        @unknown default:
            break
        }
    }
    
    private func presentImagePicker(with activityIndicator: UIActivityIndicatorView) {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        present(imagePicker, animated: true) {
            // Dismiss the activity indicator once the gallery is presented
            activityIndicator.stopAnimating()
            activityIndicator.removeFromSuperview()
        }
    }
    
    private func presentCamera()
    {
        if UIImagePickerController.isSourceTypeAvailable(.camera)
        {
            let imagePicker = UIImagePickerController()
            imagePicker.sourceType = .camera
            imagePicker.delegate = self
            present(imagePicker, animated: true, completion: nil)
        }
        else
        {
            print("Device Camera not available")
        }
    }
    
    private func redirectToSettings()
    {
        let alertController = UIAlertController(title: "Permission Required", message: "Please enable access to the camera or photo library in Settings.", preferredStyle: .alert)
        
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { _ in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
            }
        }
        alertController.addAction(settingsAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }

    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
    {
        picker.dismiss(animated: true, completion: nil)
        
        guard let pickedImage = info[.originalImage] as? UIImage else { return }
        readerimage.image = pickedImage
        scannerbtn.isHidden = false
        textview.isHidden = true
        //GoTodetailScreen(image: pickedImage)
       
    }
    @IBAction func sharebtnPressed(_ sender: UIButton) {
        if let textToShare = textview.text, !textToShare.isEmpty {
            let activityViewController = UIActivityViewController(activityItems: [textToShare], applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = sender // For iPads

            present(activityViewController, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Alert!", message: "Text field is empty. Please add some text to share.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }

    @IBAction func scanbtnPressed(_ sender:UIButton)
    {
        recognizeText(image:  readerimage.image!)
      
    }
    
    @IBAction func backbtnPressed(_ sender:UIButton)
    {
        self.dismiss(animated: true)
    }
    
    @IBAction func copybtnPressed(_ sender:UIButton)
    {
        copyText()
    }

    func copyText()
    {
        if !textview.text.isEmpty
       {
           UIPasteboard.general.string = textview.text
            textview.text = ""
           let alert = UIAlertController(title: "Text Copied", message: "Your Text has been copied", preferredStyle: .alert)
           alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
           present(alert, animated: true, completion: nil)
           return
       }
     
       let alert = UIAlertController(title: "Alert!", message: "Looks like text field is empty", preferredStyle: .alert)
       alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
       present(alert, animated: true, completion: nil)
   }


}


extension VisualReaderViewController
{
    func recognizeText(image: UIImage) {
        guard let cgImage = image.cgImage else { return }
        
        let textRecognitionRequest = VNRecognizeTextRequest { request, error in
            guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
            var recognizedText = ""
            for observation in observations {
                guard let topCandidate = observation.topCandidates(1).first else { continue }
                recognizedText += topCandidate.string + "\n"
            }
            DispatchQueue.main.async {
                
                if recognizedText == "" {
                    self.textview.text = "No Text Found in Image. Try! another image"
                    let alert = UIAlertController(title: "Recognition Error", message: "No Text Found in Image. Try! another image", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
                else {
                    self.readerimage.isHidden = true
                    self.textview.text = recognizedText
                    self.textview.isHidden = false
                    //self.readerimage.image = UIImage(named: "placeholder")
                    self.scannerbtn.isHidden = true
                }
            }
        }
        
        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        do {
            try requestHandler.perform([textRecognitionRequest])
        } catch {
            print("Error: \(error.localizedDescription)")
        }
    }
}
 
