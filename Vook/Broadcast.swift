//
//  Video.swift
//  Vook
//
//  Created by Jonathon Fishman on 9/28/16.
//  Copyright © 2016 VookClub. All rights reserved.
//

import Foundation

class Broadcast: NSObject {
    
    // Gets set by BE, needs to be objectId
    var objectId: String?
    
    // Should = chapter and/or discussion title
    var broadcastName: String?
    
    var broadcastUrl: String?
    
    var bookId: String?
    
    var isDiscussion: Bool?
    
    var liveBroadcast: Bool?
}
