//
//  VideoCellTableViewCell.swift
//  EditSoftDemo
//
//  Created by Saurabh Yadav on 31/01/17.
//  Copyright © 2017 Saurabh Yadav. All rights reserved.
//

import UIKit
import AVFoundation

class VideoCellTableViewCell: UITableViewCell {
    
    @IBOutlet weak var videoPlayerSuperView: UIView!
  
    var avPlayer: AVPlayer?
    var avPlayerLayer: AVPlayerLayer?
    var paused: Bool = false
    var videoPlayerItem: AVPlayerItem? = nil {
        didSet {
            /*
             If needed, configure player item here before associating it with a player.
             (example: adding outputs, setting text style rules, selecting media options)
             */
            avPlayer?.replaceCurrentItem(with: self.videoPlayerItem)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupMoviePlayer()
    }
    
    func setupMoviePlayer(){
        print("setup")
        self.avPlayer = AVPlayer.init(playerItem: self.videoPlayerItem)
        avPlayerLayer = AVPlayerLayer(player: avPlayer)
        avPlayerLayer?.videoGravity = AVLayerVideoGravity.resizeAspect
        avPlayer?.volume = 0
        avPlayer?.actionAtItemEnd = .none

        avPlayerLayer?.frame.size.width = self.frame.width
        self.frame.size.height = self.frame.width * 9 / 16
        avPlayerLayer?.frame.size.height = self.frame.width * 9 / 16
//        if UIScreen.main.bounds.width == 375 {
//
//            let widthRequired = self.frame.size.width - 20
//            avPlayerLayer?.frame = CGRect.init(x: 0, y: 0, width: widthRequired, height: widthRequired/1.78)
//            print(avPlayerLayer?.frame )
//        }else if UIScreen.main.bounds.width == 320 {
//            avPlayerLayer?.frame = CGRect.init(x: 0, y: 0, width: (self.frame.size.height - 120) * 1.78, height: self.frame.size.height - 120)
//            print(avPlayerLayer?.frame )
//        }else{
//            let widthRequired = self.frame.size.width
//            avPlayerLayer?.frame = CGRect.init(x: 0, y: 0, width: widthRequired, height: widthRequired/1.78)
//            print(avPlayerLayer?.frame )
//        }
        self.backgroundColor = .clear
        self.videoPlayerSuperView.layer.insertSublayer(avPlayerLayer!, at: 0)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.playerItemDidReachEnd(notification:)),
                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                               object: avPlayer?.currentItem)
//        self.avPlayer?.play()
    }
    
    func stopPlayback(){
        self.avPlayer?.pause()
    }
    
    func startPlayback(){
        print("self.avPlayer?.play()")
        self.avPlayer?.play()
    }
    
    // A notification is fired and seeker is sent to the beginning to loop the video again
    @objc func playerItemDidReachEnd(notification: Notification) {
        let p: AVPlayerItem = notification.object as! AVPlayerItem
        p.seek(to: kCMTimeZero)
    }
    
}



//Resources Used
//1. //https://developer.apple.com/library/content/samplecode/AVFoundationSimplePlayer-iOS/Listings/Swift_AVFoundationSimplePlayer_iOS_PlayerViewController_swift.html

//2. //http://stackoverflow.com/questions/36168519/playing-video-in-uitableview-cell
