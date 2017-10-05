//
//  SplashVC.swift
//  ViksitIOS
//
//  Created by Akshay Kumar Both on 10/3/17.
//  Copyright © 2017 Istar Feroz. All rights reserved.
//

import UIKit
import Photos

class SplashVC: UIViewController {
    
    let queue: DispatchQueue = DispatchQueue(label: "com.viksitIOS.queue", qos: .userInteractive, attributes: .concurrent)
    let group:DispatchGroup = DispatchGroup()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        
        //let queue: DispatchQueue = DispatchQueue(label: "com.viksitIOS.queue", attributes: .concurrent)
        
        
        if let complexCache = DataCache.sharedInstance.cache["complexObject"] {
            
            for task in (ComplexObject(JSONString: complexCache).tasks)! {
                if let imageURL = task.imageURL {
                    //queue.async (group: group) {
                    
                        self.saveFileAsync(urlString: imageURL, extraPath: "/Viksit/Viksit_TASKS/", optionalFolderName: "\(task.id!)/")
                    //}
                }
            }
            
            for item in ComplexObject(JSONString: complexCache).leaderboards! {
                if let students = item.allStudentRanks {
                    for student in students {
                        if let imageURL = student.imageURL {
                            //queue.async (group: group) {
                            
                                self.saveFileAsync(urlString: imageURL, extraPath: "/Viksit/Viksit_STUDENTS/", optionalFolderName: "")
                            //}
                        }
                    }
                }
            }
            
            for notification in ComplexObject(JSONString: complexCache).notifications! {
                if let imageURL = notification.imageURL {
                    //queue.async (group: group) {
                    
                        self.saveFileAsync(urlString: imageURL, extraPath: "/Viksit/Viksit_NOTIFICATION/", optionalFolderName: "")
                    //}
                }
            }
            
            for course in ComplexObject(JSONString: complexCache).courses! {
                if let imageURL = course.imageURL {
                    //queue.async (group: group) {
                    
                        self.saveFileAsync(urlString: imageURL, extraPath: "/Viksit/Viksit_ROLES/", optionalFolderName: "")
                    //}
                }
                
                for module in course.modules! {
                    if let moduleImageURL = module.imageURL {
                        //queue.async (group: group) {
                        
                            self.saveFileAsync(urlString: moduleImageURL, extraPath: "/Viksit/Viksit_MODULE/", optionalFolderName: "\(module.id!)/")
                        //}
                    }
                }
            }
            
            group.notify(queue: DispatchQueue.main) {
                print("done doing stuff")
                let storyBoard : UIStoryboard = UIStoryboard(name: "Tab", bundle:nil)
                let nextViewController = storyBoard.instantiateViewController(withIdentifier: "TabBarController") as! TabBarController
                self.present(nextViewController, animated:true, completion:nil)
            }
        }
        
    }
    /*
    func s() {
        //let queue:DispatchQueue  = DispatchQueue.global(attributes: DispatchQueue.GlobalAttributes.qosDefault)
        let queue: DispatchQueue = DispatchQueue(label: "com.viksitIOS.queue", attributes: .concurrent)
        let group:DispatchGroup = DispatchGroup()
        
        print("start")
        
        queue.async (group: group) {
            print("doing stuff")
        }
        
        queue.async (group: group) {
            print("doing more stuff")
        }
        
        group.notify(queue: DispatchQueue.main) {
            print("done doing stuff")
            let storyBoard : UIStoryboard = UIStoryboard(name: "Tab", bundle:nil)
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "TabBarController") as! TabBarController
            self.present(nextViewController, animated:true, completion:nil)
        }
        
    }*/

    //saving file asynchronously in document directory
    func saveFileAsync(urlString: String, extraPath: String, optionalFolderName: String) {
        //let videoImageUrl = "http://www.sample-videos.com/video/mp4/720/big_buck_bunny_720p_1mb.mp4"
        MediaUtil.createFolderInDocuments(folderName: optionalFolderName, extraPath: extraPath)
        let finalFileName = extraPath + optionalFolderName + urlString.components(separatedBy: "/").last!
        
        //DispatchQueue.global(qos: .userInitiated).async {
            if let url = URL(string: urlString),
                let urlData = NSData(contentsOf: url)
            {
                let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
                
                //let filePath="\(documentsPath)/Viksit/\(finalFileName!)"
                let filePath = "\(documentsPath)/\(finalFileName)"
                let fileExists = FileManager().fileExists(atPath: filePath)
                print(filePath)
                
                if !fileExists {
                    
                    queue.async (group: group) {
                    //DispatchQueue.global(qos: .userInteractive).async {
                        print("doing stuff")
                        urlData.write(toFile: filePath, atomically: true)
                        PHPhotoLibrary.shared().performChanges({
                            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: URL(fileURLWithPath: filePath))
                        })
                        { completed, error in
                            if completed {
                                print("File is saved!")
                            }
                        }
                    }
                } else {
                    if optionalFolderName != "" {
                        print("\(urlString.components(separatedBy: "/").last!) already exists in \(optionalFolderName)")
                    } else {
                        print("\(urlString.components(separatedBy: "/").last!) already exists")
                    }
                    
                }
            }
        //}
    }
    

}
