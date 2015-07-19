//
//  FileManager.swift
//  FirstGame
//
//  Created by Maghnus Mareneck on 3/17/15.
//  Copyright (c) 2015 Maghnus Mareneck. All rights reserved.
//

import Foundation

class FileManager {
    
    let classicFileName = "classicHighscore.txt"
    let classicPath : String
    
    let arcadeFileName = "arcadeHighscore.txt"
    let arcadePath : String
    
    let noAdsName = "noAds.txt"
    let noAdsPath : String
    
    init() {
        let dirPaths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let dir = dirPaths[0] as! String
        
        classicPath = dir + "/" + classicFileName
        arcadePath = dir + "/" + arcadeFileName
        noAdsPath = dir + "/" + noAdsName
        
        //println(classicPath)
        //println(noAdsPath)
    }
    
    func writeScore(score:Int, mode:Int) {
        
        let s = String(score)
        
        if mode == 1 { // classic
            s.writeToFile(classicPath, atomically: false, encoding: NSUTF8StringEncoding, error: nil)
        } else { // arcade
            s.writeToFile(arcadePath, atomically: false, encoding: NSUTF8StringEncoding, error: nil)
        }
        
    }
    
    func noAds() {
        let s = String(1)
        s.writeToFile(noAdsPath, atomically: false, encoding: NSUTF8StringEncoding, error: nil)
    }
    
    func justMakeItFalse() {
        let s = String(0)
        s.writeToFile(noAdsPath, atomically: false, encoding: NSUTF8StringEncoding, error: nil)
    }
    
    func readClassicScore() -> Int {
        checkFile() //ensures that the file exists
        
        var s = String(contentsOfFile: classicPath, encoding: NSUTF8StringEncoding, error: nil)! // reads the contents of the file

        s = s.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) //removes any whitespace characters that prevent converting the string to an int

        return s.toInt()! //converts the string to an int and returns it
    }
    
    func readArcadeScore() -> Int {
        checkFile()
        
        var s = String(contentsOfFile: arcadePath, encoding: NSUTF8StringEncoding, error: nil)! // reads the contents of the file
        s = s.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) //removes any whitespace characters that prevent converting the string to an int
        
        return s.toInt()!
    }
    
    func readNoAds() -> Int {
        checkFile()
        
        var s = String(contentsOfFile: noAdsPath, encoding: NSUTF8StringEncoding, error: nil)! // reads the contents of the file
        s = s.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) //removes any whitespace characters that prevent converting the string to an int
        return s.toInt()!
    }
    
    func checkFile() {
        let manager = NSFileManager.defaultManager()
        //println(path)
        
        if (!manager.fileExistsAtPath(classicPath)) {
            let s = "0"
            s.writeToFile(classicPath, atomically: true, encoding: NSUTF8StringEncoding, error: nil)
        }
        
        if (!manager.fileExistsAtPath(arcadePath)) {
            let s = "0"
            s.writeToFile(arcadePath, atomically: true, encoding: NSUTF8StringEncoding, error: nil)
        }
        
        if(!manager.fileExistsAtPath(noAdsPath)) {
            let s = "0"
            s.writeToFile(noAdsPath, atomically: true, encoding: NSUTF8StringEncoding, error: nil)
        }
    }
    
}