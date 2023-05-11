//
//  AudioPost.swift
//  AudioSound
//
//  Created by Olisemedua Onwuatogwu on 4/13/23.
//
import Foundation
import ParseSwift

struct Audio: ParseObject{
    
    
    
    var objectId: String?
    var createdAt: Date?
    var updatedAt: Date?
    var ACL: ParseACL?
    var originalData: Data?

    // Your own custom properties.
    var audioName: String?;
    var description: String?;
    var hashTags: String?;
    var audioFile: ParseFile?;
    var clipArt: ParseFile?;
}

extension Audio{
    
    init(audioName: String, description: String, hashTags:String,
         audioFile: ParseFile, artStyle: ParseFile){
        self.audioName = audioName;
        self.description = description;
        self.hashTags = hashTags;
        self.audioFile = audioFile;
        self.clipArt = artStyle;
    }
}
