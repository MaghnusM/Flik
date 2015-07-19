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
import Foundation
import StoreKit

class GameOverViewController: UIViewController, ADInterstitialAdDelegate, ADBannerViewDelegate, SKPaymentTransactionObserver, SKProductsRequestDelegate {
    
    var score : Int!
    var mode : Int!
    var initialColor : Int!
    
    var noAdsIcon = UIButton.buttonWithType(UIButtonType.System) as! UIButton
    
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var highscoreLabel: UILabel!
    
    let classicArrow = UIImage(named: "ClassicArrow")
    let arcadeArrow = UIImage(named: "ArcadeArrow")
    let classicArrowView = UIImageView()
    let arcadeArrowView = UIImageView()
    
    var interstitialAd:  ADInterstitialAd!
    var interstitialAdView: UIView = UIView()
    
    var closeButton = UIButton.buttonWithType(UIButtonType.System) as! UIButton
    
    var timer = NSTimer()
    var count = 0
    
    let fileManager = FileManager()
    
    var bannerIsVisible: Bool = false
    //var adBannerView = ADBannerView(frame: CGRect.zeroRect)
    
    var scoreOffsetRatio:CGFloat = 0
    var scoreOffset: CGFloat = 0
    
    var arrowHeight: CGFloat = 0
    var arrowWidth: CGFloat = 0
    var arrowWidthRatio: CGFloat = 0
    var arrowRatioHeightToWith:CGFloat = 0
    
    var product: SKProduct?
    var productID = "com.thewhateverlabs.Flik.noads"
    
    var noAds: Bool?
    
    let screen = UIScreen.mainScreen().bounds
    
    @IBOutlet var swipeUpController: UISwipeGestureRecognizer!
    @IBOutlet var swipeDownController: UISwipeGestureRecognizer!
    
    @IBOutlet var mainView: UIView!
    
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
        
        ViewController().firstHighScore = true
        
        //let appdelegate = UIApplication.sharedApplication().delegate
          //  as! AppDelegate
        
        // appdelegate.homeViewController = self
        
        switch fileManager.readNoAds() {
        case 0:
            noAds = false
        case 1:
            noAds = true
        default:
            noAds = false
        }
        
        highscoreLabel.alpha = 0
        classicArrowView.alpha = 0
        arcadeArrowView.alpha = 0
        
        let screen = UIScreen.mainScreen().bounds
        arrowWidthRatio = 170/375
        arrowWidth = arrowWidthRatio * screen.width
        arrowRatioHeightToWith = 185/170
        arrowHeight = arrowRatioHeightToWith * arrowWidth
        
        scoreOffsetRatio = 30/667
        scoreOffset = scoreOffsetRatio * screen.height
        
        self.swipeDownController.enabled = false
        self.swipeUpController.enabled = false
        
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
        //mainView.backgroundColor = UIColor(red: 0.777, green: 0.777, blue: 0.777, alpha: 1.0)
        timer = NSTimer.scheduledTimerWithTimeInterval(1.5, target: self, selector: Selector("changeBackground"), userInfo: nil, repeats: true)
        
        var highscore : Int
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
        
        scoreLabel.text = "\(score)"
        highscoreLabel.font = UIFont(name: "Avenir Black", size: 20)
        
        scoreLabel.textColor = UIColor.whiteColor()
        scoreLabel.font = UIFont(name: "Avenir Black", size: 60)
        scoreLabel.setTranslatesAutoresizingMaskIntoConstraints(false)

        scoreLabel.frame = CGRectMake(0, screen.height/4, 100, 100)
        
        // position the score label using constraints
        let labelCenterX = NSLayoutConstraint(item: scoreLabel, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: mainView, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0)
        mainView.addConstraint(labelCenterX)
        
        let labelCenterY = NSLayoutConstraint(item: scoreLabel, attribute: NSLayoutAttribute.TopMargin, relatedBy: NSLayoutRelation.Equal, toItem: mainView, attribute: NSLayoutAttribute.TopMargin, multiplier: 1, constant: scoreOffset)
        mainView.addConstraint(labelCenterY)
        
        classicArrowView.image = classicArrow
        arcadeArrowView.image = arcadeArrow
        /*
        if(noAds == false) {
            addBanner()
        }
*/
        addMusicIcon()
        if(noAds == false) {
            addNoAdsIcon()
        }
        
