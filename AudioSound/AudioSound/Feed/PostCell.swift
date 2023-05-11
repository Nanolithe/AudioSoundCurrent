//
//  PostCell.swift
//  AudioSound
//
//  Created by Olisemedua Onwuatogwu on 4/21/23.
//

import UIKit
import Alamofire
import AlamofireImage
import AVFoundation
import ParseSwift

class PostCell: UITableViewCell, AVAudioPlayerDelegate {

    @IBOutlet weak var audioArtwork: UIImageView!
    
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var smallClipArt: UIImageView!
    
    @IBOutlet weak var audioClipName: UILabel!
    
    @IBOutlet weak var audiodescription: UILabel!
    
    @IBOutlet weak var hashTag: UILabel!
    
    @IBOutlet weak var profileIcon: UIImageView!
    @IBOutlet weak var touchAreaView: UIView!
    
    
    var audioData:Data?
    var audioPlayer: AVPlayer?
    var audioParseFile: ParseFile?
    var progressBarObserver: Any?
    
    private var imageDataRequest: DataRequest?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // reset progress bar to 0.0
        progressBar.setProgress(0.0, animated: true);
    }
    

    func configureCell(with audioInfo: Audio){
        // Initialization code
 
        audioArtwork.layer.cornerRadius = 12;
        audioArtwork.layer.masksToBounds = true;
        
        smallClipArt.layer.cornerRadius = 12;
        smallClipArt.layer.masksToBounds = true;
        
        profileIcon.layer.cornerRadius = 22;
        profileIcon.layer.masksToBounds = true;
        
        
        
        // Add gesture recognizer to the touch area view
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
            touchAreaView.addGestureRecognizer(tapGestureRecognizer)
            
        // Add pan gesture recognizer to the touch area view
            let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
            touchAreaView.addGestureRecognizer(panGestureRecognizer)
            
            
        
        // Image
        if let imageFile = audioInfo.clipArt,
           let imageUrl = imageFile.url {
            
            // Use AlamofireImage helper to fetch remote image from URL
            
            // Remeber Nuke packge we used some
            // labs ago was used to load up image
            // from URL. rember our imge file
            // is not an image but binary file
            
            
            imageDataRequest = AF.request(imageUrl).responseImage{
                [weak self] response in
                
                switch response.result {
                case .success(let image):
                    // Set image view image with fetched image
                    self?.audioArtwork.image = image
                    self?.smallClipArt.image = image
                case .failure(let error):
                    print("❌ Error fetching image: \(error.localizedDescription)")
                    break
                }
            }
        }
        
        audioClipName.text = audioInfo.audioName
        audiodescription.text = audioInfo.description
        hashTag.text = audioInfo.hashTags
        
    }
    

    
    
    @objc func handleTap(sender: UITapGestureRecognizer) {
        let point = sender.location(in: touchAreaView)
        let progress = point.x / touchAreaView.bounds.size.width
        progressBar.setProgress(Float(progress), animated: true)
    }

    func addProgressBarObserver(audioPlayer: AVPlayer ){
        // Add "periodic time observer" to update the progress bar
        let interval = CMTime(seconds: 0.1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        
        progressBarObserver = audioPlayer.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main) {
            [weak self] time in
            
            // keep updating the progress bar
            let currentTime = CMTimeGetSeconds(time)
            let duration = CMTimeGetSeconds(audioPlayer.currentItem?.duration ?? CMTime.zero)
            
            // this gives us a percentage of completeness
            let progress = Float(currentTime / duration)
                
            self?.progressBar.setProgress(progress, animated: true);
        }
        
        self.audioPlayer = audioPlayer
    }
    
    func removeProgressBarObserver(){
        guard let audioPlayer = self.audioPlayer
        else{ return}
            
        audioPlayer.removeTimeObserver(progressBarObserver as Any);
        self.audioPlayer = nil
    }
    
    
    @objc func handlePan(sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: touchAreaView)
        let progress = progressBar.progress + Float(translation.x / touchAreaView.bounds.size.width)
        progressBar.setProgress(progress, animated: true)
        sender.setTranslation(CGPoint.zero, in: touchAreaView)
    }
    
    func playAudioFromURL(data: Data) {
        
        do {
            let audioPlayer = try AVAudioPlayer(data: data)
            audioPlayer.delegate = self
            audioPlayer.prepareToPlay()
            audioPlayer.play()
        } catch let error as NSError {
            print("Error playing audio: \(error)")
        }
    }
}
