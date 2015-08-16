//
//  GameOverViewController.swift
//  FirstGame
//
//  Created by Maghnus Mareneck on 3/17/15.
//  Copyright (c) 2015 Maghnus Mareneck. All rights reserved.
//


import UIKit
import iAd
import AVFoundation
import GameKit
import Foundation
import StoreKit

class GameOverViewController: UIViewController, ADBannerViewDelegate, GKGameCenterControllerDelegate {
    
    var score : Int!
    var highscore: Int!
    var mode : Int!
    var initialColor : Int!
    var appID = 1000536418
    
    var scoreLabel = UILabel()
    var highscoreLabel = UILabel()
    
    let classicArrow = UIImage(named: "ClassicArrow")
    let arcadeArrow = UIImage(named: "ArcadeArrow")
    let classicArrowView = UIImageView()
    let arcadeArrowView = UIImageView()
    
    var timer = NSTimer()
    var count = 0
    
    let fileManager = FileManager()
    
    var mainView = UIView()
    
    var bannerIsVisible: Bool = false
    
    var scoreOffsetRatio:CGFloat = 0
    var scoreOffset: CGFloat = 0
    
    var arrowHeight: CGFloat = 0
    var arrowWidth: CGFloat = 0
    var arrowWidthRatio: CGFloat = 0
    var arrowRatioHeightToWith:CGFloat = 0
    
    let screen = UIScreen.mainScreen().bounds
    
    var swipeUpController = UISwipeGestureRecognizer()
    var swipeDownController = UISwipeGestureRecognizer()
    
    var musicIcon = UIButton.buttonWithType(UIButtonType.System) as! UIButton
    
    func setupAudioPlayerWithFile(file: NSString, type: NSString) -> AVAudioPlayer {
        var path = NSBundle.mainBundle().pathForResource(file as String, ofType: type as String)
        var url = NSURL.fileURLWithPath(path!)
        
        var error: NSError?
        
        var audioPlayer: AVAudioPlayer?
        audioPlayer = AVAudioPlayer(contentsOfURL: url, error: &error)
        audioPlayer?.numberOfLoops = -1
        
        return audioPlayer!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.canDisplayBannerAds = true
        ViewController().firstHighScore = true
        
        mainView.frame = CGRectMake(0, 0, screen.width, screen.height)
        view.addSubview(mainView)
        
        highscoreLabel.alpha = 0
        classicArrowView.alpha = 0
        arcadeArrowView.alpha = 0
        
        arrowWidthRatio = 170/375
        arrowWidth = arrowWidthRatio * screen.width
        arrowRatioHeightToWith = 185/170
        arrowHeight = arrowRatioHeightToWith * arrowWidth
        
        scoreOffsetRatio = 30/667
        scoreOffset = scoreOffsetRatio * screen.height
        
        swipeUpController.addTarget(self, action: "classicSegue")
        swipeDownController.addTarget(self, action: "arcadeSegue")
        swipeDownController.enabled = false
        swipeUpController.enabled = false
        view.addGestureRecognizer(swipeUpController)
        view.addGestureRecognizer(swipeDownController)
        
        var c : UIColor
        switch initialColor {
        case 1:
            c = UIColor(red: 0, green: 0.8, blue: 0.4, alpha: 1.0)
        case 2:
            c = UIColor(red: 1.0, green: 0.16, blue: 0.24, alpha: 1.0)
        case 3:
            c = UIColor(red: 1.0, green: 0.43, blue: 0.2, alpha: 1.0)
        case 4:
            c = UIColor(red: 0.15, green: 0.32, blue: 0.7, alpha: 1.0)
        default:
            c = UIColor(red: 0.15, green: 0.32, blue: 0.7, alpha: 1.0)
        }
        
        mainView.backgroundColor = c
        timer = NSTimer.scheduledTimerWithTimeInterval(1.5, target: self, selector: Selector("changeBackground"), userInfo: nil, repeats: true)

        
        scoreLabel.text = "\(score)"
        
        scoreLabel.textColor = UIColor.whiteColor()
        scoreLabel.font = UIFont(name: "Avenir Black", size: 60)
        scoreLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        mainView.addSubview(scoreLabel)
        
        // position the score label using constraints
        let labelCenterX = NSLayoutConstraint(item: scoreLabel, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: mainView, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0)
        mainView.addConstraint(labelCenterX)
        
        let labelCenterY = NSLayoutConstraint(item: scoreLabel, attribute: NSLayoutAttribute.TopMargin, relatedBy: NSLayoutRelation.Equal, toItem: mainView, attribute: NSLayoutAttribute.TopMargin, multiplier: 1, constant: scoreOffset)
        mainView.addConstraint(labelCenterY)
        classicArrowView.image = classicArrow
        arcadeArrowView.image = arcadeArrow
        addMusicIcon()
        addEndGameOptionButton(buttonTitle: "RATE", xOffset: (-screen.width/4), yOffset: (arrowHeight/2.2 + arrowHeight))
        addEndGameOptionButton(buttonTitle: "MORE GAMES", xOffset: (screen.width/4), yOffset: (arrowHeight/2.2 + arrowHeight))
        addEndGameOptionButton(buttonTitle: "SHARE", xOffset: (-screen.width/4), yOffset: (arrowHeight/2))
        
        //GAME CENTER
        authenticateLocalPlayer()
    }

