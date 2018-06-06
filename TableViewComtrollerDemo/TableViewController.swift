//
//  TableViewController.swift
//  TableViewComtrollerDemo
//
//  Created by Kirill Lukyanov on 17.05.2018.
//  Copyright © 2018 Kirill Lukyanov. All rights reserved.
//

import UIKit
import MobileCoreServices
import Photos
import AVKit
import AVFoundation

class TableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    var documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    
    var elementsArray:[Any] = []
    var numbersFileInDirectory: [Int] = []
    var filesInDirectory: [String] = []
    
//    var avPlayer: AVPlayer!
    var visibleIP : IndexPath?
    var aboutToBecomeInvisibleCell = -1
//    var avPlayerLayer: AVPlayerLayer!
    var paused: Bool = false
//
    
    func getFileFromDisk() {
        
        let filesNumDir = NSHomeDirectory() + "/Documents/FilesNum"
        
        do {
            
            filesInDirectory = try FileManager().contentsOfDirectory(atPath: filesNumDir)
            
        } catch let error as NSError {
            print(error)
        }
        
        numbersFileInDirectory=[]
        
        for value in filesInDirectory {
            if value.contains(".MOV") || value.contains (".MP4") {
                let subValue = value.split(separator: ".")
                numbersFileInDirectory.append(Int(subValue.first!)!)
            } else {
            numbersFileInDirectory.append(Int(value)!)
            }
        }
        
        elementsArray = []
        for  (index,value) in numbersFileInDirectory.sorted().enumerated() {
            if    let currentImage = UIImage(contentsOfFile: documentsDirectory!.appendingPathComponent(String(value)).path) {
                
                elementsArray.append(currentImage)
                
            } else  {
                
                let videoDir = NSHomeDirectory() + "/Documents/Video/"
                elementsArray.append(videoDir + filesInDirectory[index] + ".MOV")
            }
        }
        print (numbersFileInDirectory.sorted())
        print (elementsArray)
        
        self.tableView.reloadData()
        
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
     
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let videoDir = NSHomeDirectory() + "/Documents/Video"
        let filesNumDir = NSHomeDirectory() + "/Documents/FilesNum"
        do {
            try FileManager.default.createDirectory(atPath: videoDir, withIntermediateDirectories: true, attributes: nil)
            
            try FileManager.default.createDirectory(atPath: filesNumDir, withIntermediateDirectories: true, attributes: nil)
            
        } catch let error {
            print(error)
        }
    
        visibleIP = IndexPath.init(row: 0, section: 0)
        
        getFileFromDisk()
        
        checkPermission()
        
        print (documentsDirectory)
        
       
    }
    
//    @IBAction func add(_ sender: Any) {
//        
//        let imagePicker = UIImagePickerController()
//        imagePicker.sourceType = .photoLibrary
//        imagePicker.allowsEditing = false
//        imagePicker.mediaTypes = [kUTTypeImage as String]
//        imagePicker.delegate = self
//        
//        present(imagePicker, animated: true, completion: nil)
//        
//    }
    
    
    func checkPermission() {
        let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        switch photoAuthorizationStatus {
        case .authorized:
            print("Access is granted by user")
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization({
                (newStatus) in
                print("status is \(newStatus)")
                if newStatus ==  PHAuthorizationStatus.authorized {
                    //               // do stuff here /
                    print("success")
                }
            })
            print("It is not determined until now")
        case .restricted:
            // same same
            print("User do not have access to photo album.")
        case .denied:
            // same same
            print("User has denied the permission.")
        }
        
      //   let mediaAuthorizationStatus = PHMedia  .authorizationStatus()
    }
    
    // по нажатию кнопки идет аплоад и открывается галерея
    
    @IBAction func addBottom(_ sender: Any) {
        
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false
        imagePicker.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]
        imagePicker.delegate = self
        
        present(imagePicker, animated: true, completion: nil)
        
    }
   
    
    // захват из галереи когда уже выбрана
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if info[UIImagePickerControllerMediaType] as? String == "public.image" {
            let image = info[UIImagePickerControllerOriginalImage] as! UIImage
            
            
            let newFileName = String(filesInDirectory.count*10)
            let url = documentsDirectory!.appendingPathComponent(newFileName, isDirectory: true)
            
            let data = UIImagePNGRepresentation(image.fixedOrientation()!)
            FileManager.default.createFile(atPath: url.path, contents: data, attributes: nil)
            getFileFromDisk()
            
        } else if let mediaType = info[UIImagePickerControllerMediaType] as? String,
            mediaType == (kUTTypeMovie as String),
            let url = info[UIImagePickerControllerMediaURL] as? URL{
            
            let fileNmaeWithOutExtension = String(filesInDirectory.count*10)
            let filePathWithOutExtension = documentsDirectory!.appendingPathComponent(fileNmaeWithOutExtension, isDirectory: true)
            let newFileName = String(filesInDirectory.count*10) + ".MOV"
            let videoDirUrl = URL(fileURLWithPath: NSHomeDirectory() + "/Documents/Video")
            let videoUrl = videoDirUrl.appendingPathComponent(newFileName, isDirectory: true)
            let data = ""
            
            do {

                try FileManager.default.moveItem(at: url, to: videoUrl)
//                try FileManager.default.createFile(atPath: fileNmaeWithOutExtension, contents: nil, attributes: nil)
                try data.write(to: filePathWithOutExtension, atomically: true, encoding: .utf8)
              
            } catch {
                
                print (error)
            }
  
             getFileFromDisk()
            

            
            print(url)
        }
        dismiss(animated: true, completion: nil)
    }
    
 
    
    // если в галерее нажали отмену закрывает галерею
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    
 
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        
            return numbersFileInDirectory.count

        
    }
    
    // заполняем ячейки
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
//        if indexPath.section == 0 {
        

            
            if let image  = elementsArray[indexPath.row] as? UIImage {
                let cell = tableView.dequeueReusableCell(withIdentifier: "imageCell", for: indexPath) as! ImageTableViewCell
                cell.picture.image = image
                
                cell.parrentController = self
                
                let const = cell.picture.image!.size.height / cell.picture.image!.size.width
                tableView.rowHeight =  cell.frame.size.width * const
                print (cell.picture.image!.size.width, cell.frame.size.width, const)
                return cell
                
            } else {
                
            
                
            let url  = elementsArray[indexPath.row] as! String
//            print("url string \(url)")
            let fullUrl = URL(fileURLWithPath: url)
//            print ("fullUrl:", fullUrl)
                
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "videoCell") as! VideoCellTableViewCell
//                 let bundleurl = Bundle.main.url(forResource:"IMG_5304", withExtension: "MOV")
                cell.videoPlayerItem = AVPlayerItem.init(url: fullUrl)
                let resolution = resolutionForLocalVideo(url: fullUrl)
                print(resolution)
                
