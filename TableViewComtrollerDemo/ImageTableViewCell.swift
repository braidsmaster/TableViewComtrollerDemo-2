//
//  ViewController.swift
//  TableViewComtrollerDemo
//
//  Created by Kirill Lukyanov on 17.05.2018.
//  Copyright © 2018 Kirill Lukyanov. All rights reserved.
//

import UIKit
import MobileCoreServices
import Photos
import AVFoundation

class ImageTableViewCell: UITableViewCell, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
//    @IBOutlet weak var videoPlayerSuperView: UIView!
//    @IBOutlet weak var verticalProportion: NSLayoutConstraint!
    
//    var avPlayer: AVPlayer?
//    var avPlayerLayer: AVPlayerLayer?
//    var paused: Bool = false
//
//    //This will be called everytime a new value is set on the videoplayer item
//    var videoPlayerItem: AVPlayerItem? = nil {
//        didSet {
//            /*
//             If needed, configure player item here before associating it with a player.
//             (example: adding outputs, setting text style rules, selecting media options)
//             */
//            avPlayer?.replaceCurrentItem(with: self.videoPlayerItem)
//        }
//    }
//
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        //Setup you avplayer while the cell is created
//        self.setupMoviePlayer()
//    }
//    func setupMoviePlayer(){
//        self.avPlayer = AVPlayer.init(playerItem: self.videoPlayerItem)
//        avPlayerLayer = AVPlayerLayer(player: avPlayer)
//        avPlayerLayer?.videoGravity = AVLayerVideoGravity.resizeAspect
//        avPlayer?.volume = 3
//        avPlayer?.actionAtItemEnd = .none
//
//        //        You need to have different variations
//        //        according to the device so as the avplayer fits well
//        if UIScreen.main.bounds.width == 375 {
//            let widthRequired = self.frame.size.width - 20
//            avPlayerLayer?.frame = CGRect.init(x: 0, y: 0, width: widthRequired, height: widthRequired/1.78)
//        }else if UIScreen.main.bounds.width == 320 {
//            avPlayerLayer?.frame = CGRect.init(x: 0, y: 0, width: (self.frame.size.height - 120) * 1.78, height: self.frame.size.height - 120)
//        }else{
//            let widthRequired = self.frame.size.width
//            avPlayerLayer?.frame = CGRect.init(x: 0, y: 0, width: widthRequired, height: widthRequired/1.78)
//        }
//        self.backgroundColor = .clear
//        self.videoPlayerSuperView.layer.insertSublayer(avPlayerLayer!, at: 0)
//
//        // This notification is fired when the video ends, you can handle it in the method.
//        NotificationCenter.default.addObserver(self,
//                                               selector: #selector(self.playerItemDidReachEnd(notification:)),
//                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
//                                               object: avPlayer?.currentItem)
//    }
//
//    func stopPlayback(){
//        self.avPlayer?.pause()
//    }
//
//    func startPlayback(){
//        self.avPlayer?.play()
//    }
//    
//    // A notification is fired and seeker is sent to the beginning to loop the video again
//    @objc func playerItemDidReachEnd(notification: Notification) {
//        let p: AVPlayerItem = notification.object as! AVPlayerItem
//        p.seek(to: kCMTimeZero)
//    }
    
    
    var parrentController: TableViewController?
    
    @IBOutlet weak var picture: UIImageView! {
        didSet {
            picture.translatesAutoresizingMaskIntoConstraints = false
//            picture.image?.fixedOrientation()
        }
    }
  
    
    func iconFrame() {
        let const = picture.image!.size.height / picture.image!.size.width
        let iconWidth: CGFloat = self.frame.width
        let iconHeight: CGFloat = self.frame.width * const
        let iconSize = CGSize(width: iconWidth, height: iconHeight)
        let iconOrigin = CGPoint(x: bounds.midX - iconWidth / 2, y: bounds.midY - iconHeight / 2)
        picture.frame = CGRect(origin: iconOrigin, size: iconSize)
    }
    
