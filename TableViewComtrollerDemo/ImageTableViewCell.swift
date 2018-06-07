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
    

    
    override func layoutSubviews() {
        super.layoutSubviews()
            iconFrame()
    }
    
    func setImage(imageName: UIImage) {
        self.picture.image = imageName
        iconFrame()
    }

    
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
            
            
            let url = parrentController!.filesNumDirURL.appendingPathComponent(newFileName, isDirectory: true)

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
