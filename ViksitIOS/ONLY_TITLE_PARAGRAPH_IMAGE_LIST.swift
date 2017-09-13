//
//  ONLY_TITLE_PARAGRAPH_IMAGE_LIST.swift
//  ViksitIOS
//
//  Created by Akshay Kumar Both on 8/21/17.
//  Copyright © 2017 Istar Feroz. All rights reserved.
//

import UIKit

class ONLY_TITLE_PARAGRAPH_IMAGE_LIST: UIViewController {
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var paraStack: UIStackView!
    @IBOutlet var gifImageView: UIImageView!
    @IBOutlet var imageView: UIImageView!
    
    var slide: CMSlide = CMSlide()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        paraStack.subviews.forEach { $0.removeFromSuperview() } // removing all subviews
        titleLabel.text = slide.title.text
        for item in slide.list.items {
            print(item.text)
            ThemeUtil.setParaListTextLabelCustom(text: item.text, paraStack: paraStack)
        }
    }

    
}
