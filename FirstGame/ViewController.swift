//
//  ViewController.swift
//  FirstGame
//
//  Created by Maghnus Mareneck on 3/16/15.
//  Copyright (c) 2015 Maghnus Mareneck. All rights reserved.
//

import UIKit
import iAd
import AVFoundation

class ViewController: UIViewController, ADBannerViewDelegate {
    
    var score = 0
    var rawScore = 1
    var highscore = 0
    var difficulty = 3.0
    
    var firstHighScore: Bool = true
    
    var elapsedTime:Double = 0
    var timer = NSTimer()
    var scoreTimer = NSTimer()
    
    var lastColor = 0
    var currentColor = 5
    var scoreSize: CGFloat = 60
    
    let fileManager = FileManager()
    var noAds: Bool?

    let BLUE = 0
    let GREEN = 1
    let RED = 2
    let ORANGE = 3
    
    var backgroundView = UIView()
    var arrow = UIImage(named: "arrow")
    
    var arrowHeight: CGFloat = 0
    var arrowWidth: CGFloat = 0
    var arrowWidthRatio: CGFloat = 0
    var arrowRatioHeightToWith:CGFloat = 0
    
    var bannerIsVisible: Bool = false
    
    var scoreOffsetRatio:CGFloat = 0
    var scoreOffset: CGFloat = 0
    
    let screen = UIScreen.mainScreen().bounds
    
    var musicIcon = UIButton.buttonWithType(UIButtonType.System) as! UIButton
    //var adBannerView = ADBannerView(frame: CGRect.zeroRect)
    
    func setupAudioPlayerWithFile(file: NSString, type: NSString) -> AVAudioPlayer {
        var path = NSBundle.mainBundle().pathForResource(file as String, ofType: type as String)
        var url = NSURL.fileURLWithPath(path!)
        
        var error: NSError?
        
        var audioPlayer: AVAudioPlayer?
        audioPlayer = AVAudioPlayer(contentsOfURL: url, error: &error)
        audioPlayer?.numberOfLoops = -1
        
        return audioPlayer!
    }
    
    @IBOutlet var mainView: UIView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        switch fileManager.readNoAds() {
        case 0:
            noAds = false
        case 1:
            noAds = true
        default:
            noAds = false
        }
        
        //println("no ads state: \(noAds)")
        
        let screen = UIScreen.mainScreen().bounds
        
        arrowWidthRatio = 170/375
        arrowWidth = arrowWidthRatio * screen.width
        arrowRatioHeightToWith = 185/170
        arrowHeight = arrowRatioHeightToWith * arrowWidth
        
        scoreOffsetRatio = 60/667
        scoreOffset = scoreOffsetRatio * screen.height
        
        firstHighScore = true
        
