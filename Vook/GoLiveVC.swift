//
//  GoLiveVC.swift
//  Vook
//
//  Created by Jonathon Fishman on 10/12/16.
//  Copyright © 2016 VookClub. All rights reserved.
//

import UIKit

class GoLiveVC: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var preView: UIView!
    @IBOutlet weak var subLayer: UIView!
    @IBOutlet weak var bookTitleLabel: UILabel!
    @IBOutlet weak var broadcastNameLabel: UILabel!
    
    @IBOutlet weak var liveLabel: UILabel!
    @IBOutlet weak var recordingOptionsSegmentControl: UISegmentedControl!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var swapCameraButton: UIButton!
    
    var broadcastData: Broadcast?
    var bookTitle: String?
    var broadcastName: String?
    var broadcastUrl: String?
    var webReader: String?
    var showWebReader = false
    
    //
    // BackendlessManager leak
    let BMSI = BackendlessManager.sharedInstance
    let backendless = Backendless.sharedInstance()
    var resolution: MPVideoResolution = RESOLUTION_CIF
    var publisher: MediaPublisher?
    var player: MediaPlayer?
    let VIDEO_TUBE = "Default"
    // End BE leak
    //
    
    enum RecordingMode {
        
        case videoAndAudio
        case audioOnly
    }
    
    var currentRecordingMode: RecordingMode = .videoAndAudio
    
    override func viewDidLoad() {
        super.viewDidLoad()
        recordButton.isEnabled = true
        liveLabel.isHidden = true
        recordingOptionsSegmentControl.isHidden = false
        stopButton.isHidden = true
        bookTitleLabel.text = bookTitle!
        broadcastNameLabel.text = broadcastName!
        
//TODO: Start microphone with camera OR ask for just ask for permission
//TODO: Add switch camera button for preview layer
        // start camera upon initialization
        setupCameraSession()

    }
    
    // added to setup camera preview layer
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if showWebReader == false {
         subLayer.layer.addSublayer(previewLayer)
        }
        cameraSession.startRunning()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        cameraSession.stopRunning()
        print("cameraSession.isRunning = \(cameraSession.isRunning)")
        
    }
    
    // set up the preview session
    lazy var cameraSession: AVCaptureSession = {
        let session = AVCaptureSession()
        session.sessionPreset = AVCaptureSessionPresetHigh
        return session
    }()
    
    
    lazy var previewLayer: AVCaptureVideoPreviewLayer = {
        let preview = AVCaptureVideoPreviewLayer(session: self.cameraSession)
        //add cameraView
        preview?.bounds = CGRect(x: 0, y: 0, width: self.preView.bounds.width, height: self.preView.bounds.height)
        //add cameraView
        preview?.position = CGPoint(x: self.preView.bounds.midX, y: self.preView.bounds.midY)
        preview?.videoGravity = AVLayerVideoGravityResize
        
        return preview!
    }()
    
    func setupCameraSession() {
        
        if #available(iOS 10.0, *) {
            let captureDevice = AVCaptureDevice.defaultDevice(withDeviceType: .builtInWideAngleCamera, mediaType: AVMediaTypeVideo, position: .front)
            
            do {
                let deviceInput = try AVCaptureDeviceInput(device: captureDevice)
                
                cameraSession.beginConfiguration()
                
                if (cameraSession.canAddInput(deviceInput) == true) {
                    cameraSession.addInput(deviceInput)
                }
                
                let dataOutput = AVCaptureVideoDataOutput()
                
                dataOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as NSString) : NSNumber(value: kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)]
                
                dataOutput.alwaysDiscardsLateVideoFrames = true //
                
                if (cameraSession.canAddOutput(dataOutput) == true) {
                    cameraSession.addOutput(dataOutput)
                }
                
                cameraSession.commitConfiguration()
            }
            catch let error as NSError {
                NSLog("\(error), \(error.localizedDescription)")
            }
            
        }
