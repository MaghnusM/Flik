//
//  MainMenuViewController.swift
//  FirstGame
//
//  Created by Maghnus Mareneck on 3/19/15.
//  Copyright (c) 2015 Maghnus Mareneck. All rights reserved.
//

import UIKit
import iAd
import AVFoundation

var backgroundMusic = AVAudioPlayer()
var musicSwitch: Bool?


class MainMenuViewController: UIViewController {

    @IBOutlet var MainMenuView: UIView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var instructionsButton: UIButton!
    
    var timer = NSTimer()
    var count = 0
    
    var noAds: Bool?
    
    let classicArrow = UIImage(named: "ClassicArrow")
    let arcadeArrow = UIImage(named: "ArcadeArrow")
    let logoPicture = UIImage(named: "logo")
    
    let fileManager = FileManager()
    
    let classicArrowView = UIImageView()
    let arcadeArrowView = UIImageView()
    let logoPictureView = UIImageView()
    
    var arrowHeight: CGFloat = 0
    var arrowWidth: CGFloat = 0
    var logoWidth: CGFloat = 0
    var logoHeight: CGFloat = 0
    var logoRatioWidthToHeight: CGFloat = 0
    var arrowWidthRatio: CGFloat = 0
    var arrowRatioHeightToWith:CGFloat = 0
    
    var musicIcon = UIButton.buttonWithType(UIButtonType.System) as! UIButton
    
    let screen = UIScreen.mainScreen().bounds
    
    @IBOutlet var swipeUpController: UISwipeGestureRecognizer!
    @IBOutlet var swipeDownController: UISwipeGestureRecognizer!
    