    override func viewDidAppear(animated: Bool) {
        let screen = UIScreen.mainScreen().bounds
        setUpArrows()
        positionAndSetUpHighScore()
        
        UIView.animateWithDuration(0.75, delay: 0.2, options: nil, animations: {
            let translate = CGAffineTransformMakeTranslation(0, ((screen.height/2) - self.scoreOffset/* * mult!*/)/1.5 - (self.scoreLabel.font.lineHeight/2.7))
            let scale = CGAffineTransformMakeScale(1.5, 1.5)
            
            self.scoreLabel.transform = CGAffineTransformConcat(translate, scale)
            }, completion: {finished in self.highscoreFadeIns() })

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func changeBackground() {
        if count < 4 {
            count++
        } else {
            count = 1
        }
        
        switch count {
        case 1:
            UIView.animateWithDuration(1.5, delay: 0.0, options: (UIViewAnimationOptions.AllowUserInteraction), animations: {self.mainView.backgroundColor = UIColor(red: 0, green: 0.8, blue: 0.4, alpha: 1.0)}, completion: nil)
        case 2:
            UIView.animateWithDuration(1.5, delay: 0.0, options: (UIViewAnimationOptions.AllowUserInteraction), animations: {self.mainView.backgroundColor = UIColor(red: 1.0, green: 0.43, blue: 0.2, alpha: 1.0)}, completion: nil)
        case 3:
            UIView.animateWithDuration(1.5, delay: 0.0, options: (UIViewAnimationOptions.AllowUserInteraction), animations: {self.mainView.backgroundColor = UIColor(red: 1.0, green: 0.16, blue: 0.24, alpha: 1.0)}, completion: nil)
        case 4:
            UIView.animateWithDuration(1.5, delay: 0.0, options: (UIViewAnimationOptions.AllowUserInteraction), animations: {self.mainView.backgroundColor = UIColor(red: 0.15, green: 0.32, blue: 0.7, alpha: 1.0)}, completion: nil)
        default:
            mainView.backgroundColor = UIColor(red: 0.15, green: 0.32, blue: 0.7, alpha: 1.0)
        }
        
    }
    
    func highscoreFadeIns(){
        
        UIView.animateWithDuration(0.5, animations: {
            self.highscoreLabel.alpha = 1.0}, completion: {(value: Bool) in self.arrowsFadeIns()}
        )
    }
    
    func arrowsFadeIns(){
        
        let screen = UIScreen.mainScreen().bounds
        self.createUpTransparentBox(mainView, randomX: (screen.width/2 - self.arrowWidth/2), randomY: (screen.height/2 - self.arrowHeight/2.2 - self.arrowHeight))
        self.createDownTransparentBox(mainView, randomX: (screen.width/2 - self.arrowWidth/2), randomY: screen.height/2 + self.arrowHeight/2.2)
        
        UIView.animateWithDuration(1.0, animations: {
            for innerView in self.mainView.subviews {
                let alphaView = innerView as! UIView
                alphaView.alpha = 1
            }
            
            }, completion: { (value: Bool) in
                self.swipeUpController.enabled = true
                self.swipeDownController.enabled = true
        })
    }
    
    func setUpArrows(){
        
        let screen = UIScreen.mainScreen().bounds
        
        mainView.addSubview(classicArrowView)
        classicArrowView.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        mainView.addSubview(arcadeArrowView)
        arcadeArrowView.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        
        let classicView = ["classicArrowView" : classicArrowView]
        let arcadeView = ["arcadeArrowView" : arcadeArrowView]
        
        let constrainWidthClassic = NSLayoutConstraint.constraintsWithVisualFormat("H:[classicArrowView(\(arrowWidth))]", options: NSLayoutFormatOptions(0), metrics: nil, views: classicView)
        let constrainHeightClassic = NSLayoutConstraint.constraintsWithVisualFormat("V:[classicArrowView(\(arrowHeight))]", options: NSLayoutFormatOptions(0), metrics: nil, views: classicView)
        
        classicArrowView.addConstraints(constrainWidthClassic)
        classicArrowView.addConstraints(constrainHeightClassic)
        
        //sets the size of both arrows
        let constrainWidthArcade = NSLayoutConstraint.constraintsWithVisualFormat("H:[arcadeArrowView(\(arrowWidth))]", options: NSLayoutFormatOptions(0), metrics: nil, views: arcadeView)
        let constrainHeightArcade = NSLayoutConstraint.constraintsWithVisualFormat("V:[arcadeArrowView(\(arrowHeight))]", options: NSLayoutFormatOptions(0), metrics: nil, views: arcadeView)
        
        arcadeArrowView.addConstraints(constrainWidthArcade)
        arcadeArrowView.addConstraints(constrainHeightArcade)
        
        //centers both arrows horizontally
        let classicArrowCenterX = NSLayoutConstraint(item: classicArrowView, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: mainView, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0)
        let arcadeArrowCenterX = NSLayoutConstraint(item: arcadeArrowView, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: mainView, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0)
        mainView.addConstraint(classicArrowCenterX)
        mainView.addConstraint(arcadeArrowCenterX)
        
        //positions both arrows vertically (space between dependent on arrowHeight)
        let classicArrowCenterY = NSLayoutConstraint(item: classicArrowView, attribute: NSLayoutAttribute.BottomMargin, relatedBy: NSLayoutRelation.Equal, toItem: mainView, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: -arrowHeight/2.2)
        let arcadeArrowCenterY = NSLayoutConstraint(item: arcadeArrowView, attribute: NSLayoutAttribute.TopMargin, relatedBy: NSLayoutRelation.Equal, toItem: mainView, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: arrowHeight/2.2)
        mainView.addConstraint(classicArrowCenterY)
        mainView.addConstraint(arcadeArrowCenterY)
        
    }
    
    func positionAndSetUpHighScore(){
        if mode == 1 {
            if (score > fileManager.readClassicScore()) {
                fileManager.writeScore(score, mode: 1)
            }
            
            highscore = fileManager.readClassicScore()
            highscoreLabel.text = "CLASSIC BEST: \(highscore)"
            
        } else {
            if (score > fileManager.readArcadeScore()) {
                fileManager.writeScore(score, mode: 2)
            }
            
            highscore = fileManager.readArcadeScore()
            highscoreLabel.text = "ARCADE BEST: \(highscore)"
        }
        highscoreLabel.font = UIFont(name: "Avenir Black", size: 20)
        highscoreLabel.textColor = UIColor.whiteColor()
        highscoreLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        mainView.addSubview(highscoreLabel)
        
        let labelBottomX = NSLayoutConstraint(item: highscoreLabel, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: mainView, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0)
        mainView.addConstraint(labelBottomX)
        let labelBottomY = NSLayoutConstraint(item: highscoreLabel, attribute: NSLayoutAttribute.TopMargin, relatedBy: NSLayoutRelation.Equal, toItem: arcadeArrowView, attribute: NSLayoutAttribute.TopMargin, multiplier: 1, constant: -40)
        mainView.addConstraint(labelBottomY)
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
        //println("DID CLASSIC NOW")
        self.performSegueWithIdentifier("classic_segue", sender: self)
    }
    
    func arcadeSegue() {
        self.performSegueWithIdentifier("arcade_segue", sender: self)
    }
    
    func addEndGameOptionButton(#buttonTitle: String, xOffset: CGFloat, yOffset: CGFloat) {
        var optionButton = UIButton.buttonWithType(UIButtonType.System) as! UIButton
        optionButton.addTarget(self, action: "linkHandler:", forControlEvents: UIControlEvents.TouchDown)
        mainView.addSubview(optionButton)
        optionButton.alpha = 0
        optionButton.setTranslatesAutoresizingMaskIntoConstraints(false)
        optionButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        let optionButtonX = NSLayoutConstraint(item: optionButton, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: mainView, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: xOffset)
        let optionButtonY = NSLayoutConstraint(item: optionButton, attribute: NSLayoutAttribute.BottomMargin, relatedBy: NSLayoutRelation.Equal, toItem: mainView, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: yOffset)
        optionButton.setTitle(buttonTitle, forState: .Normal)
        optionButton.titleLabel!.font! = UIFont(name: "Avenir Black", size: 22.5)!
        mainView.addConstraint(optionButtonX)
        mainView.addConstraint(optionButtonY)
    }
    
    func addMusicIcon() {
        musicIcon.frame = CGRectMake((screen.width - 50),20,25,25)
        musicIcon.setImage(UIImage(named: "musicIcon"), forState: .Normal)
        musicIcon.tintColor = UIColor.whiteColor()
        musicIcon.addTarget(self, action: "toggleMusic:", forControlEvents: UIControlEvents.TouchDown)
        mainView.addSubview(musicIcon)
        musicIcon.alpha = 0
    }
    
    func linkHandler(sender: UIButton) {
        if let title = sender.currentTitle {
            println("sender current title is : \(title)")
            if sender.currentTitle == "RATE" {
                UIApplication.sharedApplication().openURL(NSURL(string : "itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=\(appID)&onlyLatestVersion=true&pageNumber=0&sortOrdering=1)")!)
            } else if sender.currentTitle == "MORE GAMES" {
                UIApplication.sharedApplication().openURL(NSURL(string : "https://itunes.apple.com/us/artist/maghnus-mareneck/id1000536417")!)
            } else if sender.currentTitle == "SHARE" {
                shareHighscore(highscore)
            }

        }
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
   
    override func viewWillDisappear(animated: Bool) {
    }
    
    func authenticateLocalPlayer(){
        
        var localPlayer = GKLocalPlayer.localPlayer()
        
        localPlayer.authenticateHandler = {(viewController, error) -> Void in
            
            if (viewController != nil) {
                self.presentViewController(viewController, animated: true, completion: nil)
            }
                
            else {
                println((GKLocalPlayer.localPlayer().authenticated))
            }
        }
    }
    
    func shareHighscore(score:Int) {
        
        //check if user is signed in
        if GKLocalPlayer.localPlayer().authenticated {
            var scoreReporter = GKScore(leaderboardIdentifier: "global_highscores") //leaderboard id here
            scoreReporter.value = Int64(score) //score variable here (same as above)
            var scoreArray: [GKScore] = [scoreReporter]
            
            GKScore.reportScores(scoreArray, withCompletionHandler: {(error : NSError!) -> Void in
                if error != nil {
                    println("error")
                }
            })
        }
        showLeaderboard()
    }
    
    func showLeaderboard() {
        var gc : GKGameCenterViewController = GKGameCenterViewController()
        gc.gameCenterDelegate = self
        //var vc = self.mainView.window?.rootViewController
        self.view.window?.rootViewController?.presentViewController(gc, animated: true, completion: nil)
    }
    
    func gameCenterViewControllerDidFinish(gameCenterViewController: GKGameCenterViewController!) {
        gameCenterViewController.dismissViewControllerAnimated(true, completion: nil)
        
    }
}


    
    



