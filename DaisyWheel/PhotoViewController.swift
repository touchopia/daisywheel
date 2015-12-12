//
//  PhotoViewController.swift
//
//
//  Created by Phil Wright on 12/8/15.
//  Copyright © 2015 Touchopia, LLC. All rights reserved.
//

import UIKit
import AVFoundation

class PhotoViewController: UIViewController {
    
    @IBOutlet weak var previewView: UIView!
    
    var captureSession: AVCaptureSession = AVCaptureSession()
    var stillImageOutput: AVCaptureStillImageOutput?
    var previewLayer: AVCaptureVideoPreviewLayer?
    var capturedImage: UIImage?
    
    //MARK: - View Controller Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let recognizer = UITapGestureRecognizer(target: self, action: Selector("takePhoto"))
        self.view.addGestureRecognizer(recognizer)
    }
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        
        captureSession.sessionPreset = AVCaptureSessionPresetPhoto
        
        let backCamera = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        
        var error : NSError?
        var input: AVCaptureDeviceInput?
        
        do {
            input = try AVCaptureDeviceInput(device: backCamera)
        } catch let e as NSError {
            input = nil
            error = e
        }
        
        if error == nil && captureSession.canAddInput(input) {
            captureSession.addInput(input)
            
            stillImageOutput = AVCaptureStillImageOutput()
            stillImageOutput!.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
            
            if captureSession.canAddOutput(stillImageOutput) {
                captureSession.addOutput(stillImageOutput)
                
                if let layer = AVCaptureVideoPreviewLayer(session: captureSession) {
                    layer.videoGravity = AVLayerVideoGravityResizeAspect
                    layer.connection?.videoOrientation = AVCaptureVideoOrientation.Portrait
                    previewView.layer.addSublayer(layer)
                    previewLayer = layer
                }
                
                captureSession.startRunning()
            }
        }
        
    }
    
    override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(animated)
        
        if let layer = previewLayer {
            layer.frame = previewView.bounds
        } else {
            print("No Layer Created")
        }
    }
    
    func takePhoto() {
        
        guard let output = stillImageOutput else {
            print("No Output Detected")
            return
        }
        
        if let videoConnection = output.connectionWithMediaType(AVMediaTypeVideo) {
            videoConnection.videoOrientation = AVCaptureVideoOrientation.Portrait
            output.captureStillImageAsynchronouslyFromConnection(videoConnection, completionHandler: {(sampleBuffer, error) in
                if (sampleBuffer != nil) {
                    let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
                    let dataProvider = CGDataProviderCreateWithCFData(imageData)
                    let cgImageRef = CGImageCreateWithJPEGDataProvider(dataProvider, nil, true, CGColorRenderingIntent.RenderingIntentDefault)
                    
                    let image = UIImage(CGImage: cgImageRef!, scale: 1.0, orientation: UIImageOrientation.Right)
                    self.capturedImage = image
                    
                    self.performSegueWithIdentifier("ShowImage", sender: self)
                }
            })
        }
    }
    
    override func unwindForSegue(unwindSegue: UIStoryboardSegue, towardsViewController subsequentVC: UIViewController) {
        if unwindSegue.identifier == "ShowImage" {
            
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "ShowImage" {
            if let controller = segue.destinationViewController as? DetailViewController {
                controller.capturedImage = self.capturedImage
            }
            
        }
    }
    
}

