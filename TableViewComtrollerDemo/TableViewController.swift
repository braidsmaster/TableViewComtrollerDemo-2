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
        
        
        do {
            
            filesInDirectory = try FileManager().contentsOfDirectory(atPath: documentsDirectory!.path)
            
        } catch let error as NSError {
            print(error)
        }
        
        numbersFileInDirectory=[]
        
        for value in filesInDirectory {
            if value.contains(".MOV") {
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
                
            elementsArray.append(documentsDirectory!.appendingPathComponent(String(filesInDirectory[index])).path)
            }
        }
        print (numbersFileInDirectory.sorted())
        
        self.tableView.reloadData()
        
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        // перемотка  работает  но только когда много
        
//        let indexPath  = IndexPath(row: 0, section: 0)
//        self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //        documentsDirectory = documentsDirectory!.appendingPathComponent("localImages")
        
//        VideoHelper.startMediaBrowser(delegate: self, sourceType: .savedPhotosAlbum)
    
        visibleIP = IndexPath.init(row: 0, section: 0)
        
        getFileFromDisk()
        
        checkPermission()
        
        print (documentsDirectory)
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
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
    //    override func didReceiveMemoryWarning() {
    //        super.didReceiveMemoryWarning()
    //        // Dispose of any resources that can be recreated.
    //    }
    
    //    func imagePickerController(_ picker: UIImagePickerController,
    //                               didFinishPickingMediaWithInfo info: [String : Any]) {
    //        // 1
    //        guard
    //            let mediaType = info[UIImagePickerControllerMediaType] as? String,
    //            mediaType == (kUTTypeMovie as String),
    //            let url = info[UIImagePickerControllerMediaURL] as? URL
    //            else {
    //                return
    //        }
    //
    //        // 2
    //        dismiss(animated: true) {
    //            //3
    //            let player = AVPlayer(url: url)
    //            let vcPlayer = AVPlayerViewController()
    //            vcPlayer.player = player
    //            self.present(vcPlayer, animated: true, completion: nil)
    //        }
    //    }
    
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
            
            print("choose video url \(url)")
            let newFileName = String(filesInDirectory.count*10) + ".MOV"
            let videoUrl = documentsDirectory!.appendingPathComponent(newFileName, isDirectory: true)
            
            do {

                try FileManager.default.moveItem(at: url, to: videoUrl)
            } catch {
                
                print (error)
            }
            
             getFileFromDisk()
            
//            let image = info[UIImagePickerControllerOriginalImage] as! UIImage
//
//
//            let newFileName = String(filesInDirectory.count*10)
//            let url = documentsDirectory!.appendingPathComponent(newFileName, isDirectory: true)
//
//            let data = UIImagePNGRepresentation(image.fixedOrientation()!)
//            FileManager.default.createFile(atPath: url.path, contents: data, attributes: nil)
//            getFileFromDisk()
            
            
            print(url)
        }
        dismiss(animated: true, completion: nil)
    }
    
    // функция загрузки картинки в амазон
    
    //    func uploadImage(_ image: UIImage) {
    //        let completionHandler: AWSS3TransferUtilityUploadCompletionHandlerBlock = {
    //            (task, error) -> Void in
    //            if let error = error {
    //                print(error)
    //            } else {
    //
    //                self.downloadAfterUpload()
    //                print("success")
    //
    //            }
    //        }
    //
    //        // амазоновский класс вызыват функцию загрузки в амазон
    //
    //        transferUtility.uploadData(UIImagePNGRepresentation(image)!, key: "test-image2.png", contentType: "image/png", expression: AWSS3TransferUtilityUploadExpression(), completionHandler: completionHandler).continueWith {
    //            (task) -> AnyObject? in
    //            if let error = task.error {
    //                print(error)
    //            }
    //
    //            if let _ = task.result {
    //                print("upload started")
    //
    //
    //            }
    //
    //            return nil
    //        }
    //    }
    
    // если в галерее нажали отмену закрывает галерею
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: - Table view data source
    
//    override func numberOfSections(in tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 1
//    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
//        if section == 0 {
        
            return numbersFileInDirectory.count