    override func viewDidLoad() {
        showInstructionClassic = true
        showInstructionArcade = true
        
        super.viewDidLoad()
        
        switch fileManager.readNoAds() {
        case 0:
            noAds = false
        case 1:
            noAds = true
        default:
            noAds = false
        }
        
        self.swipeUpController.enabled = false
        self.swipeDownController.enabled = false
        
        logoPictureView.alpha = 0.0
        arcadeArrowView.alpha = 0.01
        classicArrowView.alpha = 0.01
        
        let screen = UIScreen.mainScreen().bounds
        
        logoRatioWidthToHeight = 1250/678
        arrowWidthRatio = 170/375
        arrowWidth = arrowWidthRatio * screen.width
        arrowRatioHeightToWith = 185/170
        arrowHeight = arrowRatioHeightToWith * arrowWidth
        logoHeight = arrowWidth * (2/3)
        logoWidth = logoRatioWidthToHeight * logoHeight
        
        MainMenuView.backgroundColor = UIColor(red: 1.0, green: 0.43, blue: 0.2, alpha: 1.0)
        timer = NSTimer.scheduledTimerWithTimeInterval(1.5, target: self, selector: Selector("changeBackground"), userInfo: nil, repeats: true)
        
        classicArrowView.image = classicArrow
        arcadeArrowView.image = arcadeArrow
        logoPictureView.image = logoPicture
        
        MainMenuView.addSubview(classicArrowView)
        classicArrowView.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        MainMenuView.addSubview(arcadeArrowView)
        arcadeArrowView.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        MainMenuView.addSubview(logoPictureView)
        logoPictureView.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        
        //sets the size of both arrows
        let classicView = ["classicArrowView" : classicArrowView]
        let arcadeView = ["arcadeArrowView" : arcadeArrowView]
        let logoView = ["logoPictureView" : logoPictureView]
        
        let constrainWidthClassic = NSLayoutConstraint.constraintsWithVisualFormat("H:[classicArrowView(\(arrowWidth))]", options: NSLayoutFormatOptions(0), metrics: nil, views: classicView)
        let constrainHeightClassic = NSLayoutConstraint.constraintsWithVisualFormat("V:[classicArrowView(\(arrowHeight))]", options: NSLayoutFormatOptions(0), metrics: nil, views: classicView)
        
        classicArrowView.addConstraints(constrainWidthClassic)
        classicArrowView.addConstraints(constrainHeightClassic)
        
        let constrainWidthArcade = NSLayoutConstraint.constraintsWithVisualFormat("H:[arcadeArrowView(\(arrowWidth))]", options: NSLayoutFormatOptions(0), metrics: nil, views: arcadeView)
        let constrainHeightArcade = NSLayoutConstraint.constraintsWithVisualFormat("V:[arcadeArrowView(\(arrowHeight))]", options: NSLayoutFormatOptions(0), metrics: nil, views: arcadeView)
        
        arcadeArrowView.addConstraints(constrainWidthArcade)
        arcadeArrowView.addConstraints(constrainHeightArcade)
        
        // constrain the size of the logo
        let constrainWidthLogo = NSLayoutConstraint.constraintsWithVisualFormat("H:[logoPictureView(\(logoWidth))]", options: NSLayoutFormatOptions(0), metrics: nil, views: logoView)
        let constrainHeightLogo = NSLayoutConstraint.constraintsWithVisualFormat("V:[logoPictureView(\(logoHeight))]", options: NSLayoutFormatOptions(0), metrics: nil, views: logoView)
        
        logoPictureView.addConstraints(constrainWidthLogo)
        logoPictureView.addConstraints(constrainHeightLogo)
        
        //centers both arrows and logo horizontally
        let classicArrowCenterX = NSLayoutConstraint(item: classicArrowView, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: MainMenuView, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0)
        let arcadeArrowCenterX = NSLayoutConstraint(item: arcadeArrowView, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: MainMenuView, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0)
        let logoCenterX = NSLayoutConstraint(item: logoPictureView, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: MainMenuView, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0)
        MainMenuView.addConstraint(classicArrowCenterX)
        MainMenuView.addConstraint(arcadeArrowCenterX)
        MainMenuView.addConstraint(logoCenterX)
        
        //positions both arrows and logo vertically (space between dependent on arrowHeight)
        let classicArrowCenterY = NSLayoutConstraint(item: classicArrowView, attribute: NSLayoutAttribute.BottomMargin, relatedBy: NSLayoutRelation.Equal, toItem: MainMenuView, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: -arrowHeight/2.2)
        let arcadeArrowCenterY = NSLayoutConstraint(item: arcadeArrowView, attribute: NSLayoutAttribute.TopMargin, relatedBy: NSLayoutRelation.Equal, toItem: MainMenuView, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: arrowHeight/2.2)
        let logoCenterY = NSLayoutConstraint(item: logoPictureView, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: MainMenuView, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0)
        MainMenuView.addConstraint(classicArrowCenterY)
        MainMenuView.addConstraint(arcadeArrowCenterY)
        MainMenuView.addConstraint(logoCenterY)
        
        // adds another view on top for the gestures to occur on
        var swipeView = UIView(frame: CGRectMake(0, 0, screen.width, screen.height))
        swipeView.userInteractionEnabled = true
        MainMenuView.insertSubview(swipeView, aboveSubview: MainMenuView)
        
        backgroundMusic = self.setupAudioPlayerWithFile("Soundtrack", type: "aif")
        
        backgroundMusic.play()
        musicSwitch = true
        
        addMusicIcon()
        
    }
    
    
    func setupAudioPlayerWithFile(file: NSString, type: NSString) -> AVAudioPlayer {
        var path = NSBundle.mainBundle().pathForResource(file as String, ofType: type as String)
        var url = NSURL.fileURLWithPath(path!)
        
        var error: NSError?
        
        var audioPlayer: AVAudioPlayer?
        audioPlayer = AVAudioPlayer(contentsOfURL: url, error: &error)
        audioPlayer?.numberOfLoops = -1
        
        return audioPlayer!
    }

    
    override func viewDidAppear(animated: Bool) {
        
        UIView.animateWithDuration(0.5, delay: 0.0, options: nil, animations: {
            self.logoPictureView.alpha = 1.0
            }, completion: nil)
            
            UIView.animateWithDuration(2.0, delay: 0.0, options: nil, animations: {
            self.classicArrowView.alpha = 1.0
                self.arcadeArrowView.alpha = 1.0
                self.musicIcon.alpha = 1.0}, completion: {(value: Bool) in
                self.swipeUpController.enabled = true
                self.swipeDownController.enabled = true
                self.createUpTransparentBox(self.MainMenuView, randomX: (self.screen.width/2 - self.arrowWidth/2), randomY: (self.screen.height/2 - self.arrowHeight/2.2 - self.arrowHeight))
                self.createDownTransparentBox(self.MainMenuView, randomX: (self.screen.width/2 - self.arrowWidth/2), randomY: self.screen.height/2 + self.arrowHeight/2.2)})
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func changeBackground() {
        if count < 4 {
            count++
        } else {
            count = 1
        }
        
        switch count { //green, orange, red, blue
        case 1:
            UIView.animateWithDuration(1.5, delay: 0.0, options: (UIViewAnimationOptions.AllowUserInteraction), animations: {self.MainMenuView.backgroundColor = UIColor(red: 1.0, green: 0.16, blue: 0.24, alpha: 1.0)}, completion: nil)
        case 2:
            UIView.animateWithDuration(1.5, delay: 0.0, options: (UIViewAnimationOptions.AllowUserInteraction), animations: {self.MainMenuView.backgroundColor = UIColor(red: 0.15, green: 0.32, blue: 0.7, alpha: 1.0)}, completion: nil)
        case 3:
            UIView.animateWithDuration(1.5, delay: 0.0, options: (UIViewAnimationOptions.AllowUserInteraction), animations: {self.MainMenuView.backgroundColor = UIColor(red: 0, green: 0.8, blue: 0.4, alpha: 1.0)}, completion: nil)

        case 4:
            UIView.animateWithDuration(1.5, delay: 0.0, options: (UIViewAnimationOptions.AllowUserInteraction), animations: {self.MainMenuView.backgroundColor = UIColor(red: 1.0, green: 0.43, blue: 0.2, alpha: 1.0)}, completion: nil)
        default:
            MainMenuView.backgroundColor = UIColor(red: 0.15, green: 0.32, blue: 0.7, alpha: 1.0)
        }
        
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func createUpTransparentBox(backgroundView: UIView, randomX: CGFloat, randomY: CGFloat){
        
        let screen = UIScreen.mainScreen().bounds
        
        var upBoxFrame: CGRect
        
        upBoxFrame = CGRectMake(randomX, randomY, arrowWidth, arrowHeight)
        
        var upBoxView = UIView(frame: upBoxFrame)
        upBoxView.backgroundColor = UIColor.clearColor()
        
        let touchUp = UITapGestureRecognizer()
        
        touchUp.addTarget(self, action: Selector("classicSegue"))
        upBoxView.userInteractionEnabled = true
        upBoxView.addGestureRecognizer(touchUp)
        
        backgroundView.addSubview(upBoxView)

    }
    
    func createDownTransparentBox(backgroundView: UIView, randomX: CGFloat, randomY: CGFloat){
        
        let screen = UIScreen.mainScreen().bounds
        
        var downBoxFrame: CGRect
        
        downBoxFrame = CGRectMake(randomX, randomY, arrowWidth, arrowHeight)
        
        var downBoxView = UIView(frame: downBoxFrame)
        downBoxView.backgroundColor = UIColor.clearColor()
        
        let touchDown = UITapGestureRecognizer()
        
        touchDown.addTarget(self, action: Selector("arcadeSegue"))
        downBoxView.userInteractionEnabled = true
        downBoxView.addGestureRecognizer(touchDown)
        
        backgroundView.addSubview(downBoxView)

    }
    
    func classicSegue() {
        self.performSegueWithIdentifier("classic_segue", sender: self)
    }
    
    func arcadeSegue() {
        self.performSegueWithIdentifier("arcade_segue", sender: self)
    }
    
    func addMusicIcon() {
        musicIcon.frame = CGRectMake((screen.width - 50),20,25,25)
        musicIcon.setImage(UIImage(named: "musicIcon"), forState: .Normal)
        musicIcon.tintColor = UIColor.whiteColor()
        musicIcon.addTarget(self, action: "toggleMusic:", forControlEvents: UIControlEvents.TouchDown)
        MainMenuView.addSubview(musicIcon)
        musicIcon.alpha = 0
    }
    
    
    func toggleMusic(sender: UIButton) {
        
        if(musicSwitch == true) {
            backgroundMusic.stop()
            musicSwitch = false
        }
            
        else {
            backgroundMusic = self.setupAudioPlayerWithFile("Soundtrack", type: "aif")
            backgroundMusic.play()
            musicSwitch = true
        }
    }

}

// Global variables

var showInstructionClassic: Bool?
var showInstructionArcade: Bool?



