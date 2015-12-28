//
//  SwViewController.swift
//  SwiftStitch
//
//  Created by HOBY WOO on 15/12/28.
//  Copyright © 2015年 ellipsis.com. All rights reserved.
//

import UIKit
import CoreMotion

class SwViewController: UIViewController, UIScrollViewDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate,UIAlertViewDelegate,UIGestureRecognizerDelegate{
    
    var tutorialView = UIImageView()
    
    private var motionManager: CMMotionManager = CMMotionManager()
    //creat Core Motion
    var count = 0
    var Label = UILabel()
    @IBAction func generate(sender: UIButton) {
        stitch()
    }
    @IBOutlet weak var generateButton: UIButton!
    @IBOutlet weak var addPhotoButton: UIButton!
    @IBOutlet weak var savingButton: UIButton!
    @IBAction func addToAlbum(sender: UIButton) {
        let image = self.stitchedImage
        UIImageWriteToSavedPhotosAlbum(image,nil, nil, nil)
        let a = UIAlertView(title: "保存成功", message: "照片已保存至相机胶卷", delegate: self, cancelButtonTitle: "好")
        a.show()
    }
    
    func snapshot(bigImage:UIImage) ->UIImage{
        let myImageRect = CGRectMake((bigImage.size.width-bigImage.size.width*0.83)*0.5, (bigImage.size.height-bigImage.size.height*0.83)*0.5, bigImage.size.width*0.83, bigImage.size.height*0.83)
        let imageRef = bigImage.CGImage
        let subImageRef = CGImageCreateWithImageInRect(imageRef, myImageRect)
        
        
        var size = CGSize()
        size.width = bigImage.size.width*0.83
        size.height = bigImage.size.height*0.83
        UIGraphicsBeginImageContext(size)
        let context = UIGraphicsGetCurrentContext()
        CGContextDrawImage(context, myImageRect, subImageRef)
        let smallImage = UIImage(CGImage: subImageRef!)
        UIGraphicsEndImageContext()
        
        return smallImage
    }
    
    func alertView(alertView: UIAlertView, didDismissWithButtonIndex buttonIndex: Int) {
        UIView.animateWithDuration(0.4, delay: 0, options: .CurveEaseOut, animations: {
            self.addPhotoLeading.constant = self.view.center.x-self.addPhotoButton.frame.width*0.5-15
            self.generateButton.alpha = 0
            self.savingButton.alpha = 0
            self.view.layoutIfNeeded()
            }, completion: nil)
    }
    
    @IBOutlet weak var addPhotoLeading: NSLayoutConstraint!
    
    @IBAction func loadImageButtonTapped(sender: UIButton) {
        Label.alpha = 0.5
        Label.text = "请垂直手持设备"
        circleView.alpha = 0
        circleViewBorder.alpha = 0
        circleView.center.x = imagePicker.view.center.x
        circleView.center.y = 250
        self.imageArray.removeAll()
        buttonLabel.text = " "
        imagePicker.sourceType = .Camera
        imagePicker.view.viewWithTag(400)?.transform = CGAffineTransformMakeScale(0, 0)
        imagePicker.cameraFlashMode = .Off
        imagePicker.cameraCaptureMode = .Photo
        imagePicker.showsCameraControls = false
        imagePicker.cameraViewTransform = CGAffineTransformMakeScale(1.2, 1.2)
        presentViewController(imagePicker, animated: true, completion: nil)
        self.startMonitoring()
        
    }
    @IBOutlet var spinner:UIActivityIndicatorView!
    @IBOutlet var scrollView:UIScrollView!
    @IBOutlet weak var countLabel: UILabel!
    