//                print("videoCellItem \(cell.videoPlayerItem)")
//                cell.frame.size.height = 300
//                cell.startPlayback()
//            cell.picture.frame.size.width = 0
//            cell.picture.frame.size.height = 0
           
          return cell
                
//                cell.videoPlayerItem = AVPlayerItem.init(url: URL(string: fullUrl)!)
//                cell.startPlayback()
                
            }
        
            
        
            
//        }
//        else {
//
//            tableView.rowHeight = 105
//
//            let cell = tableView.dequeueReusableCell(withIdentifier: "cell2", for: indexPath)
//            return cell
//        }
        
        // Configure the cell...
        
        
    }
    func resolutionForLocalVideo(url: URL) -> CGSize? {
        guard let track = AVURLAsset(url: url).tracks(withMediaType: AVMediaType.video).first else { return nil }
        let size = track.naturalSize.applying(track.preferredTransform)
        return CGSize(width: fabs(size.width), height: fabs(size.height))
    }
    
    // определение что ячейка появилась на экране делается запуск и останавливается когда уходит с экрана
    
    func playerItemDidReachEnd(notification: Notification) {
        let p: AVPlayerItem = notification.object as! AVPlayerItem
        p.seek(to: kCMTimeZero)
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let indexPaths = self.tableView.indexPathsForVisibleRows
        var cells = [Any]()
        for ip in indexPaths!{
            if let videoCell = self.tableView.cellForRow(at: ip) as? VideoCellTableViewCell{
//                print("Videocell add")
                cells.append(videoCell)
            }else{
                if  let imageCell = self.tableView.cellForRow(at: ip) as? ImageTableViewCell {
//                print("ImageCell add")
                cells.append(imageCell)
                }
            }
        }
        let cellCount = cells.count
        if cellCount == 0 {return}
        if cellCount == 1{
//            print ("visible = \(indexPaths?[0])")
            if visibleIP != indexPaths?[0]{
                visibleIP = indexPaths?[0]
            }
            if let videoCell = cells.last! as? VideoCellTableViewCell{
                self.playVideoOnTheCell(cell: videoCell, indexPath: (indexPaths?.last)!)
            }
        }
        if cellCount >= 2 {
            for i in 0..<cellCount{
                let cellRect = self.tableView.rectForRow(at: (indexPaths?[i])!)
                let completelyVisible = self.tableView.bounds.contains(cellRect)
                let intersect = cellRect.intersection(self.tableView.bounds)
                
                let currentHeight = intersect.height
                
                let cellHeight = (cells[i] as AnyObject).frame.size.height
 //               print("\n currentHeight \(currentHeight) cellHeight \(cellHeight * 0.3) visibleIP \(visibleIP)")
                if currentHeight > (cellHeight * 0.4){
 //                   print(">")
                    if visibleIP != indexPaths?[i]{
//                        print("!=")
                        visibleIP = indexPaths?[i]
//                        print ("visible11 = \(indexPaths?[i])")
                        if let videoCell = cells[i] as? VideoCellTableViewCell{
                            self.playVideoOnTheCell(cell: videoCell, indexPath: (indexPaths?[i])!)
                            videoCell.videoFrame()
                        }
                        if let imageCell = cells[i] as? ImageTableViewCell{
                            imageCell.iconFrame()
                        }
                    }
                }
                else{
                    if aboutToBecomeInvisibleCell != indexPaths?[i].row{
                        aboutToBecomeInvisibleCell = (indexPaths?[i].row)!
                        if let videoCell = cells[i] as? VideoCellTableViewCell{
                            self.stopPlayBack(cell: videoCell, indexPath: (indexPaths?[i])!)
                        }
                        
                    }
                }
            }
        }
    }
    

    
    func playVideoOnTheCell(cell : VideoCellTableViewCell, indexPath : IndexPath){
//        print("play")
        cell.startPlayback()
    }
    
    func stopPlayBack(cell : VideoCellTableViewCell, indexPath : IndexPath){
        cell.stopPlayback()
    }
    
    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        print("end = \(indexPath)")
        if let videoCell = cell as? VideoCellTableViewCell{
            videoCell.stopPlayback()
        }
        
        paused = true
    }
    
    
   
    
}

