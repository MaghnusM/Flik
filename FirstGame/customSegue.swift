//
//  customSegue.swift
//  FirstGame
//
//  Created by Maghnus Mareneck on 5/12/15.
//  Copyright (c) 2015 Maghnus Mareneck. All rights reserved.
//

import UIKit

class customSegue: UIStoryboardSegue {
   
    override func perform() {
        
        let sourceViewController = self.sourceViewController as! UIViewController
        let destinationViewController = self.destinationViewController as! UIViewController
        
        destinationViewController.view.removeFromSuperview()
        sourceViewController.presentViewController(destinationViewController, animated: false, completion: nil)
    }
    
}
