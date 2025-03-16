//
//  ViewController.swift
//  machineLearningImageDetect
//
//  Created by Mürşide Gökçe on 15.03.2025.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var imageview: UIImageView!
    var chosenImage = CIImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func imagePicker(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            imageview.image = selectedImage
            if let ciImage = CIImage(image: selectedImage) {
                chosenImage = ciImage
                recognizeImage(image: chosenImage)
            }
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func recognizeImage(image: CIImage) {
        label.text = "Finding ..."
        
        guard let model = try? VNCoreMLModel(for: MobileNetV2().model) else {
            label.text = "Model yüklenemedi"
            return
        }
        
        let request = VNCoreMLRequest(model: model) { (vnRequest, error) in
            guard let results = vnRequest.results as? [VNClassificationObservation], let topResult = results.first else {
                DispatchQueue.main.async {
                    self.label.text = "Tanımlama yapılamadı"
                }
                return
            }
            
            let confidenceLevel = topResult.confidence * 100
            let confidence = String(format: "%.2f", confidenceLevel)
            
            DispatchQueue.main.async {
                self.label.text = "\(confidence)% it's \(topResult.identifier)"
            }
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        DispatchQueue.global(qos: .userInteractive).async {
            do {
                try handler.perform([request])
            } catch {
                DispatchQueue.main.async {
                    self.label.text = "Resim işlenirken hata oluştu"
                }
                print(error.localizedDescription)
            }
        }
    }
}
