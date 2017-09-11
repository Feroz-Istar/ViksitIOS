//
//  AssessmentVC.swift
//  ViksitIOS
//
//  Created by Akshay Kumar Both on 9/6/17.
//  Copyright © 2017 Istar Feroz. All rights reserved.
//

import UIKit



class AssessmentVC: UIViewController {
    var assessment: Assessment!
    var questions: [Question] = []
    
    var testString: String = "<!DOCTYPE html><html><head><style> table, th, td {border: 1px solid black;border-collapse: collapse;padding: 0 !important; margin: 0 !important;}</style></head><body><table style=\"width:100%\"><tr><td>Jill</td><td>Smith</td><td>50</td></tr><tr><th>Firstname</th><th>Lastname</th><th>Age</th></tr><tr><td>Jill</td><td>Smith</td><td>50</td></tr><tr><th>Firstname</th><th>Lastname</th><th>Age</th></tr><tr><td>Jill</td><td>Smith</td><td>50</td></tr></table></body></html>"
    
    var visibleCellIndex: IndexPath!    
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var quesTableList: UITableView!
    @IBOutlet var centerYconstraint: NSLayoutConstraint!
    @IBOutlet var tableViewContainer: UIView!
    @IBOutlet var viewAllBtn: UIButton!
    
    @IBAction func showPrev(_ sender: UIButton) {
        if visibleCellIndex.row != 0 {
            collectionView.scrollToItem(at:IndexPath(item: visibleCellIndex.row - 1 , section: 0), at: .left, animated: false)
            UIView.animate(withDuration: 0.3, animations: {
                self.view.layoutIfNeeded()
            })
            visibleCellIndex.row = visibleCellIndex.row - 1
        }
        
    }
    
    @IBAction func showNext(_ sender: UIButton) {
        print(" lll  \(visibleCellIndex.row)")
        if visibleCellIndex.row != (questions.count-1) { // 4 has to be changed
            collectionView.scrollToItem(at:IndexPath(item: visibleCellIndex.row + 1 , section: 0), at: .right, animated: false)
            UIView.animate(withDuration: 0.3, animations: {
                self.view.layoutIfNeeded()
            })
            
            visibleCellIndex.row = visibleCellIndex.row + 1
            
        }
        
    }
    
