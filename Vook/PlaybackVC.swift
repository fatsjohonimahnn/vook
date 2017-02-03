//
//  PlaybackVC.swift
//  Vook
//
//  Created by Jonathon Fishman on 10/16/16.
//  Copyright © 2016 VookClub. All rights reserved.
//

import UIKit

class PlaybackVC: UIViewController, IMediaStreamerDelegate {
    
    @IBOutlet weak var playBackView: UIImageView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
   
    var broadcast: Broadcast?
    var user: BackendlessUser?
    
    var resolution: MPVideoResolution = RESOLUTION_CIF
    
    var backendless = Backendless.sharedInstance()
    var player: MediaPlayer?
    let VIDEO_TUBE = "Default"
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.tabBarController?.tabBar.isHidden = false
        
        stopMedia()
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(user?.getProperty("isLive") as! Bool)

        stopButton.isEnabled = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Actions
    
    @IBAction func onPlayButton(_ sender: UIButton) {
        
        var options: MediaPlaybackOptions
        
        if user?.getProperty("isLive") as! Bool == true {
            options = MediaPlaybackOptions.liveStream(self.playBackView) as! MediaPlaybackOptions
        } else {
            options = MediaPlaybackOptions.recordStream(self.playBackView) as! MediaPlaybackOptions
        }
        
        options.orientation = .up
        options.isRealTime = Utility.sharedInstance.isLive!
        
        player = backendless?.mediaService.playbackStream(broadcast?.broadcastUrl!, tube: VIDEO_TUBE, options: options, responder: self)
        
        playButton.isEnabled = false
        stopButton.isEnabled = true
        
        Utility.sharedInstance.showActivityIndicator(view: self.view)
        
    }
    
    @IBAction func onStopButton(_ sender: UIButton) {
        
        playButton.isEnabled = true
        stopButton.isEnabled = false 

        
        stopMedia()
    }
    
    func stopMedia() {
                
        if player != nil {
            
            player?.disconnect()
            player = nil;
        }
        
        Utility.sharedInstance.hideActivityIndicator(view: self.view)
    }
    
    // MARK: IMediaStreamerDelegate protocol methods to handle stream state changes and errors
    
    public func streamStateChanged(_ sender: Any!, state: Int32, description: String!) {
        
        switch state {
            
        case 0: //CONN_DISCONNECTED
            
            stopMedia()
            
        case 1: break //CONN_CONNECTED
            
        case 2: //CONN_CREATED
            
            stopButton.isEnabled = true
            
        case 3: //STREAM_PLAYING
            
            Utility.sharedInstance.hideActivityIndicator(view: self.view)
            
            if self.player != nil {
                
                if description == "NetStream.Play.StreamNotFound" {
                    stopMedia()
                    
                    print("NetStream.Play.StreamNotFound")
                    
                    // turn on play button
                    playButton.isEnabled = true
                    stopButton.isEnabled = false
                    
                    return
                }
                
                if description != "NetStream.Play.Start" {
                    
                    print("NetStream.Play.Start")
                    return
                }
                
                MPMediaData.routeAudioToSpeaker()
                
                playBackView.isHidden = false
                
                Utility.sharedInstance.hideActivityIndicator(view: self.view)
            }
            
            return
            
        case 4: //STREAM_PAUSED
            
            stopMedia()
            
        default:
            print("streamStateChanged unhandled state: \(state)");
            return
        }
    }
    
    func streamConnectFailed(_ sender: Any!, code: Int32, description: String!) {
        
        print("<IMediaStreamerDelegate> streamConnectFailed: \(code) = \(description)");
        
        stopMedia()
    }
    



}
