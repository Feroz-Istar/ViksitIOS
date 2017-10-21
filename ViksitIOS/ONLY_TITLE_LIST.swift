//
//  ONLYTITLELIST.swift
//  ViksitIOS
//
//  Created by Akshay Kumar Both on 8/21/17.
//  Copyright © 2017 Istar Feroz. All rights reserved.
//

import UIKit

class ONLY_TITLE_LIST: UIViewController {
    
    var slide: CMSlide = CMSlide()

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var listStack: UIStackView!
    @IBOutlet var gifImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        print(slide.templateName)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        listStack.subviews.forEach { $0.removeFromSuperview() } // removing all subviews
        titleLabel.text = slide.title.text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if slide.list.items.count > 0 {
            for item in slide.list.items {
                //print(item.text)
                if item.text != "" {
                    //ThemeUtil.setListItemTextLabel(text: item.text, listStack: listStack)
                    ThemeUtil.setListItemTextLabelCustom(text: item.text, listStack: listStack)
                    
                }
                
            }
        }
        //ImageAsyncLoader.loadImageAsync(url: slide.image.url, imgView: gifImageView)
    }

}
