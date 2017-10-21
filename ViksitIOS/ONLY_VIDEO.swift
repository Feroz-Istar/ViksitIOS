//
//  ONLY_VIDEO.swift
//  ViksitIOS
//
//  Created by Akshay Kumar Both on 8/21/17.
//  Copyright © 2017 Istar Feroz. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import Photos

class ONLY_VIDEO: UIViewController {
    
    @IBOutlet var containerView: UIView!
    @IBOutlet var startVideoBtn: UIButton!
    var slide: CMSlide = CMSlide()
    
    @IBAction func startVideoPressed(_ sender: UIButton) {
        
        //playVideoAV(urlString: "http://www.sample-videos.com/video/mp4/720/big_buck_bunny_720p_1mb.mp4")
        playVideoAV(urlString: slide.video.url)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(slide.templateName)
        getVideoFromDocuments(videoURL: slide.video.url)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //getVideoFromDocuments(videoURL: "http://www.sample-videos.com/video/mp4/720/big_buck_bunny_720p_1mb.mp4")
        
    }

    // play video
    func playVideoAV(urlString: String) {
        
        let url = getVideoFromDocuments(videoURL: urlString)
        let player = AVPlayer(url: url)
        let av = AVPlayerViewController()
        av.player = player
        av.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        self.present(av, animated: true)
        self.view.addSubview(av.view)
        player.play()
        av.didMove(toParentViewController: self)
        
    }
    
    //getting file from document directory
    func getVideoFromDocuments(videoURL: String) -> URL{
        let finalFileName = videoURL.components(separatedBy: "/").last
        //print(finalFileName!)
        let documentsURL = try! FileManager().url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let fooURL = documentsURL.appendingPathComponent(finalFileName!)
        let fileExists = FileManager().fileExists(atPath: fooURL.path)
        
        if !fileExists {
            saveVideoAsync(urlToYourVideo: videoURL)
        }
        print(fooURL)
        //print(fileExists)
        return fooURL
    }
    
    //saving video asynchronously in document directory
    func saveVideoAsync(urlToYourVideo: String) {
        //let videoImageUrl = "http://www.sample-videos.com/video/mp4/720/big_buck_bunny_720p_1mb.mp4"
        
        let finalFileName = urlToYourVideo.components(separatedBy: "/").last
        print(finalFileName!)
        
        DispatchQueue.global(qos: .userInteractive).async {
            if let url = URL(string: urlToYourVideo),
                let urlData = NSData(contentsOf: url)
            {
                let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0];
                //let filePath="\(documentsPath)/tempFile.mp4"
                let filePath="\(documentsPath)/\(finalFileName!)"
                DispatchQueue.main.async {
                    urlData.write(toFile: filePath, atomically: true)
                    PHPhotoLibrary.shared().performChanges({
                        PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: URL(fileURLWithPath: filePath))
                    }) { completed, error in
                        if completed {
                            print("Video is saved!")
                        }
                    }
                }
            }
        }
    }
    
}