        //buyStation.viewDidLoad()
        getProductInfo()
        
        

    }
    
    
    @IBAction func restart(sender: AnyObject) {
        
    }
    
    
    // happens as soon as view appears
    override func viewDidAppear(animated: Bool) {
        //println("at load: \(intermitAdPull)")
        if(noAds == false) {
            if(intermitAdPull! == 2) {
                loadInterstitialAd()
                intermitAdPull = 1
            }
        
            else {
                intermitAdPull = intermitAdPull! + 1
                //println("after increment: \(intermitAdPull)")
            }
        }
        
        /*
        if(intAdLoadedOnce == false) {
            loadInterstitialAd()
            intAdLoadedOnce = true
        }
*/
        let screen = UIScreen.mainScreen().bounds
        setUpArrows()
        positionHighScore()
        
        let mult: CGFloat?
        
        if(noAds == false) {
            mult = 2
        }
        
        else {
            mult = 0
        }
        
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
        
        //setUpArrows()
        //positionHighScore()
        
    }
    
    func highscoreFadeIns(){
        
        UIView.animateWithDuration(0.5, animations: {
            self.highscoreLabel.alpha = 1.0}, completion: {(value: Bool) in self.arrowsFadeIns()}
        )
    }
    
    func arrowsFadeIns(){
        
        let screen = UIScreen.mainScreen().bounds
        self.createUpTransparentBox(self.mainView, randomX: (screen.width/2 - self.arrowWidth/2), randomY: (screen.height/2 - self.arrowHeight/2.2 - self.arrowHeight))
        self.createDownTransparentBox(self.mainView, randomX: (screen.width/2 - self.arrowWidth/2), randomY: screen.height/2 + self.arrowHeight/2.2)
        
        UIView.animateWithDuration(1.0, animations: {
            self.classicArrowView.alpha = 1.0
            self.arcadeArrowView.alpha = 1.0
            self.musicIcon.alpha = 1
            self.noAdsIcon.alpha = 1
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
    
    func positionHighScore(){
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
    
     /*
    func addBanner() {
        
        self.canDisplayBannerAds = true
    }
    
        
        var adBannerView = ADBannerView(frame: CGRect.zeroRect)
        
        mainView.addSubview(adBannerView)
        
        
        adBannerView.setTranslatesAutoresizingMaskIntoConstraints(false)
        let views = ["adBannerView": adBannerView]
        
        let constrainWidthBanner = NSLayoutConstraint.constraintsWithVisualFormat("H:[adBannerView(\(screen.width))]", options: NSLayoutFormatOptions(0), metrics: nil, views: views)
        
        mainView.addConstraints(constrainWidthBanner)
        
        let bannerConstrainX = NSLayoutConstraint(item: adBannerView, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: mainView, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0)
        
        let bannerConstrainY = NSLayoutConstraint(item: adBannerView, attribute: NSLayoutAttribute.BottomMargin, relatedBy: NSLayoutRelation.Equal, toItem: mainView, attribute: NSLayoutAttribute.BottomMargin, multiplier: 1, constant: 0)
        
        mainView.addConstraint(bannerConstrainX)
        mainView.addConstraint(bannerConstrainY)

    }
*/
    
    func startBuyNoAds() {
        //println("tried to buy!")
        buyProduct()
        self.swipeDownController.enabled = false
        self.swipeUpController.enabled = false
        
    }
    
    func noAdsPurchased() {
        //println("no ads state1: \(noAds)")
        fileManager.noAds()
        self.swipeDownController.enabled = true
        self.swipeUpController.enabled = true
        
        println("They were bought!")
        //println("no ads state2: \(noAds)")
    }
    
    func addNoAdsIcon() {
        noAdsIcon.frame = CGRectMake(12.5, 30, 75, 14)
        noAdsIcon.setImage(UIImage(named: "no ads"), forState: .Normal)
        noAdsIcon.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        noAdsIcon.tintColor = UIColor.whiteColor()
        noAdsIcon.backgroundColor = UIColor.clearColor()
        noAdsIcon.layer.borderWidth = 0
        noAdsIcon.addTarget(self, action: "startBuyNoAds", forControlEvents: UIControlEvents.TouchDown)
        noAdsIcon.alpha = 0
        mainView.addSubview(noAdsIcon)
    }
    
    /*
    func bannerView(banner: ADBannerView!, didFailToReceiveAdWithError error: NSError!) {
        println("problem!")
        println(error)
        if (self.bannerIsVisible) {
            UIView.animateWithDuration(0.2, delay: 0.0, options: nil, animations: {
                self.adBannerView.alpha = 0 }, completion: nil)
            self.bannerIsVisible = false
        }
        
    }
*/
    /*
    func deleteNoAds() {
        noAdsIcon.enabled = false
        noAdsIcon.removeFromSuperview()
        noAdsIcon.backgroundColor = UIColor.clearColor()
        noAdsIcon.alpha = 0
        println("major problem")
    }
*/
    
    func loadInterstitialAd() {
        interstitialAd = ADInterstitialAd()
        interstitialAd.delegate = self
    }
    
    func interstitialAdWillLoad(interstitialAd: ADInterstitialAd!) {
        
    }
    
    func interstitialAdDidLoad(interstitialAd: ADInterstitialAd!) {
        interstitialAdView = UIView()  
        interstitialAdView.frame = self.view.bounds
        mainView.addSubview(interstitialAdView)
        
        interstitialAd.presentInView(interstitialAdView)
        UIViewController.prepareInterstitialAds()
        
        createCloseButton()
    }
    
    func interstitialAdActionDidFinish(interstitialAd: ADInterstitialAd!) {
        interstitialAdView.removeFromSuperview()
    }
    
    func interstitialAdActionShouldBegin(interstitialAd: ADInterstitialAd!, willLeaveApplication willLeave: Bool) -> Bool {
        return true
    }
    
    func interstitialAd(interstitialAd: ADInterstitialAd!, didFailWithError error: NSError!) {
        closeButton.removeFromSuperview()
        interstitialAdView.removeFromSuperview()
    }
    
    func interstitialAdDidUnload(interstitialAd: ADInterstitialAd!) {
        interstitialAdView.removeFromSuperview()
    }
    
    func createCloseButton() {
        closeButton.frame = CGRectMake(10, 10, 20, 20)
        closeButton.layer.cornerRadius = 10
        closeButton.setTitle("X", forState: .Normal)
        closeButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
        closeButton.backgroundColor = UIColor.whiteColor()
        closeButton.layer.borderColor = UIColor.blackColor().CGColor
        closeButton.layer.borderWidth = 0
        closeButton.addTarget(self, action: "closeAd:", forControlEvents: UIControlEvents.TouchDown)
        interstitialAdView.addSubview(closeButton)
    }
    
    func closeAd(sender: UIButton) {
        closeButton.removeFromSuperview()
        interstitialAdView.removeFromSuperview()
    }
    
    
    func addMusicIcon() {
        musicIcon.frame = CGRectMake((screen.width - 50),20,25,25)
        musicIcon.setImage(UIImage(named: "musicIcon"), forState: .Normal)
        musicIcon.tintColor = UIColor.whiteColor()
        musicIcon.addTarget(self, action: "toggleMusic:", forControlEvents: UIControlEvents.TouchDown)
        mainView.addSubview(musicIcon)
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
    
    
//-----------------------------------

    
    func getProductInfo()
    {
        if SKPaymentQueue.canMakePayments() {
            let request = SKProductsRequest(productIdentifiers:
                NSSet(objects: self.productID) as Set<NSObject>)
            request.delegate = self
            request.start()
        } else {
            //productDescription.text = "Please enable In App Purchase in Settings"
            let alert = UIAlertView()
            alert.title = "Fix Needed!"
            alert.message = "Please enable In App Purchase in Settings"
            alert.addButtonWithTitle("OK")
            alert.show()
        }
    }
    
    func productsRequest(request: SKProductsRequest!, didReceiveResponse response: SKProductsResponse!) {
        //println("ran products Request")
        
        var products = response.products
        
        if (products.count != 0) {
            product = products[0] as? SKProduct
            //productTitle.text = product!.localizedTitle
            //productDescription.text = product!.localizedDescription
            //println("\(product!.localizedTitle)")
            //println("\(product!.localizedDescription)")
            
        } else {
            //productTitle.text = "Product not found"
            //println("Product not found")
        }
        
        products = response.invalidProductIdentifiers
        
        for product in products
        {
            //println("Product not found: \(product)")
        }
    }
    
    func buyProduct() {
        //println("tried to buy 2!")
        //println("product id: \(productID)")
        SKPaymentQueue.defaultQueue().addTransactionObserver(self)
        let payment = SKPayment(product: product)
        //println("still a problem? 1")
        SKPaymentQueue.defaultQueue().addPayment(payment)
        //println("still a problem? 2")
    }
    
    func paymentQueue(queue: SKPaymentQueue!, updatedTransactions transactions: [AnyObject]!) {
        //println("ran payment que")
        
        for transaction in transactions as! [SKPaymentTransaction] {
            
            switch transaction.transactionState {
                
            case SKPaymentTransactionState.Purchased:
                self.unlockFeature()
                SKPaymentQueue.defaultQueue().finishTransaction(transaction)
                //println("already purchased?")
                
            case SKPaymentTransactionState.Failed:
                SKPaymentQueue.defaultQueue().finishTransaction(transaction)
                //println("failed")
            default:
                //println("did I break?")
                break
            }
        }
    }
    
    
    func unlockFeature() {
        //println("Item has been purchased")
        //let appdelegate = UIApplication.sharedApplication().delegate
            //as! AppDelegate
        
        //appdelegate.homeViewController!.noAdsPurchased()
        noAdsPurchased()
        
        //appdelegate.homeViewController!.noAdsIcon.enabled = false
        noAdsIcon.enabled = false
        //appdelegate.homeViewController!.noAdsIcon.alpha = 0
        noAdsIcon.alpha = 0
        //buyButton.enabled = false
        //productTitle.text = "Item has been purchased"
    }


//-----------------------------------

    override func viewWillDisappear(animated: Bool) {
        //adBannerView.removeFromSuperview()
        //adBannerView.delegate = nil
    }
    
    
    
    
}