//        }
//        else {
//            return 1
//        }
        
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
            print("url string \(url)")
            let fullUrl = URL(fileURLWithPath: url)
            print ("fullUrl:", fullUrl)
                
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "videoCell") as! VideoCellTableViewCell
                 let bundleurl = Bundle.main.url(forResource:"IMG_5304", withExtension: "MOV")
                cell.videoPlayerItem = AVPlayerItem.init(url: fullUrl)
                print("videoCellItem \(cell.videoPlayerItem)")
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
                print("Videocell add")
                cells.append(videoCell)
            }else{
                if  let imageCell = self.tableView.cellForRow(at: ip) as? ImageTableViewCell {
                print("ImageCell add")
                cells.append(imageCell)
                }
            }
        }
        let cellCount = cells.count
        if cellCount == 0 {return}
        if cellCount == 1{
            print ("visible = \(indexPaths?[0])")
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
                print("\n currentHeight \(currentHeight) cellHeight \(cellHeight * 0.3) visibleIP \(visibleIP)")
                if currentHeight > (cellHeight * 0.4){
                    print(">")
                    if visibleIP != indexPaths?[i]{
                        print("!=")
                        visibleIP = indexPaths?[i]
                        print ("visible11 = \(indexPaths?[i])")
                        if let videoCell = cells[i] as? VideoCellTableViewCell{
                            self.playVideoOnTheCell(cell: videoCell, indexPath: (indexPaths?[i])!)
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
    
//     func checkVisibilityOfCell(cell : VideoCellTableViewCell, indexPath : IndexPath){
//        let cellRect = self.tableView.rectForRow(at: indexPath)
//        let completelyVisible = self.tableView.bounds.contains(cellRect)
//        if completelyVisible {
//            self.playVideoOnTheCell(cell: cell, indexPath: indexPath)
//        }
//        else{
//            if aboutToBecomeInvisibleCell != indexPath.row{
//                aboutToBecomeInvisibleCell = indexPath.row
//                self.stopPlayBack(cell: cell, indexPath: indexPath)
//            }
//        }
//    }
    
    func playVideoOnTheCell(cell : VideoCellTableViewCell, indexPath : IndexPath){
        print("play")
        cell.startPlayback()
    }
    
    func stopPlayBack(cell : VideoCellTableViewCell, indexPath : IndexPath){
        cell.stopPlayback()
    }
    
    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        print("end = \(indexPath)")
        if let videoCell = cell as? VideoCellTableViewCell{
            videoCell.stopPlayback()
        }
        
        paused = true
    }
    
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}










////
////  TableViewController.swift
////  TableViewComtrollerDemo
////
////  Created by Kirill Lukyanov on 17.05.2018.
////  Copyright © 2018 Kirill Lukyanov. All rights reserved.
////
//
//import UIKit
//import MobileCoreServices
//import Photos
//
//class TableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
//
//
//    var documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
//
//    var elementsArray:[UIImage] = []
//    var numbersFileInDirectory: [Int] = []
//    var filesInDirectory: [String] = []
//
//    func getFileFromDisk() {
//
//
//        do {
//
//            filesInDirectory = try FileManager().contentsOfDirectory(atPath: documentsDirectory!.path)
//
//        } catch let error as NSError {
//            print(error)
//        }
//
//        numbersFileInDirectory=[]
//
//        for value in filesInDirectory {
//            numbersFileInDirectory.append(Int(value)!)
//        }
//
//        elementsArray = []
//        for  value in numbersFileInDirectory.sorted() {
//            let currentImage = UIImage(contentsOfFile: documentsDirectory!.appendingPathComponent(String(value)).path)
//            elementsArray.append(currentImage!)
//        }
//        print (numbersFileInDirectory.sorted())
//
//        self.tableView.reloadData()
//
//
//    }
//
//
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(true)
//        // перемотка  работает  но только когда много
//
//        let indexPath  = IndexPath(row: 0, section: 1)
//        self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
//    }
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
////        documentsDirectory = documentsDirectory!.appendingPathComponent("localImages")
//
//        getFileFromDisk()
//
//        checkPermission()
//
//
//
//        // Uncomment the following line to preserve selection between presentations
//        // self.clearsSelectionOnViewWillAppear = false
//
//        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
//        // self.navigationItem.rightBarButtonItem = self.editButtonItem
//    }
//
//
//    func checkPermission() {
//        let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
//        switch photoAuthorizationStatus {
//        case .authorized:
//            print("Access is granted by user")
//        case .notDetermined:
//            PHPhotoLibrary.requestAuthorization({
//                (newStatus) in
//                print("status is \(newStatus)")
//                if newStatus ==  PHAuthorizationStatus.authorized {
//                    //               // do stuff here /
//                    print("success")
//                }
//            })
//            print("It is not determined until now")
//        case .restricted:
//            // same same
//            print("User do not have access to photo album.")
//        case .denied:
//            // same same
//            print("User has denied the permission.")
//        }
//    }
//
//    // по нажатию кнопки идет аплоад и открывается галерея
//
//    @IBAction func addBottom(_ sender: Any) {
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
////    override func didReceiveMemoryWarning() {
////        super.didReceiveMemoryWarning()
////        // Dispose of any resources that can be recreated.
////    }
//
//
//
//    // захват из галереи когда уже выбрана
//
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
//        if info[UIImagePickerControllerMediaType] as? String == "public.image" {
//            let image = info[UIImagePickerControllerOriginalImage] as! UIImage
//            //           uploadImage(image)
//
//            // определяем путь с именем картинки
//
//            let newFileName = String(filesInDirectory.count*10)
//            let url = documentsDirectory!.appendingPathComponent(newFileName, isDirectory: true)
//
//            let data = UIImagePNGRepresentation(image.fixedOrientation()!)
//            FileManager.default.createFile(atPath: url.path, contents: data, attributes: nil)
//
//            //  добавляем в массив изображений
//
//            //          self.elementsArray.append(image)
//
//            getFileFromDisk()
//
//
//
//            // перемотка не работает
//
//            //            let indexPath  = IndexPath(row: filesInDirectory.count - 1, section: 0)
//            //            self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
//            //
//            //         self.tableView.setContentOffset(CGPoint(x: 0, y: CGFloat.greatestFiniteMagnitude), animated: true)
//        }
//
//        dismiss(animated: true, completion: nil)
//    }
//
//    // функция загрузки картинки в амазон
//
////    func uploadImage(_ image: UIImage) {
////        let completionHandler: AWSS3TransferUtilityUploadCompletionHandlerBlock = {
////            (task, error) -> Void in
////            if let error = error {
////                print(error)
////            } else {
////
////                self.downloadAfterUpload()
////                print("success")
////
////            }
////        }
////
////        // амазоновский класс вызыват функцию загрузки в амазон
////
////        transferUtility.uploadData(UIImagePNGRepresentation(image)!, key: "test-image2.png", contentType: "image/png", expression: AWSS3TransferUtilityUploadExpression(), completionHandler: completionHandler).continueWith {
////            (task) -> AnyObject? in
////            if let error = task.error {
////                print(error)
////            }
////
////            if let _ = task.result {
////                print("upload started")
////
////
////            }
////
////            return nil
////        }
////    }
//
//    // если в галерее нажали отмену закрывает галерею
//
//    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
//        dismiss(animated: true, completion: nil)
//    }
//
//
//    // MARK: - Table view data source
//
//    override func numberOfSections(in tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 2
//    }
//
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        // #warning Incomplete implementation, return the number of rows
//
//        if section == 0 {
//
//            return numbersFileInDirectory.count
//        } else {
//            return 1
//        }
//
//    }
//
//    // заполняем ячейки
//
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//
//
//        if indexPath.section == 0 {
//
//            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ElementTableViewCell
//
//
//            cell.picture.image = elementsArray[indexPath.row]
//
//            cell.parrentController = self
//
//            let const = cell.picture.image!.size.height / cell.picture.image!.size.width
//            tableView.rowHeight =  cell.frame.size.width * const
//            print (cell.picture.image!.size.width, cell.frame.size.width, const)
//
//            return cell
//
//        } else {
//
//            tableView.rowHeight = 105
//
//            let cell = tableView.dequeueReusableCell(withIdentifier: "cell2", for: indexPath)
//            return cell
//        }
//
//        // Configure the cell...
//
//
//    }
//
//
//    /*
//     // Override to support conditional editing of the table view.
//     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
//     // Return false if you do not want the specified item to be editable.
//     return true
//     }
//     */
//
//    /*
//     // Override to support editing the table view.
//     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
//     if editingStyle == .delete {
//     // Delete the row from the data source
//     tableView.deleteRows(at: [indexPath], with: .fade)
//     } else if editingStyle == .insert {
//     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
//     }
//     }
//     */
//
//    /*
//     // Override to support rearranging the table view.
//     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
//
//     }
//     */
//
//    /*
//     // Override to support conditional rearranging of the table view.
//     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
//     // Return false if you do not want the item to be re-orderable.
//     return true
//     }
//     */
//
//    /*
//     // MARK: - Navigation
//
//     // In a storyboard-based application, you will often want to do a little preparation before navigation
//     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//     // Get the new view controller using segue.destinationViewController.
//     // Pass the selected object to the new view controller.
//     }
//     */
//
//}
//
//
//
