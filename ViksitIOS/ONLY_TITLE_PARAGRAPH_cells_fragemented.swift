//
//  ONLY_TITLE_PARAGRAPH_cells_fragemented.swift
//  ViksitIOS
//
//  Created by Akshay Kumar Both on 8/21/17.
//  Copyright © 2017 Istar Feroz. All rights reserved.
//

import UIKit

class ONLY_TITLE_PARAGRAPH_cells_fragemented: UIViewController {
    
    @IBOutlet var gifImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var webView: UITextView!
    
    var slide: CMSlide = CMSlide()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(slide.templateName)
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        titleLabel.text = slide.title.text
        
        //webView.scrollView.isScrollEnabled = false
        //webView.scrollView.bounces = false
        //webView.loadHTMLString(ThemeUtil.wrapInHtml(body: slide.paragraph.text, fontsize: "14"), baseURL: nil)
        webView.setHTMLFromString(htmlText: slide.paragraph.text)
        webView.font = webView.font?.withSize(10)
        
        if (slide.image_BG != "null" || slide.image_BG != "none"){
            ImageAsyncLoader.loadImageAsync(url: slide.image_BG, imgView: gifImageView)
        } else {
            if !(slide.image.url.contains("ToDo.png")) {
                ImageAsyncLoader.loadImageAsync(url: slide.image.url, imgView: gifImageView)
            }
        }
    }

    

}