//        else {
//            let videoDevices = AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo)
//            var captureDevice:AVCaptureDevice
//            
//            for device in videoDevices!{
//                let device = device as! AVCaptureDevice
//                if device.position == AVCaptureDevicePosition.front {
//                    captureDevice = device
//                    break
//                }
//            }
//            let deviceInput = AVCaptureDeviceInput(device: captureDevice)
//            
//            cameraSession.beginConfiguration()
//            
//            if (cameraSession.canAddInput(deviceInput) == true) {
//                cameraSession.addInput(deviceInput)
//            }
//            
//            let dataOutput = AVCaptureVideoDataOutput()
//            
//            dataOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as NSString) : NSNumber(value: kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)]
//            
//            dataOutput.alwaysDiscardsLateVideoFrames = true //
//            
//            if (cameraSession.canAddOutput(dataOutput) == true) {
//                cameraSession.addOutput(dataOutput)
//            }
//            
//            cameraSession.commitConfiguration()
//            
//        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: Actions
    
    @IBAction func onRecordingOptionsChange(_ sender: UISegmentedControl) {
        
        if sender.selectedSegmentIndex == 0 {
            currentRecordingMode = .videoAndAudio
            cameraSession.startRunning()
        } else if sender.selectedSegmentIndex == 1 {
            currentRecordingMode = .audioOnly
            cameraSession.stopRunning()
//TODO: Turn screen black
            subLayer.backgroundColor = UIColor.black
            
        }
    }
    
    @IBAction func onRecordButton(_ sender: UIButton) {
        
        cameraSession.stopRunning()

// Check if actually broadcasting live
    //    broadcastData?.isLive = true
        Utility.sharedInstance.isLive = true
        
        //BackendlessManager.sharedInstance.updateLiveStatus(isLive: true, completion: {}, error: {})
        
    //
    // Careful of Backendless leak!!!!
    //
        // use appendStream to live stream and record to server
        let recordingOptions = MediaPublishOptions.appendStream(self.preView) as! MediaPublishOptions
        
        switch currentRecordingMode {
            
            case .videoAndAudio:
            
                recordingOptions.orientation = .portrait
                recordingOptions.resolution = RESOLUTION_CIF // RESOLUTION_MEDIUM
                recordingOptions.content = AUDIO_AND_VIDEO
            
            case .audioOnly:
            
                recordingOptions.content = ONLY_AUDIO
        }
        
        // save broadcastUrl supplied in VideoInfoVC
        
        print("--------------------------------------------------------------broadcastUrl = \(broadcastUrl!)")
        
        publisher = backendless?.mediaService.publishStream(broadcastUrl!, tube: VIDEO_TUBE, options: recordingOptions, responder: self)
        
        subLayer.isHidden = true
        liveLabel.isHidden = false
        recordButton.isEnabled = false
        recordButton.isHidden = true
        recordingOptionsSegmentControl.isHidden = true
        stopButton.isHidden = false
        stopButton.isEnabled = true
        
        Utility.sharedInstance.showActivityIndicator(view: self.view)
    }
    
    
    @IBAction func onStopButton(_ sender: UIButton) {
        
        stopMedia()
        
        self.showDoneAlert(title: "Story Saved!", message: "Your broadcast is now over")
    }
    
    func stopMedia() {
        
        if publisher != nil {
            
            publisher?.disconnect()
            publisher = nil;
            
            BackendlessManager.sharedInstance.updateBroadcastInfo(broadcastUrl: broadcastUrl!, completion: {}, error: {})
            
            BackendlessManager.sharedInstance.updateLiveStatus(isLive: false, completion: {}, error: {})
          //  broadcastData?.isLive = false
        }
        Utility.sharedInstance.hideActivityIndicator(view: self.view)
    }
    
    func showDoneAlert(title: String, message: String) {
        
        let alertController = UIAlertController(title: title,message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { action in
            
            self.performSegue(withIdentifier: "goLiveToMain", sender: self)
        }
    
        alertController.addAction(okAction)
        
        self.present(alertController, animated: true)
    }
    
    @IBAction func onSwapCameraButton(_ sender: UIButton) {
        
        publisher?.switchCameras()
    }
    
    func showFailAlert(title: String, message: String) {
        
        let alertController = UIAlertController(title: title,message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { action in
            
            self.dismiss(animated: true, completion: nil)
        }
        
        alertController.addAction(okAction)
        
        self.present(alertController, animated: true)
    }
}

extension GoLiveVC: IMediaStreamerDelegate {
    
    // MARK: IMediaStreamerDelegate protocol methods to handle stream state changes and errors
    
    public func streamStateChanged(_ sender: Any!, state: Int32, description: String!) {
        
        print("<IMediaStreamerDelegate> streamStateChanged: \(state) = \(description!)");
        
        // TODO: Are there any docs on IMediaStreamerDelegate? Is there any enums we can use instead of integers?
        // This IMediaStreamerDelegate method is sometimes called from the main thread
        // and sometimes not. Since I'm unsure of which thread it will be called from
        // I'll play it safe and dispatch everything back to the main thread.
        
        switch state {
            
        case 0: // CONN_DISCONNECTED
            
            DispatchQueue.main.async {
                self.stopMedia()
            }
            
        case 1: break //CONN_CONNECTED
            
            
        case 2: //CONN_CREATED
            
            DispatchQueue.main.async {
                
                // STOP THE CAMERA PREVIEW
                self.cameraSession.stopRunning()
                //self.stopButton.isEnabled = true
            }
            
        case 3: //STREAM_PLAYING
            
            DispatchQueue.main.async {
                
                if self.publisher != nil {
                    
                    if description != "NetStream.Publish.Start" {
                        Utility.showAlert(viewController: self, title: "Backendless Error", message: "Failed to play stream on the server.")
                        self.stopMedia()
                        return
                    }
                    //self.stopButton.isHidden = false
                    //self.swapCameraButton.isEnabled = true
                    Utility.sharedInstance.hideActivityIndicator(view: self.view)
                }
                
                if self.player != nil {
                    
                    if description == "NetStream.Play.StreamNotFound" {
                        
                        self.showDoneAlert(title: "Error", message: "Could not find stream")
                        
                        self.stopMedia()
                        return
                    }
                    
                    if description != "NetStream.Play.Start" {
                        return
                    }
                    
                    MPMediaData.routeAudioToSpeaker()
                    
                    //self.preView.isHidden = true
                }
            }
            
            return
            
        case 4: //STREAM_PAUSED
            
            DispatchQueue.main.async {
                
                if description == "NetStream.Play.StreamNotFound" {
                    Utility.showAlert(viewController: self, title: "Backendless Error", message: "Could not find stream on the server.")
                }
                
                self.stopMedia()
            }
            
        default:
            print("streamStateChanged unhandled state: \(state)")
            return
        }
    }
    
    func streamConnectFailed(_ sender: Any!, code: Int32, description: String!) {
        
        print("<IMediaStreamerDelegate> streamConnectFailed: \(code) = \(description)")
        
        cameraSession.stopRunning()
        
        showFailAlert(title: "Backendless Error1", message: "Failed to connect to the stream. Please check your internet connection and try again.")
        
        stopMedia()
    }
}