    @IBOutlet weak var imageStrLabel: UILabel!
    var imageArray = [UIImage!]()
    let imagePicker = UIImagePickerController()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        // Custom initialization
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    func takephoto(){
        imagePicker.takePicture()
        blackLayer.alpha = 1
        UIView.animateWithDuration(0.1, delay: 0.0, options: .CurveEaseOut, animations: {
            self.blackLayer.alpha = 0
            },completion :nil)
    }
    var aButton = UIButton()
    var blackLayer = UIView()
    var buttonLabel = UILabel()
    var circleView = UIView()
    var circleViewBorder = UIView()
    
    func handleSingleTap(sender:UITapGestureRecognizer){
        let view = self.scrollView.viewWithTag(100) as! PanoramaView
        let scale = self.scrollView.frame.width / view.getContentSize().width
        if scale == 1{
            UIView.animateWithDuration(0.6, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 5, options: .CurveEaseOut, animations: {
                view.imageView.transform = CGAffineTransformMakeScale(1, 1)
                view.adjustScrollView()
                }, completion:nil)
            UIView.animateWithDuration(0.2, delay: 0.2 , options: .CurveEaseOut, animations: {
                if self.addPhotoLeading.constant != self.view.center.x-self.addPhotoButton.frame.width*0.5-15{
                    self.savingButton.alpha = 1
                }
                self.addPhotoButton.alpha = 1
                }, completion: nil)
        }else{
            //            minX = view.getOffset()
            //            print(minX)
            UIView.animateWithDuration(0.6, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 5, options: .CurveEaseOut, animations: {
                view.imageView.transform = CGAffineTransformMakeScale(scale, scale)
                view.adjustScrollView()
                self.savingButton.alpha = 0
                self.addPhotoButton.alpha = 0
                }, completion: nil)
        }
    }
    var singleTap = UITapGestureRecognizer()
    override func viewDidLoad() {
        super.viewDidLoad()
        singleTap = UITapGestureRecognizer(target: self, action: "handleSingleTap:")
        singleTap.numberOfTapsRequired = 1
        
        
        self.view.layer.cornerRadius = 10
        self.scrollView.canCancelContentTouches = false
        self.scrollView.delaysContentTouches = false
        Label = UILabel(frame: CGRectMake(0,0,375,500))
        Label.textAlignment = .Center
        Label.font = UIFont(name: "Helvetica", size: 45)
        imagePicker.view.addSubview(Label)
        Label.alpha = 0.5
        self.Label.textColor = UIColor.whiteColor()
        Label.text = "请垂直手持设备"
        let aButtonRing = UIImageView(frame:CGRectMake(0,0,70,70))
        aButtonRing.image = UIImage(named: "cameraButtonRing.png")
        aButtonRing.center.x = self.view.center.x
        aButtonRing.frame.origin.y = 575
        imagePicker.view.addSubview(aButtonRing)
        aButton = UIButton(frame: CGRectMake(0,0,50,50))
        aButton.setBackgroundImage(UIImage(named: "cameraButtonHighlight.png"), forState: .Highlighted)
        aButton.setBackgroundImage(UIImage(named: "cameraButtonNormal.png"), forState: .Normal)
        aButton.setBackgroundImage(UIImage(named: "cameraButtonNormal.png"), forState: .Disabled)
        aButton.center.x = self.view.center.x
        aButton.frame.origin.y = 585
        aButton.layer.cornerRadius = 25
        aButton.layer.masksToBounds = true
        aButton.addTarget(self, action: "takephoto", forControlEvents: .TouchUpInside)
        imagePicker.view.addSubview(aButton)
        aButton.transform = CGAffineTransformMakeScale(0.3, 0.3)
        buttonLabel = UILabel(frame: CGRectMake(0,0,50,50))
        buttonLabel.textAlignment = .Center
        buttonLabel.font = UIFont(name: "Helvetica", size: 24)
        buttonLabel.textColor = UIColor.blackColor()
        aButton.addSubview(buttonLabel)
        
        
        circleView = UIButton(frame: CGRectMake(0,0,50,50))
        circleView.layer.cornerRadius = 25
        circleView.backgroundColor = UIColor.whiteColor()
        circleView.center.y = imagePicker.view.center.y - 83.5
        circleView.center.x = imagePicker.view.center.x
        
        
        circleViewBorder = UIView(frame: CGRectMake(0,0,60,60))
        circleViewBorder.layer.borderColor = CGColorCreate(CGColorSpaceCreateDeviceRGB(), [1,1,1,1])
        circleViewBorder.layer.borderWidth = 2
        circleViewBorder.layer.cornerRadius = 30
        circleViewBorder.center.x = imagePicker.view.center.x
        circleViewBorder.center.y = imagePicker.view.center.y - 83.5
        
        
        
        
        imagePicker.view.addSubview(circleView)
        imagePicker.view.addSubview(circleViewBorder)
        
        let cancelButton = UIButton(frame: CGRectMake(280,585,50,50))
        cancelButton.setImage(UIImage(named: "camera_cancel"), forState: .Normal)
        cancelButton.addTarget(self, action: "cancelCamera", forControlEvents: .TouchUpInside)
        cancelButton.tag = 400
        cancelButton.transform = CGAffineTransformMakeScale(0, 0)
        imagePicker.view.addSubview(cancelButton)
        
        
        blackLayer = UIView(frame: CGRectMake(0,0,750,1000))
        blackLayer.backgroundColor = UIColor.blackColor()
        blackLayer.tag = 300
        imagePicker.view.addSubview(blackLayer)
        blackLayer.alpha = 0
        
        tutorialView = UIImageView(image: UIImage(named: "tutorial"))
        self.view.addSubview(tutorialView)
        tutorialView.center.x = self.view.center.x
        tutorialView.frame.origin.y = 93
        
        self.addPhotoButton.setTitleColor(UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1), forState:.Normal)
        self.addPhotoButton.setTitleColor(UIColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1), forState:.Highlighted)
        self.addPhotoButton.setTitleColor(UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1), forState:.Disabled)
        self.addPhotoButton.setBackgroundImage(UIImage(named: "addButtonHighlight.png"), forState: .Highlighted)
        self.addPhotoButton.setBackgroundImage(UIImage(named: "addButtonNormal.png"), forState: .Normal)
        self.addPhotoButton.setTitle("  重新拍摄", forState: .Disabled)
        
        self.savingButton.setBackgroundImage(UIImage(named: "savingButtonHighlight.png"), forState: .Highlighted)
        self.savingButton.setBackgroundImage(UIImage(named: "savingButtonNormal.png"), forState: .Normal)
        self.savingButton.setTitleColor(UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1), forState:.Highlighted)
        self.savingButton.setTitleColor(UIColor(red: 1, green: 1, blue: 1, alpha: 1),
            forState:.Normal)
        self.savingButton.setImage(UIImage(named: "compose_savingbutton_background.png"), forState: .Normal)
        self.savingButton.setImage(UIImage(named: "compose_savingbutton_Highlight.png"), forState: .Highlighted)
        
        
        self.generateButton.setBackgroundImage(UIImage(named: "generateButtonNormal.png"), forState: .Normal)
        self.generateButton.setBackgroundImage(UIImage(named: "generateButtonHighlight.png"), forState: .Highlighted)
        self.generateButton.setTitleColor(UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1), forState:.Highlighted)
        self.generateButton.setTitleColor(UIColor(red: 1, green: 1, blue: 1, alpha: 1), forState:.Normal)
        self.generateButton.setImage(UIImage(named: "compose_generatebutton_Highlight.png"), forState:.Highlighted)
        self.generateButton.setImage(UIImage(named: "compose_generatebutton_Disable.png"), forState:.Disabled)
        self.generateButton.setTitleColor(UIColor(red: 1, green: 0.66, blue: 0.47, alpha: 1), forState:.Disabled)
        
        self.savingButton.layer.cornerRadius = 22
        self.generateButton.layer.cornerRadius = 22
        self.addPhotoButton.layer.cornerRadius = 22
        self.savingButton.layer.masksToBounds = true
        self.generateButton.layer.masksToBounds = true
        self.addPhotoButton.layer.masksToBounds = true
        
        self.addPhotoLeading.constant = self.view.center.x-self.addPhotoButton.frame.width*0.5-15
        self.generateButton.alpha = 0
        self.savingButton.alpha = 0
        
        if(self.imageArray.count<2){
            self.generateButton.enabled = false
        }
        
        self.scrollView.layer.cornerRadius = 8
        self.view.layer.cornerRadius = 8
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func rotateAccordingToDeviceMotionRotationRate(deviceMotion:CMDeviceMotion){
        let gravityX = deviceMotion.gravity.x
        let gravityY = deviceMotion.gravity.y
        let gravityZ = deviceMotion.gravity.z
        let zTheta = atan2(gravityZ,sqrt(gravityX*gravityX+gravityY*gravityY))/M_PI*180.0
        let xyTheta = atan2(gravityX,gravityY)/M_PI*180.0
        if Label.text == "拍摄"{
            if abs(zTheta) > 5 {
                Label.text = "请垂直手持设备"
                if imageArray.count < 1{
                    UIView.animateWithDuration(0.2, delay: 0.0, options: .CurveEaseOut, animations: {
                        self.aButton.transform = CGAffineTransformMakeScale(0.3, 0.3)
                        self.buttonLabel.transform = CGAffineTransformMakeScale(0.5, 0.5)
                        self.buttonLabel.alpha = 0
                        },completion:nil)
                    self.aButton.enabled = false
                }
            }
        }
        if Label.text == "请垂直手持设备"{
            if abs(zTheta) < 4 {
                self.Label.text = "拍摄"
                if imageArray.count < 1{
                    UIView.animateWithDuration(0.2, delay: 0.0, options: .CurveEaseOut,animations: {
                        self.aButton.transform = CGAffineTransformMakeScale(1, 1)
                        self.buttonLabel.transform = CGAffineTransformMakeScale(1, 1)
                        self.buttonLabel.alpha = 1
                        },completion:nil)
                    self.aButton.enabled = true
                }
                
            }
            
        }
        circleView.transform = CGAffineTransformMakeScale(CGFloat.init(abs(xyTheta)*0.0111 - 1), CGFloat.init(abs(xyTheta)*0.0111 - 1))
    }
    
    func rotateAccordingToGyroRotationRate(gyroData:CMGyroData){
        // Why the y value not x or z.
        /*
        *    y:
        *      Y-axis rotation rate in radians/second. The sign follows the right hand
        *      rule (i.e. if the right hand is wrapped around the Y axis such that the
        *      tip of the thumb points toward positive Y, a positive rotation is one
        *      toward the tips of the other 4 fingers).
        */
        let gyroX = gyroData.rotationRate.x
        let gyroY = gyroData.rotationRate.y
        if imageArray.count > 0 {
            circleView.center.x += CGFloat.init(gyroY - 0.0051)*5
            circleView.center.y += CGFloat.init(gyroX + 0.0271)*5
            
            if abs(circleView.center.x-imagePicker.view.center.x) < 3 && abs(circleView.center.y-(imagePicker.view.center.y - 83.5)) < 3 && abs(circleView.frame.height - 50) < 2{
                UIView.animateWithDuration(0.2, delay: 0.0, options: .CurveEaseOut, animations: {
                    self.circleView.backgroundColor = UIColor.orangeColor()
                    self.circleViewBorder.layer.borderColor = CGColorCreate(CGColorSpaceCreateDeviceRGB(), [1,0.5,0,1])
                    },completion:nil)
                UIView.animateWithDuration(0.2, delay: 0.0, options: .CurveEaseOut, animations: {
                    self.aButton.transform = CGAffineTransformMakeScale(1, 1)
                    self.buttonLabel.transform = CGAffineTransformMakeScale(1, 1)
                    self.buttonLabel.alpha = 1
                    },completion:nil)
                self.aButton.enabled = true
            }else if abs(circleView.center.x-imagePicker.view.center.x) > 5 || abs(circleView.center.y-(imagePicker.view.center.y - 83.5)) > 5 || abs(circleView.frame.height - 50) > 3{
                UIView.animateWithDuration(0.2, delay: 0.0, options: .CurveEaseOut, animations: {
                    self.circleView.backgroundColor = UIColor.whiteColor()
                    self.circleViewBorder.layer.borderColor = CGColorCreate(CGColorSpaceCreateDeviceRGB(), [1,1,1,1])
                    },completion:nil)
                UIView.animateWithDuration(0.2, delay: 0.0, options: .CurveEaseOut, animations: {
                    self.aButton.transform = CGAffineTransformMakeScale(0.3, 0.3)
                    self.buttonLabel.transform = CGAffineTransformMakeScale(0.5, 0.5)
                    self.buttonLabel.alpha = 0
                    },completion:nil)
                self.aButton.enabled = false
            }
            
        }
        
    }
    
    func startMonitoring(){
        self.motionManager.deviceMotionUpdateInterval = 0.01
        if !self.motionManager.deviceMotionActive && self.motionManager.deviceMotionAvailable{
            
            self.motionManager.startDeviceMotionUpdatesToQueue(NSOperationQueue.currentQueue()!, withHandler: { (CMDeviceMotion, NSError) -> Void in
                self.rotateAccordingToDeviceMotionRotationRate(CMDeviceMotion!)
            })
        }
        else{
            print("No Availabel deviceMotion")
        }
        
        self.motionManager.gyroUpdateInterval = 0.01
        if !self.motionManager.gyroActive && self.motionManager.gyroAvailable{
            
            self.motionManager.startGyroUpdatesToQueue(NSOperationQueue.currentQueue()!, withHandler: { (CMGyroData, NSError) -> Void in
                self.rotateAccordingToGyroRotationRate(CMGyroData!)
            })
        }
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        imagePicker.delegate = self
    }
    
    
    
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        UIView.animateWithDuration(0.3, delay: 0.0, options: .CurveEaseOut,animations: {
            self.circleViewBorder.alpha = 0.8
            self.circleView.alpha = 0.8
            self.circleView.center.x += 110
            self.Label.alpha = 0
            },completion:nil)
        if imageArray.count == 0{
            self.tutorialView.hidden = true
            self.addPhotoButton.titleLabel?.text = "  拍摄照片"
        }
        if imageArray.count == 1{
            let button = imagePicker.view.viewWithTag(400)
            UIView.animateWithDuration(0.2, delay: 0.0, options: .CurveEaseOut,animations: {
                button?.transform = CGAffineTransformMakeScale(1, 1)
                },completion:nil)
        }
        if var pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            UIGraphicsBeginImageContext(pickedImage.size)
            pickedImage.drawInRect(CGRectMake(0,0,pickedImage.size.width,pickedImage.size.height))
            pickedImage.imageWithRenderingMode(.Automatic)
            pickedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            let newPickedImage = imageCompressWithSimple(pickedImage,scale: 0.4)
            self.imageArray.append(newPickedImage)
            self.countLabel.text = String(imageArray.count)
            self.imageStrLabel.text = ("照片数量")
        }
        buttonLabel.transform = CGAffineTransformMakeScale(0.5, 0.5)
        buttonLabel.text = String(imageArray.count)
        UIView.animateWithDuration(0.1, delay: 0.0, options:.CurveEaseOut, animations: {
            self.buttonLabel.transform = CGAffineTransformMakeScale(1, 1)
            },completion: nil)
        imagePicker.sourceType = .Camera
    }
    
    func cancelCamera(){
        self.addPhotoButton.titleLabel?.text = "  重新拍摄"
        let view = self.scrollView.viewWithTag(100)
        view?.removeFromSuperview()
        self.motionManager.stopDeviceMotionUpdates()
        self.motionManager.stopGyroUpdates()
        dismissViewControllerAnimated(true, completion: {
            if(self.imageArray.count<2){
                self.generateButton.enabled = false
                UIView.animateWithDuration(0.4, delay: 0, options: .CurveEaseOut, animations: {
                    self.addPhotoLeading.constant = self.view.center.x-self.addPhotoButton.frame.width*0.5-15
                    self.generateButton.alpha = 0
                    self.savingButton.alpha = 0
                    self.view.layoutIfNeeded()
                    }, completion: nil)
            }
            else{
                self.generateButton.enabled = true
                UIView.animateWithDuration(0.4, delay: 0, options: .CurveEaseOut, animations: {
                    self.addPhotoLeading.constant = 0
                    self.generateButton.alpha = 1
                    self.savingButton.alpha = 0
                    self.view.layoutIfNeeded()
                    }, completion: nil)
            }
        })
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        
        if(imageArray.count == 0){
            self.tutorialView.hidden = false
            let view = self.scrollView.viewWithTag(100)
            view?.removeFromSuperview()
            self.addPhotoButton.titleLabel?.text = "  再次拍摄"
        }
        dismissViewControllerAnimated(true, completion: {
            self.generateButton.enabled = false
            UIView.animateWithDuration(0.4, delay: 0, options: .CurveEaseOut, animations: {
                self.addPhotoLeading.constant = self.view.center.x-self.addPhotoButton.frame.width*0.5-15
                self.generateButton.alpha = 0
                self.savingButton.alpha = 0
                self.view.layoutIfNeeded()
                }, completion: nil)
        })
    }
    
    
    var stitchedImage = UIImage()
    func stitch() {
        self.spinner.startAnimating()
        self.addPhotoButton.enabled = false
        self.generateButton.enabled = false
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)){
            
            self.stitchedImage = CVWrapper.processWithArray(self.imageArray) as UIImage
            
            dispatch_async(dispatch_get_main_queue()){
                let button = self.imagePicker.view.viewWithTag(400)
                UIView.animateWithDuration(0.2, delay: 0.0, options: .CurveEaseOut, animations: {
                    button?.transform = CGAffineTransformMakeScale(0, 0)
                    },completion:nil)
                NSLog("stichedImage %@", self.stitchedImage)
                self.stitchedImage = self.snapshot(self.stitchedImage)
                self.imageArray.removeAll()
                let motionView = PanoramaView(frame:self.scrollView.bounds)
                motionView.setImage(self.stitchedImage)
                motionView.tag = 100
                motionView.userInteractionEnabled = true
                motionView.addGestureRecognizer(self.singleTap)
                motionView.backgroundColor = UIColor.blackColor()
                self.scrollView.addSubview(motionView)
                self.generateButton.enabled = false
                UIView.animateWithDuration(0.4, delay: 0, options: .CurveEaseOut, animations: {
                    self.addPhotoLeading.constant = self.view.center.x-7.5
                    self.generateButton.alpha = 0
                    self.savingButton.alpha = 1
                    self.view.layoutIfNeeded()
                    }, completion: nil)
                self.spinner.stopAnimating()
                self.imageStrLabel.text = " "
                self.countLabel.text = " "
                self.buttonLabel.text = " "
                self.addPhotoButton.enabled = true
                self.generateButton.enabled = true
            }
        }
    }
    
    func imageCompressWithSimple(image: UIImage,scale: CGFloat) -> UIImage{
        let size = image.size
        let height = size.height
        let width = size.width
        let scaledHeight = height * scale
        let scaledWidth = width * scale
        UIGraphicsBeginImageContext(CGSize(width: scaledWidth, height: scaledHeight))
        image.drawInRect(CGRectMake(0,0,scaledWidth,scaledHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
        
    }
}