//    func videoFrame() {
// //       let const = picture.image!.size.height / picture.image!.size.width
//        let const = CGFloat (16/9)
//        let iconWidth: CGFloat = self.frame.width
//        let iconHeight: CGFloat = self.frame.width * const
//        let iconSize = CGSize(width: iconWidth, height: iconHeight)
//        let iconOrigin = CGPoint(x: bounds.midX - iconWidth / 2, y: bounds.midY - iconHeight / 2)
//        picture.frame = CGRect(origin: iconOrigin, size: iconSize)
//    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
//        if picture.image != nil {
            iconFrame()
            
//        } else {
//
//            videoFrame()
//
//        }
    }
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        // Initialization code
//    }
    
    @IBAction func topButton(_ sender: Any) {
        
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false
        imagePicker.mediaTypes = [kUTTypeImage as String]
        imagePicker.delegate = self
        parrentController!.present(imagePicker, animated: true, completion: nil)
        
        
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
   
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if info[UIImagePickerControllerMediaType] as? String == "public.image" {
            let image = info[UIImagePickerControllerOriginalImage] as! UIImage
           
            
         //    определяем путь с именем картинки
            
            let newFileName = String(parrentController!.filesInDirectory.count*10)
            
            // нужно узнать номер ячейки отнять 1 и умножить 10 и прибавить 1
            
            
            let url = parrentController!.documentsDirectory!.appendingPathComponent(newFileName, isDirectory: true)

            let data = UIImagePNGRepresentation(image.fixedOrientation()!)
            FileManager.default.createFile(atPath: url.path, contents: data, attributes: nil)

            //  добавляем в массив изображений

            //          self.elementsArray.append(image)

            parrentController!.getFileFromDisk()

        }
        
        parrentController!.dismiss(animated: true, completion: nil)
    }
    
}



extension UIImage {
    
    func fixedOrientation() -> UIImage? {
        
        guard imageOrientation != UIImageOrientation.up else {
            //This is default orientation, don't need to do anything
            return self.copy() as? UIImage
            print("normal")
        }
        
        guard let cgImage = self.cgImage else {
            //CGImage is not available
            print("CGImage is not available")
            return nil
        }
        
        guard let colorSpace = cgImage.colorSpace, let ctx = CGContext(data: nil, width: Int(size.width), height: Int(size.height), bitsPerComponent: cgImage.bitsPerComponent, bytesPerRow: 0, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
            print("Not able to create CGContext")
            return nil //Not able to create CGContext
        }
        
        var transform: CGAffineTransform = CGAffineTransform.identity
        
        switch imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: size.width, y: size.height)
            transform = transform.rotated(by: CGFloat.pi)
            break
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.rotated(by: CGFloat.pi / 2.0)
            break
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: size.height)
            transform = transform.rotated(by: CGFloat.pi / -2.0)
            break
        case .up, .upMirrored:
            break
        }
        
        //Flip image one more time if needed to, this is to prevent flipped image
        switch imageOrientation {
        case .upMirrored, .downMirrored:
            transform.translatedBy(x: size.width, y: 0)
            transform.scaledBy(x: -1, y: 1)
            break
        case .leftMirrored, .rightMirrored:
            transform.translatedBy(x: size.height, y: 0)
            transform.scaledBy(x: -1, y: 1)
        case .up, .down, .left, .right:
            break
        }
        
        ctx.concatenate(transform)
        
        switch imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            ctx.draw(self.cgImage!, in: CGRect(x: 0, y: 0, width: size.height, height: size.width))
        default:
            ctx.draw(self.cgImage!, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
            break
        }
        
        print("fixed")
        guard let newCGImage = ctx.makeImage() else { return nil }
        return UIImage.init(cgImage: newCGImage, scale: 1, orientation: .up)
    }
}
