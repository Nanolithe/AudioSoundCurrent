//
//  AudioBox.swift
//  AudioSound
//
//  Created by Olisemedua Onwuatogwu on 4/26/23.
//

import Foundation
import AVFoundation

struct AudioBox{
    var audioPlayer: AVPlayer?
    var observer: Any? // is an observer for when the song finishes
    var playerItem: AVPlayerItem?
    
    init(){
        audioPlayer = AVPlayer()
        audioPlayer?.volume = 0.5
    }
    
    mutating func play(fileurl: URL){
        audioPlayer?.pause()
        cleanUp(); // remove old observer
        playerItem = AVPlayerItem(url: fileurl);
        audioPlayer?.replaceCurrentItem(with: playerItem )
        
        // Add an observer for the AVPlayerItemDidPlayToEndTime notification
        observer = NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem, queue: .main) { [audioPlayer] _ in
            // Seek the player back to the beginning for looping
            
            audioPlayer?.seek(to: .zero);
            
            audioPlayer?.play();
            }
        
        //play
        audioPlayer?.play()
    }
    
    mutating func cleanUp() {
        // Remove the observer when no longer needed
        if let observer = observer {
            NotificationCenter.default.removeObserver(observer)
        }
        
        playerItem = nil
        observer = nil
        
    }
}

