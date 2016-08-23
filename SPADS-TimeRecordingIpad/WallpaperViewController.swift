//
//  WallpaperViewController.swift
//  SPADS-TimeRecordingIpad
//
//  Created by BBaoBao on 7/13/15.
//  Copyright (c) 2015 buingocbao. All rights reserved.
//

import UIKit
import MediaPlayer
import AVFoundation

class WallpaperViewController: UIViewController, AVAudioPlayerDelegate {
    
    @IBOutlet weak var lbTime: UILabel!
    var moviePlayer : MPMoviePlayerController?
    var currentTime:NSDate = NSDate()
    var updateTimer:NSTimer = NSTimer()
    
    var updateMusicInfo:NSTimer = NSTimer()
    
    var managerArray:NSArray = NSArray()
    var isPlayMusicArray:[String] = [String]()
    
    var audioPlayer:AVAudioPlayer?

    override func viewDidLoad() {
        super.viewDidLoad()
        //playVideo()
        
        self.view.bringSubviewToFront(lbTime)
        updateTime()
        queryParseMethod()
        // Do any additional setup after loading the view.
    }
    
    func queryParseMethod() {
        print("Start query")
        
        //Get current day
        let date = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Hour, .Minute, .Day, .Month, .Year], fromDate: date)
        let day = String(components.day)
        let month = String(components.month)
        let year = String(components.year)
        
        let daymonthyear = "\(day)-\(month)-\(year)"
        //println(daymonthyear)
        
        let query = PFQuery(className: "TimeRecording").whereKey("Group", equalTo: "Manager").whereKey("Date", equalTo: daymonthyear)
        query.findObjectsInBackgroundWithBlock {
            (objects, error) -> Void in
            if error == nil {
                // The find succeeded.
                self.managerArray = objects!
                print("Successfully retrieved \(self.managerArray.count) manager.")
                // If have data (Boss arrived)
                if self.managerArray.count != 0 {
                    for manager in self.managerArray {
                        //MARK : check if played
                        if self.isPlayMusicArray.count != 0 {
                            let managerName = manager["Employee"] as! String
                            for playedManager in self.isPlayMusicArray {
                                if managerName != playedManager{
                                    self.playManagerMusic(manager)
                                }
                            }
                        } else {
                            self.playManagerMusic(manager)
                        }
                        
                    }
                }
            }
        }
        
        self.updateMusicInfo.invalidate()
        self.updateMusicInfo = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: Selector("queryParseMethod"), userInfo: nil, repeats: true)
    }
    
    func playManagerMusic(manager: AnyObject) {
        //MARK : Play Sound
        //let path = NSBundle.mainBundle().pathForResource("NotificationSound", ofType:"m4a")
        //let fileURL = NSURL(fileURLWithPath: path!)
        
        //var alertSound = NSURL(fileURLWithPath: "http://files.parsetfss.com/55126041-6549-4d86-8605-6a25be0c5983/tfss-8de1b1e6-d260-4f3e-970c-49140b7bf006-NotificationSound.m4a")
        let alertSound = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("NotificationSound", ofType: "m4a")!)
        do {
            //println(path)
        
            // Removed deprecated use of AVAudioSessionDelegate protocol
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        } catch _ {
        }
        do {
            try AVAudioSession.sharedInstance().setActive(true)
        } catch _ {
        }
        
        if let tempAudioPlayer = self.audioPlayer {
            if tempAudioPlayer.playing == true {
                
            } else {
                var error:NSError?
                do {
                    self.audioPlayer = try AVAudioPlayer(contentsOfURL: alertSound)
                } catch let error1 as NSError {
                    error = error1
                    self.audioPlayer = nil
                }
                self.audioPlayer!.prepareToPlay()
                self.audioPlayer!.play()
                self.audioPlayer!.numberOfLoops = 2
                
                //Mark as noticed
                let managerName = manager["Employee"] as! String
                self.isPlayMusicArray.append(managerName)
                print(self.isPlayMusicArray)
            }
        } else {
            var error:NSError?
            do {
                self.audioPlayer = try AVAudioPlayer(contentsOfURL: alertSound)
            } catch let error1 as NSError {
                error = error1
                self.audioPlayer = nil
            }
            self.audioPlayer!.prepareToPlay()
            self.audioPlayer!.play()
            self.audioPlayer!.numberOfLoops = 2
            
            //Mark as noticed
            let managerName = manager["Employee"] as! String
            self.isPlayMusicArray.append(managerName)
            print(self.isPlayMusicArray)
        }
    }
    
    func playVideo() {
        if let
            path = NSBundle.mainBundle().pathForResource("JapanIntroduction2", ofType:"mp4"),
            url = NSURL(fileURLWithPath: path),
            moviePlayer = MPMoviePlayerController(contentURL: url) {
                self.moviePlayer = moviePlayer
                moviePlayer.view.frame = self.view.bounds
                moviePlayer.prepareToPlay()
                moviePlayer.scalingMode = .AspectFill
                moviePlayer.repeatMode = MPMovieRepeatMode.One
                self.view.addSubview(moviePlayer.view)
        } else {
            debugPrint("Ops, something wrong when playing video")
        }
    }
    
    func updateTime() {
        updateTimer.invalidate()
        //updateTimer = nil
        
        currentTime = NSDate()
        let date = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Hour, .Minute, .Second, .Day, .Month, .Year], fromDate: date)
        let hour = String(components.hour)
        let minutes = String(components.minute)
        let second = String(components.second)
        lbTime.text = "\(hour):\(minutes):\(second)"
        
        updateTimer = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: Selector("updateTime"), userInfo: nil, repeats: true)
    }
    
    func setTabBarVisible(visible:Bool, animated:Bool) {
        
        //* This cannot be called before viewDidLayoutSubviews(), because the frame is not set before this time
        
        // bail if the current state matches the desired state
        if (tabBarIsVisible() == visible) { return }
        
        // get a frame calculation ready
        let frame = self.tabBarController?.tabBar.frame
        let height = frame?.size.height
        let offsetY = (visible ? -height! : height)
        
        // zero duration means no animation
        let duration:NSTimeInterval = (animated ? 0.3 : 0.0)
        
        //  animate the tabBar
        if frame != nil {
            UIView.animateWithDuration(duration) {
                self.tabBarController?.tabBar.frame = CGRectOffset(frame!, 0, offsetY!)
                return
            }
        }
    }
    
    func tabBarIsVisible() ->Bool {
        return self.tabBarController?.tabBar.frame.origin.y < CGRectGetMaxY(self.view.frame)
    }
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        setTabBarVisible(!tabBarIsVisible(), animated: true)
    }
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
        moviePlayer?.play()
    }
}
