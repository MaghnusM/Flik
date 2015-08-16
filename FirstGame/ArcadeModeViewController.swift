//
//  ArcadeModeViewController.swift
//  FirstGame
//
//  Created by Maghnus Mareneck on 5/11/15.
//  Copyright (c) 2015 Maghnus Mareneck. All rights reserved.
//

import UIKit
import iAd
import AVFoundation

class ArcadeModeViewController: UIViewController,  ADBannerViewDelegate {

    var mainView = UIView()
    
    var score = 0
    var rawScore = 1
    var difficulty = 3.0
    var highscore = 0
    var firstHighScore: Bool = true
    
    var elapsedTime:Double = 0
    var timer = NSTimer()
    var scoreTimer = NSTimer()
    
    var lastColor = 0
    var currentColor = 5
    
    var noAds: Bool?
    let fileManager = FileManager()
    
    var award: String = ""
    var awardSize: CGFloat = 0
    
    let BLUE = 0
    let GREEN = 1
    let RED = 2
    let ORANGE = 3
    
    var bannerIsVisible: Bool = false
    
    var arrowHeight: CGFloat = 0
    var arrowWidth: CGFloat = 0
    var arrowWidthRatio: CGFloat = 0
    var arrowRatioHeightToWith:CGFloat = 0
    
    var scoreOffsetRatio:CGFloat = 0
    var scoreOffset: CGFloat = 0
    var scoreSize: CGFloat = 60
    
    var countText = UILabel()
    var backgroundView = UIView()
    var arrow = UIImage(named: "arrow")
    
    let screen = UIScreen.mainScreen().bounds
    
    //var adBannerView = ADBannerView(frame: CGRect.zeroRect)
    
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
        
        switch fileManager.readNoAds() {
        case 0:
            noAds = false
        case 1:
            noAds = true
        default:
            noAds = false
        }
        
        if(noAds == false) {
            self.canDisplayBannerAds = true
        }

        let screen = UIScreen.mainScreen().bounds
        
        mainView.frame = CGRectMake(0, 0, screen.width, screen.height)
        view.addSubview(mainView)
        
        firstHighScore = true
        
        arrowWidthRatio = 170/375
        arrowWidth = arrowWidthRatio * screen.width
        arrowRatioHeightToWith = 185/170
        arrowHeight = arrowRatioHeightToWith * arrowWidth
        
        scoreOffsetRatio = 60/667
        scoreOffset = scoreOffsetRatio * screen.height
        