        scoreTimer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: Selector("incrementTime"), userInfo: nil, repeats: true)
        firstChangeColor()
        resetTimer()
        addBanner()
    }
    
    
    @IBAction func swipeUp(sender: UISwipeGestureRecognizer) {
        
        if (currentColor == BLUE) {
            rawScore++
            calculateScore()
            
            changeColor()
            resetTimer()
        } else {
            gameLost()
        }
        
    }
    
    @IBAction func swipeDown(sender: UISwipeGestureRecognizer) {
        
        if (currentColor == GREEN) {
            rawScore++
            calculateScore()
            
            changeColor()
            resetTimer()
        } else {
            gameLost()
        }
        
    }
    
    @IBAction func swipeLeft(sender: UISwipeGestureRecognizer) {
        
        if (currentColor == RED) {
            rawScore++
            calculateScore()
            
            changeColor()
            resetTimer()
        } else {
            gameLost()
        }
        
    }
    
    @IBAction func swipeRight(sender: UISwipeGestureRecognizer) {
        
        if (currentColor == ORANGE) {
            rawScore++
            calculateScore()
            
            changeColor()
            resetTimer()
        } else {
            gameLost()
        }

    }
    
    func firstChangeColor() {
        var c: Int = Int(arc4random_uniform(4)) // picks a random number 0-3
        var color : UIColor
        
        
        //takes the random number and uses it to pick a color
        switch c {
        case BLUE:
            color = UIColor(red: 0.15, green: 0.32, blue: 0.7, alpha: 1.0)
        case GREEN:
            color = UIColor(red: 0, green: 0.8, blue: 0.4, alpha: 1.0)
        case RED:
            color = UIColor(red: 1.0, green: 0.16, blue: 0.24, alpha: 1.0)
        case ORANGE:
            color = UIColor(red: 1.0, green: 0.43, blue: 0.2, alpha: 1.0)
        default:
            color = UIColor.whiteColor()
        }
        
        let screen = UIScreen.mainScreen().bounds // gets the constraints of the screen

        // creates a new view with the new color
        backgroundView = UIView(frame: CGRectMake(0, 0, screen.width, screen.height))
        backgroundView.backgroundColor = color
        mainView.addSubview(backgroundView)
        
        // create the score label
        var scoreLabel = UILabel()
        scoreLabel.text = "\(score)"
        scoreLabel.textColor = UIColor.whiteColor()
        scoreLabel.font = UIFont(name: "Avenir Black", size: scoreSize)
        backgroundView.addSubview(scoreLabel)
        scoreLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        // position the score label using constraints
        let labelCenterX = NSLayoutConstraint(item: scoreLabel, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: backgroundView, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0)
        backgroundView.addConstraint(labelCenterX)
        let labelBottomY = NSLayoutConstraint(item: scoreLabel, attribute: NSLayoutAttribute.TopMargin, relatedBy: NSLayoutRelation.Equal, toItem: backgroundView, attribute: NSLayoutAttribute.TopMargin, multiplier: 1, constant: scoreOffset) // sets the distance of the score label from the top
        backgroundView.addConstraint(labelBottomY)
        
        if(showInstructionClassic == true){
            showInstructions(backgroundView, scorePointSize: scoreLabel.font.pointSize)
        }
        
        var arrowView = UIImageView()
        arrowView.image = arrow
        arrowView.alpha = 1
        backgroundView.addSubview(arrowView)
        arrowView.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        positionArrow(arrowView)
        rotateArrow(arrowView, c: c)

        currentColor = c
        lastColor = c
        
    }
    
    func changeColor() {
        
        var c: Int = Int(arc4random_uniform(4)) // picks a random number 0-3
        var color : UIColor
        
        //make sure that it does not choose the same color twice in a row
        if (c == lastColor) {
            if (c < 3) {
                c++
            } else {
                c-=2
            }
        }
        
        //takes the random number and uses it to pick a color
        switch c {
        case BLUE:
            color = UIColor(red: 0.15, green: 0.32, blue: 0.7, alpha: 1.0)
        case GREEN:
            color = UIColor(red: 0, green: 0.8, blue: 0.4, alpha: 1.0)
        case RED:
            color = UIColor(red: 1.0, green: 0.16, blue: 0.24, alpha: 1.0)
        case ORANGE:
            color = UIColor(red: 1.0, green: 0.43, blue: 0.2, alpha: 1.0)
        default:
            color = UIColor.whiteColor()
        }
        
        let screen = UIScreen.mainScreen().bounds // gets the constraints of the screen
        
        var transform : CGAffineTransform // sets up the transform
        
        // sets the transform based on the color of the previous view
        switch lastColor {
        case BLUE:
            transform = CGAffineTransformMakeTranslation(0.0, -1 * screen.height)
        case GREEN:
            transform = CGAffineTransformMakeTranslation(0.0, screen.height)
        case RED:
            transform = CGAffineTransformMakeTranslation(-1 * screen.width, 0.0)
        case ORANGE:
            transform = CGAffineTransformMakeTranslation(screen.width, 0.0)
        default:
            transform = CGAffineTransformMakeTranslation(0.0, 0.0)
        }
        
        var prevBackgroundView = backgroundView
        
        // creates a new view with the new color and inserts it underneath
        backgroundView = UIView(frame: CGRectMake(0, 0, screen.width, screen.height))
        backgroundView.backgroundColor = color
        mainView.insertSubview(backgroundView, belowSubview: prevBackgroundView)
        
        var arrowView = UIImageView()
        arrowView.image = arrow
        arrowView.alpha = 1
        backgroundView.addSubview(arrowView)
        arrowView.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        var slideViewFrame : CGRect

        let centerX = screen.width / 2
        let centerY = screen.height / 2
        
        var slideViewTransform : CGRect
        
        switch c{
        case BLUE:
            slideViewFrame = CGRectMake(centerX - arrowWidth/2, centerY + arrowHeight/2, arrowWidth, 0)
            slideViewTransform = CGRectMake(centerX - arrowWidth/2, centerY + arrowHeight/2, arrowWidth, -arrowHeight)
        case GREEN:
            slideViewFrame = CGRectMake(centerX - arrowWidth/2, centerY - arrowHeight/2, arrowWidth, 0)
            slideViewTransform = CGRectMake(centerX - arrowWidth/2, centerY - arrowHeight/2, arrowWidth, arrowHeight)
        case ORANGE:
            slideViewFrame = CGRectMake(centerX - arrowHeight/2, centerY - arrowWidth/2, 0, arrowWidth)
            slideViewTransform = CGRectMake(centerX - arrowHeight/2, centerY - arrowWidth/2, arrowHeight, arrowWidth)
        case RED:
            slideViewFrame = CGRectMake(centerX + arrowHeight/2, centerY - arrowWidth/2, 0, arrowWidth)
            slideViewTransform = CGRectMake(centerX + arrowHeight/2, centerY - arrowWidth/2, -arrowHeight, arrowWidth)
        default:
            slideViewFrame = CGRectMake(0, 0, 0, 10)
            slideViewTransform = CGRectMake(0, 0, 0, 10)
        }
    
        var slideView = UIView(frame: slideViewFrame)
        slideView.backgroundColor = color
        backgroundView.addSubview(slideView)
        
        UIView.animateWithDuration(difficulty, delay: 0.0, options: UIViewAnimationOptions.AllowUserInteraction | UIViewAnimationOptions.AllowAnimatedContent, animations: {slideView.frame = slideViewTransform}, completion: nil)
        
        // create the score label
        var scoreLabel = UILabel()
        scoreLabel.text = "\(score)"
        scoreLabel.textColor = UIColor.whiteColor()
        scoreLabel.font = UIFont(name: "Avenir Black", size: scoreSize)
        backgroundView.addSubview(scoreLabel)
        scoreLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        // position the score label using constraints
        let labelCenterX = NSLayoutConstraint(item: scoreLabel, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: backgroundView, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0)
        backgroundView.addConstraint(labelCenterX)
        let labelBottomY = NSLayoutConstraint(item: scoreLabel, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: backgroundView, attribute: NSLayoutAttribute.TopMargin, multiplier: 1, constant: scoreOffset)
        backgroundView.addConstraint(labelBottomY)
        
        if(firstHighScore == true){
            checkHighscore(scoreLabel.font.pointSize)
        }
        
        positionArrow(arrowView)
        rotateArrow(arrowView, c: c) // rotates the arrow in the correct direction based on color

        // creates the animation for the previous view to move away and reveal the new view
        UIView.animateWithDuration(2.0, delay: 0.0, usingSpringWithDamping: 0.9, initialSpringVelocity: 5.0, options: nil, animations: {prevBackgroundView.transform = transform}, completion: nil)
        
        //mainView.backgroundColor = color //sets the background color to the random color
        currentColor = c
        lastColor = c
    }
    
    func gameLost() {
        self.performSegueWithIdentifier("game_over", sender: self)
    }
    
    func calculateScore() {
        score++
    }
    
    func incrementTime() {
        elapsedTime++
    }
    
    func getHighscore() {
        let fileManager = FileManager()
        highscore = fileManager.readClassicScore()
    }
    
    func positionArrow(arrowView: UIView) {
        
        // centers the arrow horizontally
        let centerX = NSLayoutConstraint(item: arrowView, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: backgroundView, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0)
        backgroundView.addConstraint(centerX)
        
        // centers the arrow vertically
        let centerY = NSLayoutConstraint(item: arrowView, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: backgroundView, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0)
        backgroundView.addConstraint(centerY)
        
        // sets the dimmensions of the arrow to height = 135, widht (point to end) = 150
        let views = ["arrowView" : arrowView]
        let constrainWidth = NSLayoutConstraint.constraintsWithVisualFormat("H:[arrowView(\(arrowWidth))]", options: NSLayoutFormatOptions(0), metrics: nil, views: views)
        backgroundView.addConstraints(constrainWidth)
        let constrainHeight = NSLayoutConstraint.constraintsWithVisualFormat("V:[arrowView(\(arrowHeight))]", options: NSLayoutFormatOptions(0), metrics: nil, views: views)
        backgroundView.addConstraints(constrainHeight)
        
    }
    
    func rotateArrow(arrowView: UIView, c: Int){
        // setup the rotation for the arrow
        let pi : CGFloat = 3.14159
        var arrowRotate : CGAffineTransform
        
        switch c {
        case BLUE:
            arrowRotate = CGAffineTransformMakeRotation(0)
        case GREEN:
            arrowRotate = CGAffineTransformMakeRotation(pi)
        case RED:
            arrowRotate = CGAffineTransformMakeRotation(3*pi/2)
        case ORANGE:
            arrowRotate = CGAffineTransformMakeRotation(pi/2)
        default:
            arrowRotate = CGAffineTransformMakeRotation(0)
        }
        
        arrowView.transform = arrowRotate // rotates the arrow in the correct direction based on color
    }
    
    func checkHighscore(scorePointSize: CGFloat) {
        getHighscore()
        if score > highscore {
            firstHighScore = false
            let highscoreLabel = UILabel()
            highscoreLabel.text = "NEW BEST"
            
            highscoreLabel.textColor = UIColor.whiteColor()
            highscoreLabel.font = UIFont(name: "Avenir Black", size: 35)
            mainView.addSubview(highscoreLabel)
            highscoreLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
            let screen = UIScreen.mainScreen().bounds
            
            let labelCenterX = NSLayoutConstraint(item: highscoreLabel, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: mainView, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0)
            mainView.addConstraint(labelCenterX)
            
            let labelPosY = NSLayoutConstraint(item: highscoreLabel, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: mainView, attribute: NSLayoutAttribute.TopMargin, multiplier: 1, constant: (scoreOffset + scorePointSize/2) + ((screen.height/2 - arrowWidth/2)-(scoreOffset + scorePointSize/2))/2)
            mainView.addConstraint(labelPosY)
            
            highscoreLabel.transform = CGAffineTransformMakeScale(0.1, 0.1)
            
            UIView.animateWithDuration(0.4, delay: 0.0, options: nil, animations: {highscoreLabel.transform = CGAffineTransformMakeScale(1, 1)}, completion: { (v: Bool) in
                UIView.animateWithDuration(0.4, delay: 0.2, options: nil, animations: {highscoreLabel.alpha = 0}, completion: { (v: Bool) in
                    highscoreLabel.removeFromSuperview()
                })
            })
            
        }
    }
    
    func resetTimer() {
        difficulty = 0.7 + 10/pow(Double(rawScore), 1.5)
        timer.invalidate()
        timer = NSTimer.scheduledTimerWithTimeInterval(difficulty, target: self, selector: Selector("gameLost"), userInfo: nil, repeats: false)
        elapsedTime = 0
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var nextView: GameOverViewController = segue.destinationViewController as! GameOverViewController
        nextView.score = self.score
        nextView.mode = 1
        nextView.initialColor = currentColor
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
   
    func showInstructions(backgroundView: UIView, scorePointSize: CGFloat){
        //println("I'm here")
        showInstructionClassic = false
        let instructions = UILabel()
        instructions.text = "FLIK ANYWHERE"
        let screen = UIScreen.mainScreen().bounds
        let instructionOffset: CGFloat = (scoreOffset + scorePointSize/2) + ((screen.height/2 - arrowWidth/2)-(scoreOffset + scorePointSize/2))/2
        
        instructions.textColor = UIColor.whiteColor()
        instructions.font = UIFont(name: "Avenir Black", size: 25)
        backgroundView.addSubview(instructions)
        instructions.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        let labelCenterX = NSLayoutConstraint(item: instructions, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: backgroundView, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0)
        backgroundView.addConstraint(labelCenterX)
        
        let labelPosY = NSLayoutConstraint(item: instructions, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: backgroundView, attribute: NSLayoutAttribute.TopMargin, multiplier: 1, constant: instructionOffset)
            backgroundView.addConstraint(labelPosY)
    }
    
    
    func addBanner() {
        self.canDisplayBannerAds = false
    }

    func addMusicIcon() {
        musicIcon.frame = CGRectMake((screen.width - 50),20,25,25)
        musicIcon.setImage(UIImage(named: "musicIcon"), forState: .Normal)
        musicIcon.tintColor = UIColor.whiteColor()
        musicIcon.addTarget(self, action: "toggleMusic:", forControlEvents: UIControlEvents.TouchDown)
        mainView.addSubview(musicIcon)
        
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







