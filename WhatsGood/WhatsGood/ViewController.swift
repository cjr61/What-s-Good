//
//  ViewController.swift
//  WhatsGood
//
//  Created by Cameron Reilly on 9/18/16.
//  Copyright © 2016 Cameron Reilly. All rights reserved.
//

import UIKit
import AVFoundation
import MapKit
import CoreLocation
import CoreMotion

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate {
    
    // API data 
//    var apiData = [String: Any]()
    
    //gyroscope motion manager
    var motionManager = CMMotionManager()
    
    
    // Device Location services
    let locationManager = CLLocationManager()
    
    func locationManager(_ locationManager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[0]
        
        let myLocation:CLLocationCoordinate2D = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
        
        //location data print
        //print (myLocation)
        

    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //location services request
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()         //gps
        if (CLLocationManager.headingAvailable()) {
            locationManager.headingFilter = 1           //compass
            locationManager.startUpdatingHeading()
        }
        else{
            print("no compass")
        }
        
        
        
        
        
        let userLat = locationManager.location?.coordinate.latitude
        let userLon = locationManager.location?.coordinate.longitude
//        print (userLat)
//        print (userLon)
        //API setup
        guard let url = URL(string: "https://developers.zomato.com/api/v2.1/geocode?apikey=21a22086fa4c05e648be29aece327aea&lat=\(userLat)&lon=\(userLon)") else{
            print("ERROR: Invalid URL")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) {
            
            (data, response, error) -> Void in
            
            // URL request is complete
            guard let data = data else {
                print("ERROR: Unable to access content")
                return
            }
            
            
            do{
                guard let parsedData = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? NSDictionary else{
                    print("ERROR: Unable to deserialize")
                    return
                }
                
                print (userLat)
                print (userLon)
                print (parsedData)

                
            } catch{
                print("ERROR: unable to convert download")
                print(error)
                return
            }
        }
        
        task.resume()

    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    // Camera Background Setup
    var captureSession : AVCaptureSession?
    var stillImageOutput : AVCaptureStillImageOutput?
    var previewLayer : AVCaptureVideoPreviewLayer?
    
    @IBOutlet weak var cameraView: UIView!

    
    override func viewDidAppear(_ animated: Bool) {
        //begin collecting gyro data
        motionManager.startGyroUpdates(to: OperationQueue.current!) { (data, error) in
            if let mydata = data{
                //print(mydata.rotationRate)
            }
        }
        
        //camera setup
        super.viewDidAppear(animated)
        previewLayer?.frame = cameraView.bounds
    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        captureSession = AVCaptureSession()
        captureSession?.sessionPreset = AVCaptureSessionPreset1920x1080         //POSSIBLE CHANGES TO RESOULTION HERE
        
        var backCamera = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        
        //setting camera as background
        var error : NSError?
        var input = AVCaptureDeviceInput()
        do {
            input = try AVCaptureDeviceInput(device: backCamera)
        } catch {
            //error
        }
        if error == nil && (captureSession?.canAddInput(input))! {
            captureSession?.addInput(input)
            stillImageOutput = AVCaptureStillImageOutput()
            stillImageOutput?.outputSettings = [AVVideoCodecKey : AVVideoCodecJPEG]
            
            if (captureSession?.canAddOutput(stillImageOutput))! {
                captureSession?.addOutput(stillImageOutput)
                
                previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                previewLayer?.videoGravity = AVLayerVideoGravityResizeAspect
                previewLayer?.connection.videoOrientation = AVCaptureVideoOrientation.portrait
                
                cameraView.layer.addSublayer(previewLayer!)
                captureSession?.startRunning()
            }
        }
    }
}