    @IBAction func closeTable(_ sender: UIButton) {
        centerYconstraint.constant = 1000
        
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    @IBAction func showTable(_ sender: UIButton) {
        centerYconstraint.constant = 0
        
        UIView.animate(withDuration: 0.7, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    func writeToFile() {
        let fileName = "Test"
        let documentDirURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let fileURL = documentDirURL.appendingPathComponent(fileName).appendingPathExtension("txt")
        
        print("File Path is: \(fileURL.path)")
        
        
        let writeString = "Write this text in the file in swift"
        do {
            try writeString.write(to: fileURL, atomically: true, encoding: String.Encoding.utf8)
        } catch let error as NSError {
            print("Failed to write URL")
            print(error)
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //loadAssessmentAsync()
        var response: String = Helper.makeHttpCall (url : "http://elt.talentify.in/t2c/get_lesson_details?taskId=277274&userId=4972", method: "GET", param: [:])
        self.assessment = Assessment(JSONString: response)
        setData()
        
        visibleCellIndex = IndexPath(row: 0, section: 0)
        quesTableList.tag = -1000 // so, scrollview delegate methods adoesnt affect the table view scroll
        quesTableList.rowHeight = UITableViewAutomaticDimension
        quesTableList.estimatedRowHeight = 140
        setViewAllImageToRight(viewAllBtn: viewAllBtn)
        
        
    }
    
    func loadAssessmentAsync() {
        DispatchQueue.global(qos: .background).async {
            //print("This is run on the background queue")
            var response: String = Helper.makeHttpCall (url : "http://elt.talentify.in/t2c/get_lesson_details?taskId=277274&userId=4972", method: "GET", param: [:])
            //var ass = Assessment(JSONString: response)
            DispatchQueue.main.async {
                //print("This is run on the main queue, after the previous code in outer block")
                self.assessment = Assessment(JSONString: response)
                print(self.assessment.id)
                self.setData()
            }
        }
    }
    
    func setData() {
        questions = assessment.questions
        
    }
    
    func setViewAllImageToRight(viewAllBtn: UIButton) {
        
        let titleWidth: CGFloat = viewAllBtn.titleLabel!.frame.size.width
        let imageWidth: CGFloat = viewAllBtn.imageView!.frame.size.width
        let gapWidth: CGFloat = viewAllBtn.frame.size.width - titleWidth - imageWidth
        let sidePadding: CGFloat = 10
        
        viewAllBtn.titleEdgeInsets = UIEdgeInsetsMake(viewAllBtn.titleEdgeInsets.top,
                                                      -imageWidth + viewAllBtn.titleEdgeInsets.left + sidePadding,
                                                      viewAllBtn.titleEdgeInsets.bottom,
                                                      imageWidth - viewAllBtn.titleEdgeInsets.right )
        
        viewAllBtn.imageEdgeInsets = UIEdgeInsetsMake(viewAllBtn.imageEdgeInsets.top,
                                                      titleWidth + viewAllBtn.imageEdgeInsets.left + gapWidth - sidePadding,
                                                      viewAllBtn.imageEdgeInsets.bottom,
                                                      -titleWidth + viewAllBtn.imageEdgeInsets.right - gapWidth )
    }
    
    
    func setHTMLString(testString: String) -> NSAttributedString {
        //let str = ThemeUtil.wrapInHtml(body: testString, fontsize: fontsize)
        // if the string is not wrapped in html tags then wrap it and uncomment above line
        let str = testString
        let attrStr = try! NSAttributedString(
            data: str.data(using: String.Encoding.unicode, allowLossyConversion: true)!,
            options: [ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType],
            documentAttributes: nil)
        //textview.attributedText = attrStr
        return attrStr
    }
    
}
extension AssessmentVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return questions.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "QuesOptionCell", for: indexPath) as! QuesOptionCell
        cell.optionStack.subviews.forEach { $0.removeFromSuperview() } // removing all subviews
        
        cell.scrollView.scrollToTop()
        cell.quesView.attributedText = setHTMLString(testString: questions[indexPath.row].text!)
        
        var option: OptionView
        for i in 0..<4 {
            option = OptionView()
            option.tag = i
            option.addGestureRecognizer(setTapGestureRecognizer())
            option.optionText.isScrollEnabled = false
            option.optionText.attributedText = setHTMLString(testString: (questions[indexPath.row].options?[i].text!)!)
            option.optionContainer.backgroundColor = UIColor.brown
            cell.optionStack.addArrangedSubview(option)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        return CGSize(width: collectionView.frame.width * 1, height: collectionView.frame.height) //use height whatever you wants.
    }
    
    /*
    // Called before the cell is displayed
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
     
        //print("starting display of cell: \(indexPath.row)")
    }
    
    // Called when the cell is displayed
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        print(collectionView.indexPathsForVisibleItems.first)
        //print("ending display of cell: \(indexPath.row)")
    }
 
 */
}


extension AssessmentVC: UIScrollViewDelegate {
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        if scrollView.tag == -1000 { //so hidden table view scrolling doesnt get effected by the scrollview delegate methods
            return
        }
        
        //let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        let cellWidthIncludingSpacing = collectionView.frame.width//layout.itemSize.width + layout.minimumLineSpacing
        
        var offset = targetContentOffset.pointee
        let index = (offset.x + scrollView.contentInset.left)/cellWidthIncludingSpacing
        
        let roundedIndex = round(index)
        
        offset = CGPoint(x: roundedIndex * cellWidthIncludingSpacing - scrollView.contentInset.left, y: -scrollView.contentInset.top)
        targetContentOffset.pointee = offset
        
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        if scrollView.tag == -1000 { //so hidden table view scrolling doesnt get effected by the scrollview delegate methods
            return
        }
        getVisibleCellIndexPath()
        
    }
    
    func getVisibleCellIndexPath () {
        var visibleRect = CGRect()
        visibleRect.origin = collectionView.contentOffset
        visibleRect.size = collectionView.bounds.size
        
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        let visibleIndexPath: IndexPath = collectionView.indexPathForItem(at: visiblePoint)!
        
        print(visibleIndexPath.row)
        self.visibleCellIndex = visibleIndexPath
    }
    
}

extension AssessmentVC: UIGestureRecognizerDelegate {
    
    func handleTap(gestureRecognizer: UIGestureRecognizer) {
        print("\(gestureRecognizer.view?.tag)")
        
        if let option: OptionView = gestureRecognizer.view as! OptionView {
            if !((questions[visibleCellIndex.row].options?[option.tag].isSelected)!) {
                option.optionContainer.backgroundColor = UIColor.red
                self.questions[visibleCellIndex.row].options?[(option.tag)].isSelected = true
                print("question \(visibleCellIndex.row) -> option \(option.tag) is selected")
            } else {
                option.optionContainer.backgroundColor = UIColor.brown
                self.questions[visibleCellIndex.row].options?[(option.tag)].isSelected = false
                print("question \(visibleCellIndex.row) -> option \(option.tag) is unselected")
            }
            
            
            //
            /*
            if option.optionContainer.backgroundColor == UIColor.red {
                option.optionContainer.backgroundColor = UIColor.brown
                self.questions[visibleCellIndex.row].options?[(option.tag)].isSelected = true
                
                print("question \(visibleCellIndex.row) -> option \(option.tag) is selected")
            } else {
                option.optionContainer.backgroundColor = UIColor.red
            }
 */
            
        }
    }
    
    func setTapGestureRecognizer() -> UITapGestureRecognizer {
        
        var gestureRecognizer = UITapGestureRecognizer()
        gestureRecognizer = UITapGestureRecognizer (target: self, action: #selector(handleTap(gestureRecognizer:)))
        
        return gestureRecognizer
    }

}

extension AssessmentVC: UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return questions.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        let cell = tableView.dequeueReusableCell(withIdentifier: "HiddenTableCell", for: indexPath) as! HiddenTableCell
        
        cell.questionText.setAttributedText(text: ThemeUtil.wrapInHtml(body: questions[indexPath.row].text!, fontsize: "15") , symbolCode: String(indexPath.row + 1))
        //cell.questionText.setFontSize(textSize: 100)
        cell.questionText.setSpacing(spacing: 5)
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //print(roles[indexPath.row].id as Any)
        
    }
    
}


