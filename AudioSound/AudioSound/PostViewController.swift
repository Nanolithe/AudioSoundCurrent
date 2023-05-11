//
//  ViewController.swift
//  AudioSound
//
//  Created by Olisemedua Onwuatogwu on 4/11/23.
//

import UIKit
import UniformTypeIdentifiers
import ParseSwift
import PhotosUI

class PostViewController: UIViewController {
    @IBOutlet weak var imageCover: UIView!
    
    @IBOutlet weak var previewImageView: UIImageView!
    
    @IBOutlet weak var audioName: UITextField!
    
    @IBOutlet weak var discription: UITextField!
    
    @IBOutlet weak var hashTags: UITextField!
    
    private var pickedImage: UIImage?
    private var newAudio: Audio?
    private var audioFile: ParseFile? // means it can be null
    private var clipArt: ParseFile?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageCover.layer.cornerRadius = 12;
        imageCover.layer.masksToBounds = true;
        // Do any additional setup after loading the view.
    }
    
    // opens file manager
    @IBAction func openFiles(_ sender: Any) {
        let supportedTypes: [UTType] = [UTType.mp3, UTType.audio]

                 let documentPicker =
         UIDocumentPickerViewController(
             forOpeningContentTypes: supportedTypes)

                 documentPicker.delegate = self
         
                 present(documentPicker, animated: true,
                         completion: nil)
        
    }
    
    
    
    @IBAction func onClickSelectImage(_ sender: Any) {
        if(PHPhotoLibrary.authorizationStatus(for: .readWrite) != .authorized) {
        // request for access to photo library
            
            // after function call there is a nameless func
            // (closure that takes in the return off the
            // function call as status in the nameless
            // ffunction.
            PHPhotoLibrary.requestAuthorization(for: .readWrite) {
              [weak self] status in
                
                switch status {
                case .authorized:
                    // if user authorised show picker(on main thread)
                    DispatchQueue.main.async {
                        self?.presentImagePicker()
                    }
                default:
                    // show settings alert (on main thread)
                    DispatchQueue.main.async {
                        //Helper metod to sow setting alert
                        self?.presentGoToSettingsAlert()
                    }
                }
            }
        } else {
            // show poto picker
            presentImagePicker()
        }
        
    }
    
    private func presentImagePicker(){
        
        // Create a configuration object
        var config = PHPickerConfiguration();
        
        // set the filters to only show
        // images as option (i.e. no videos, etc.).
        config.filter = .images
        
        // Request the original file format.
        // Fastest method as it avoids transcoding
        config.preferredAssetRepresentationMode = .current
        
        // Only allow 1 image to be selected at a time.
        config.selectionLimit = 1
        
        // Instantiate a picker, passing in the
        // configuration.
        let picker = PHPickerViewController(configuration: config)
        
        // set the picker delegate so we can receive
        // whatever image the user picks.
        // (Means who is going to handel the picking
        // of images?)
        picker.delegate = self;
        
        
        
        // Present the picker
        present(picker, animated: true)
    }

    @IBAction func onClickPostBTN(_ sender: Any) {
        
        // Dismiss Keyboard
        view.endEditing(true)
    
        // self.newAudio? just tells the compilar
        // not to do anything if newAudio is null
        
        self.newAudio = Audio(audioName: audioName.text,description:discription.text,
                              hashTags: hashTags.text, audioFile: self.audioFile, clipArt: self.clipArt);
        
        self.newAudio?.save{
            [weak self] result in

            switch result {
            case .success(let audioObject):
                print("Audio saved ✅");

            case .failure(let error):
                print(error);

            }
        };
    }
    
    func presentGoToSettingsAlert() {
        let alertController = UIAlertController (
            title: "Photo Access Required",
            message: "In order to add photos to your audio posts, we need access to your photo library. You can allow access in Settings.",
            preferredStyle: .alert)

        let settingsAction = UIAlertAction(title: "Settings", style: .default) { _ in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }

            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl)
            }
        }

        alertController.addAction(settingsAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)

        present(alertController, animated: true, completion: nil)
    }
    
    private func showAlert(description: String? = nil) {
        let alertController = UIAlertController(title: "Oops...", message: "\(description ?? "Please try again...")", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(action)
        present(alertController, animated: true)
    }
}

// extension for file manager delegates
extension PostViewController : UIDocumentPickerDelegate {
    
    // delegeate method called  after
    // picking audio
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        // dismiss document picker
        controller.dismiss(animated: true)
        
        // get Url of picked file
        let pickedFileUrl = urls[0];
        
        // try to get the data using
        // the file URL
        let audioData = try! Data(contentsOf: pickedFileUrl);
        
        // Turn the data to parse file
        self.audioFile = ParseFile(name:"audioFile.mp3", data: audioData);
        
        // creating a new type Audio
        
       }
}

// extention to help our view conntroller handel
// picking a picture.
extension PostViewController: PHPickerViewControllerDelegate{
    // what to do after picking a photo
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        
        // Dismiss the picker
        picker.dismiss(animated: true)
        
        // Make sure we have a non-nil item
        // provider
        guard let provider = results.first?.itemProvider,
            // Make sure the provider can load the UIImage
              provider.canLoadObject(ofClass: UIImage.self)
        else {return}
        
        // load a UIImage from the provider
        provider.loadObject(ofClass: UIImage.self) {
            [weak self] object, error in
            
            // Make sure we can cast the retured object to a
            // UIImage
            guard let image = object as? UIImage else {
                // ❌ Unable to cast to UIImag
                self?.showAlert()
                return
            }
            
            //check for and handle any errors
            if let error = error {
                self?.showAlert(description: error.localizedDescription)
                return
            }
            else {
                
                // UI update (like setting image on image view)
                // should be done on main thread
                DispatchQueue.main.async {
                    // set image on preview image view
                    self?.previewImageView.image = image
                    
                    // set image to use when saving post
                    self?.pickedImage = image
                    
                    
                    // ========= Turning Image to parsefile
                    
                    //Unwrap optional pickedImage
                    guard let image = self?.pickedImage,
                          // Create and compress image data (jpeg) from UIImage
                          let imageData = image.jpegData(compressionQuality: 0.1)
                    else {
                        return
                    }
                    
                    // Create a Parse File by providing a name and
                    // passing in the image data('to binary data')
                    self?.clipArt = ParseFile(name:"image.jpg", data: imageData)
                    
                    //================================
                }
            }
        }
    }
}