        scoreTimer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: Selector("incrementTime"), userInfo: nil, repeats: true)
        firstChangeColor()
        resetTimer()
        getHighscore()
        
        addBanner()
    }
    
    func firstChangeColor() {
        var c = Int(arc4random_uniform(4)) // picks a random number 0-3
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
        scoreLabel.font = UIFont(name: "Avenir", size: scoreSize)
        backgroundView.addSubview(scoreLabel)
        scoreLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        // position the score label using constraints
        let labelCenterX = NSLayoutConstraint(item: scoreLabel, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: backgroundView, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0)
        backgroundView.addConstraint(labelCenterX)
        let labelBottomY = NSLayoutConstraint(item: scoreLabel, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: backgroundView, attribute: NSLayoutAttribute.TopMargin, multiplier: 1, constant: scoreOffset) // sets the distance of the score label from the top
        backgroundView.addConstraint(labelBottomY)
        
        if(showInstructionArcade == true){
            showInstructions(backgroundView, scorePointSize: scoreLabel.font.pointSize)
        }
        
        var arrowView = UIImageView()
        arrowView.image = arrow
        arrowView.alpha = 1
        backgroundView.addSubview(arrowView)
        arrowView.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        positionArrow(arrowView, randomX: (screen.width/2), randomY: (screen.height/2))
        rotate(arrowView, c: c)
        
        currentColor = c
        lastColor = c
        
        createTransparentBox(backgroundView, randomX: (screen.width/2), randomY: (screen.height/2), c: c)
    }
    
    func changeColor() {
        var c = Int(arc4random_uniform(4)) // picks a random number 0-3
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
        var slideViewTransform : CGRect
        
        // create the score label
        var scoreLabel = UILabel()
        scoreLabel.text = "\(score)"
        scoreLabel.textColor = UIColor.whiteColor()
        scoreLabel.font = UIFont(name: "Avenir", size: scoreSize)
        backgroundView.addSubview(scoreLabel)
        scoreLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        var randomX = arrowHeight/2 + CGFloat(arc4random_uniform(UInt32(UIScreen.mainScreen().bounds.width - arrowHeight)))
        var randomY = scoreOffset + scoreLabel.font.pointSize + arrowHeight/2 + CGFloat(arc4random_uniform(UInt32(UIScreen.mainScreen().bounds.height - scoreOffset - arrowHeight - scoreLabel.font.pointSize - 50)))
        
        switch c {
        case BLUE:
            slideViewFrame = CGRectMake(randomX - arrowWidth/2, randomY + arrowHeight/2, arrowWidth, 0)
            slideViewTransform = CGRectMake(randomX - arrowWidth/2, randomY + arrowHeight/2, arrowWidth, -arrowHeight)
        case GREEN:
            slideViewFrame = CGRectMake(randomX - arrowWidth/2, randomY - arrowHeight/2, arrowWidth, 0)
            slideViewTransform = CGRectMake(randomX - arrowWidth/2, randomY - arrowHeight/2, arrowWidth, arrowHeight)
        case ORANGE:
            slideViewFrame = CGRectMake(randomX - arrowHeight/2, randomY - arrowWidth/2, 0, arrowWidth)
            slideViewTransform = CGRectMake(randomX - arrowHeight/2, randomY - arrowWidth/2, arrowHeight, arrowWidth)
        case RED:
            slideViewFrame = CGRectMake(randomX + arrowHeight/2, randomY - arrowWidth/2, 0, arrowWidth)
            slideViewTransform = CGRectMake(randomX + arrowHeight/2, randomY - arrowWidth/2, -arrowHeight, arrowWidth)
        default:
            slideViewFrame = CGRectMake(0, 0, 0, 10)
            slideViewTransform = CGRectMake(0, 0, 0, 10)
        }
        
        var slideView = UIView(frame: slideViewFrame)
        slideView.backgroundColor = color
        backgroundView.addSubview(slideView)
        
        UIView.animateWithDuration(difficulty, delay: 0.0, options: UIViewAnimationOptions.AllowUserInteraction | UIViewAnimationOptions.AllowAnimatedContent, animations: {slideView.frame = slideViewTransform}, completion: nil)
        
        
        
        // position the score label using constraints
        let labelCenterX = NSLayoutConstraint(item: scoreLabel, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: backgroundView, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0)
        backgroundView.addConstraint(labelCenterX)
        let labelBottomY = NSLayoutConstraint(item: scoreLabel, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: backgroundView, attribute: NSLayoutAttribute.TopMargin, multiplier: 1, constant: scoreOffset)
        backgroundView.addConstraint(labelBottomY)
        
        if(firstHighScore == true){
            checkHighscore(scoreLabel.font.pointSize)
        }
        
        
        positionArrow(arrowView, randomX: randomX, randomY: randomY)
        rotate(arrowView, c: c)
        
        
        
        // creates the animation for the previous view to move away and reveal the new view
        UIView.animateWithDuration(2.0, delay: 0.0, usingSpringWithDamping: 0.9, initialSpringVelocity: 5.0, options: nil, animations: {prevBackgroundView.transform = transform}, completion: nil)


        currentColor = c
        lastColor = c
        
/* // adds another view on top for the gestures to occur on
        var swipeView = UIView(frame: CGRectMake(0, 0, screen.width, screen.height))
        swipeView.userInteractionEnabled = true
        mainView.insertSubview(swipeView, aboveSubview: slideView)
*/
        
        annotate(backgroundView, scorePointSize: scoreLabel.font.pointSize)
        
        createTransparentBox(backgroundView, randomX: randomX, randomY: randomY, c: c)

    }
    
    func calculateScore() {
        //println (elapsedTime/10)
        if((elapsedTime/10) <= 0.4){
            award = "5"
            awardSize = scoreSize/2
            score += 5
        }
        
        else if((elapsedTime/10) <= 0.5){
            award = "2"
            awardSize = scoreSize/3
            score += 2
        }
        
        else{
            award = ""
            score += 1
        }
            
        //score += Int(5.0*(difficulty - elapsedTime/10.0)/difficulty)
    }
    
    func incrementTime() {
        elapsedTime++
        //setCountLabel()
    }
    
    func gameLost() {
        //println("GAME OVER")
        self.performSegueWithIdentifier("game_over", sender: self)
    }
    
    func resetTimer() {
        //println("raw score: \(rawScore)")
        difficulty = 0.8 + 10/pow(Double(rawScore), 1.25)
        timer.invalidate()
        timer = NSTimer.scheduledTimerWithTimeInterval(difficulty, target: self, selector: Selector("gameLost"), userInfo: nil, repeats: false)
        elapsedTime = 0
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var nextView: GameOverViewController = segue.destinationViewController as! GameOverViewController
        nextView.score = self.score
        nextView.mode = 2
        nextView.initialColor = currentColor
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func annotate(background: UIView, scorePointSize: CGFloat){
        let screen = UIScreen.mainScreen().bounds
        var annotateAward = UILabel()
        var annotateOffset: CGFloat = -((screen.size.height/2 - scoreOffset)/2)
        var annotateSize: CGFloat = awardSize
        mainView.addSubview(annotateAward)
        annotateAward.font = UIFont(name: "Avenir Black", size: annotateSize)
        annotateAward.textColor = UIColor.whiteColor()
        annotateAward.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        annotateAward.lineBreakMode = NSLineBreakMode.ByWordWrapping
        annotateAward.numberOfLines = 2
        annotateAward.textAlignment = NSTextAlignment.Center
        
        
        if(award == "2")
        {
            annotateAward.text = "QUICK\n+\(award)"
        }
        if(award == "5"){
            annotateAward.text = "INSANE\n+\(award)"
        }
        
        //if(award == "5"){
            //annotateAward.text = "INSANE: +\(award)"
        //}
        
        let labelCenterX = NSLayoutConstraint(item: annotateAward, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: backgroundView, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: -screen.width/4)
        mainView.addConstraint(labelCenterX)
        let labelBottomY = NSLayoutConstraint(item: annotateAward, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: backgroundView, attribute: NSLayoutAttribute.TopMargin, multiplier: 1, constant: scoreOffset)
        mainView.addConstraint(labelBottomY)
        
        annotateAward.transform = CGAffineTransformMakeScale(0.1, 0.1)
        
        UIView.animateWithDuration(0.4, delay: 0.0, options: nil, animations: {annotateAward.transform = CGAffineTransformMakeScale(1, 1)}, completion: { (v: Bool) in UIView.animateWithDuration(0.4, delay: 0.0, options: nil, animations: {annotateAward.alpha = 0}, completion: { (v: Bool) in
                annotateAward.removeFromSuperview()
            })

    })

}
    func positionArrow(arrowView: UIView, randomX: CGFloat, randomY: CGFloat){
        
        // randomizes the arrow horizontally
        let centerX = NSLayoutConstraint(item: arrowView, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: backgroundView, attribute: NSLayoutAttribute.Left, multiplier: 1, constant: randomX)
        backgroundView.addConstraint(centerX)
        
        // randomizes the arrow vertically
        let centerY = NSLayoutConstraint(item: arrowView, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: backgroundView, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: randomY)
        backgroundView.addConstraint(centerY)
        
        // sets the dimensions of the arrow to width = 185, height = 200
        let views = ["arrowView" : arrowView]
        let constrainWidth = NSLayoutConstraint.constraintsWithVisualFormat("H:[arrowView(\(arrowWidth))]", options: NSLayoutFormatOptions(0), metrics: nil, views: views)
        backgroundView.addConstraints(constrainWidth)
        let constrainHeight = NSLayoutConstraint.constraintsWithVisualFormat("V:[arrowView(\(arrowHeight))]", options: NSLayoutFormatOptions(0), metrics: nil, views: views)
        backgroundView.addConstraints(constrainHeight)

    }
    
    func rotate(view: UIView, c: Int){
        // setup the rotation for the arrow
        let pi : CGFloat = 3.14159
        var rotate : CGAffineTransform
        
        switch c {
        case BLUE:
            rotate = CGAffineTransformMakeRotation(0)
        case GREEN:
            rotate = CGAffineTransformMakeRotation(pi)
        case RED:
            rotate = CGAffineTransformMakeRotation(3*pi/2)
        case ORANGE:
            rotate = CGAffineTransformMakeRotation(pi/2)
        default:
            rotate = CGAffineTransformMakeRotation(0)
        }
        
        view.transform = rotate // rotates the arrow in the correct
        
    }
    
    func getHighscore() {
        let fileManager = FileManager()
        highscore = fileManager.readArcadeScore()
    }
    
    func createSwipeRecognizers(view: UIView, c: Int){
        
        let downSwipe = UISwipeGestureRecognizer()
        let upSwipe = UISwipeGestureRecognizer()
        let leftSwipe = UISwipeGestureRecognizer()
        let rightSwipe = UISwipeGestureRecognizer()
        
        downSwipe.addTarget(self, action: Selector("swipedDown:"))
        upSwipe.addTarget(self, action: Selector("swipedUp:"))
        rightSwipe.addTarget(self, action: Selector("swipedRight:"))
        leftSwipe.addTarget(self, action: Selector("swipedLeft:"))
        
        upSwipe.direction = .Up
        rightSwipe.direction = .Right
        downSwipe.direction = .Down
        leftSwipe.direction = .Left
        
        view.userInteractionEnabled = true

        view.addGestureRecognizer(downSwipe)
        view.addGestureRecognizer(leftSwipe)
        view.addGestureRecognizer(upSwipe)
        view.addGestureRecognizer(rightSwipe)
        
        
    }
    
    func swipedLeft(sender: UISwipeGestureRecognizer){
        print("swipe left")
        if (currentColor == RED) {
            rawScore++
            calculateScore()
            changeColor()
            resetTimer()
        } else {
            gameLost()
        }
    }

    func swipedRight(sender: UISwipeGestureRecognizer){
        print("swipe right")
        if (currentColor == ORANGE) {
            rawScore++
            calculateScore()
            changeColor()
            resetTimer()
        } else {
            gameLost()
        }
    }
    
    func swipedUp(sender: UISwipeGestureRecognizer){
        print("swipe up")
        if (currentColor == BLUE) {
            rawScore++
            calculateScore()
            changeColor()
            resetTimer()
        } else {
            gameLost()
        }
    }
    
    func swipedDown(sender: UISwipeGestureRecognizer){
        print("swipe down")
        if (currentColor == GREEN) {
            rawScore++
            calculateScore()
            changeColor()
            resetTimer()
        } else {
            gameLost()
        }
    }
    
    func checkHighscore(scorePointSize: CGFloat) {
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
            
            highscoreLabel.transform = CGAffineTransformMakeScale(0.1, 0.1)
            
            UIView.animateWithDuration(0.4, delay: 0.0, options: nil, animations: {highscoreLabel.transform = CGAffineTransformMakeScale(1, 1)}, completion: { (v: Bool) in
                UIView.animateWithDuration(0.4, delay: 0.2, options: nil, animations: {highscoreLabel.alpha = 0}, completion: { (v: Bool) in
                    highscoreLabel.removeFromSuperview()
                })
            })
            
        }
    }
    
    func showInstructions(backgroundView: UIView, scorePointSize: CGFloat){
        //println("I'm here")
        showInstructionArcade = false
        let instructions = UILabel()
        instructions.text = "FLIK ON THE ARROW"
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
    
    func createTransparentBox(backgroundView: UIView, randomX: CGFloat, randomY: CGFloat, c: Int){
        
        var boxFrame: CGRect
        
        switch c {
        case BLUE:
            boxFrame = CGRectMake(randomX - arrowWidth/2, randomY + arrowHeight/2, arrowWidth, -arrowHeight)
        case GREEN:
            boxFrame = CGRectMake(randomX - arrowWidth/2, randomY - arrowHeight/2, arrowWidth, arrowHeight)
        case ORANGE:
            boxFrame = CGRectMake(randomX - arrowHeight/2, randomY - arrowWidth/2, arrowHeight, arrowWidth)
        case RED:
            boxFrame = CGRectMake(randomX + arrowHeight/2, randomY - arrowWidth/2, -arrowHeight, arrowWidth)
        default:
            boxFrame = CGRectMake(0,0,0,0)
        }
        
        var boxView = UIView(frame: boxFrame)
        boxView.backgroundColor = UIColor.clearColor()
        backgroundView.addSubview(boxView)
        
        createSwipeRecognizers(boxView, c: c)

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




