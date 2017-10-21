
import UIKit
import AnimatedCollectionViewLayout

class TasksVC: UIViewController{
    
    var tasks: Array<Tasks> = []
    var completedTasks: Array<Tasks> = []
    var incompleteTasks: Array<Tasks> = []
    var visibleCellIndex: IndexPath!
    var userID: Int = -1
    var currentPage = 0
    let dotsCount = 5

    let cellWidthScaling: CGFloat = 0.85
    let cellHeightScaling: CGFloat = 0.76
    @IBOutlet var cards: UICollectionView!
    
    @IBOutlet var pageControl: UIPageControl!
    @IBOutlet var topActionBarHeight: NSLayoutConstraint!
    
    @IBOutlet var topActionBar: UIView!
    @IBOutlet var coinsBtn: UIButton!
    @IBOutlet var experiencePoints: UILabel!
    @IBOutlet var profileBtn: UIButton!
   
    @IBAction func onCoinsPressed(_ sender: UIButton) {
        goto(storyBoardName: "Profile", storyBoardID: "LeaderboardVC")
    }
    
    @IBAction func onNotificationPressed(_ sender: UIButton) {
        goto(storyBoardName: "Modules", storyBoardID: "NotificationsVC")
        
    }
    
    @IBAction func onProfilePressed(_ sender: UIButton) {
        goto(storyBoardName: "Profile", storyBoardID: "ProfileTBC")
    }
    
    func setCollectionCellSize(){
        let screenSize = UIScreen.main.bounds.size
        let cellWidth = floor(screenSize.width * cellWidthScaling)
        let cellHeight = floor(screenSize.height * cellHeightScaling)
        
        let insetX = (view.bounds.width - cellWidth)/2.0
        let insetY = (view.bounds.height - cellHeight)/2.0
        
        let layout = AnimatedCollectionViewLayout()
        layout.animator = LinearCardAttributesAnimator( minAlpha: 0.5, itemSpacing: 0.1, scaleRate: 1.0)
        
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: cellWidth, height: cellHeight)
        cards.collectionViewLayout = layout
        cards.contentInset = UIEdgeInsets(top: (1 * insetY), left: insetX, bottom: ( insetY + 15), right: insetX)
        
        self.cards.delegate = self
        self.cards.dataSource = self
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if incompleteTasks.count < dotsCount {
            if completedTasks.count != 0 {
                self.pageControl.numberOfPages = incompleteTasks.count + 1
            } else {
                self.pageControl.numberOfPages = incompleteTasks.count
            }
            
        } else {
            
            self.pageControl.numberOfPages = dotsCount
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.pageControl.numberOfPages = dotsCount
        topActionBar.backgroundColor = UIColor.Custom.themeColor
        pageControl.currentPageIndicatorTintColor = UIColor(red:0.14, green:0.71, blue:0.98, alpha:1.0)
        pageControl.pageIndicatorTintColor = UIColor(red:0.88, green:0.88, blue:0.88, alpha:1.0)
        pageControl.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        //topActionBarHeight.constant = CGFloat.Custom.topActionBarHeight
        
        setCollectionCellSize()
        
        var profileImgUrl: String = ""
        var xp: Int = 0
        var coins: Int = 0
        
        if let complexCache = DataCache.sharedInstance.cache["complexObject"] {
            tasks = (ComplexObject(JSONString: complexCache).tasks)!
            completedTasks = tasks.filter({$0.status == "COMPLETED"}).filter({$0.dateFormat == Date()}) //filtering completed tasks
            incompleteTasks = tasks.filter({$0.status == "INCOMPLETE"}) //filtering incomplete tasks
            userID = (ComplexObject(JSONString: complexCache).studentProfile?.id!)!
            profileImgUrl = (ComplexObject(JSONString: complexCache).studentProfile?.profileImage)!
            xp = (ComplexObject(JSONString: complexCache).studentProfile?.experiencePoints)!
            coins = (ComplexObject(JSONString: complexCache).studentProfile?.coins)!
            
            setProfileImage(profileImgUrl: profileImgUrl)
        }
        
        //set userpoints in toolbar
        coinsBtn.setTitle(" " + String(coins), for: .normal)
        experiencePoints.text = String(xp)
        
    }

    func goto(storyBoardName: String, storyBoardID: String) {
        let storyBoard : UIStoryboard = UIStoryboard(name: storyBoardName, bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: storyBoardID)
        self.present(nextViewController, animated:true, completion:nil)
    }
    
    override var prefersStatusBarHidden : Bool {
        return false
    }

    func setProfileImage(profileImgUrl: String) {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let finalPath = path + "/Viksit/Viksit_PROFILE_PIC/profile_pic.jpg"
        let fileExists = FileManager().fileExists(atPath: finalPath)
        if fileExists {
            profileBtn.setBackgroundImage(UIImage(contentsOfFile: finalPath), for: .normal)
            print("found")
        } else {
            print("\(finalPath) not found")
            
            if let url = URL(string: profileImgUrl) {
                DispatchQueue.global().async {
                    let data = try? Data(contentsOf: url)
                    
                    DispatchQueue.main.async {
                        if data != nil {
                            self.profileBtn.setBackgroundImage(UIImage(data: data!), for: .normal)
                        } else {
                            self.profileBtn.setBackgroundImage(UIImage(named: "coins"), for: .normal)
                        }
                    }
                }
            }
        }
        
        profileBtn.makeButtonRound(borderWidth: 2.5, borderColor: UIColor.white)
    }
    
    
    func loadImageAsync(url: String, imgView: UIImageView){
        do {
            let url = URL(string: url)
            DispatchQueue.global().async {
                let data = try? Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
                DispatchQueue.main.async {
                    if data != nil {
                        imgView.image = UIImage(data: data!)

                    } else {
                        imgView.image = UIImage(named: "info")
                    }
                                    }
            }
        }catch let error as NSError {
            print(" Error \(error)")
        }
    }
    
    
    func getSubstring (str: String, startOffest: Int, endOffset: Int)-> String {
        let start = str.index(str.startIndex, offsetBy: startOffest)
        let end = str.index(str.endIndex, offsetBy: endOffset)
        let range = start..<end
        
        return str[range]
    }
    
}

extension TasksVC: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if completedTasks.count == 0 {
            return incompleteTasks.count
        }
        return incompleteTasks.count + 1
    }
    
    @IBAction func startBtnTapped(_ sender: UIButton) -> Void {
        
        print(sender.tag)
        print("\(incompleteTasks[sender.tag].id) -- \(incompleteTasks[sender.tag].title) -- \(incompleteTasks[sender.tag].header)")
        
        let task = incompleteTasks[sender.tag]
        
        /*
         var storyBoardName: String = ""
         var storyBoardID: String = ""*/
        print(task.itemType)
        
        if task.itemType == "LESSON_PRESENTATION" {//LessonsPageVC
            let storyBoard : UIStoryboard = UIStoryboard(name: "Lesson", bundle:nil)
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "LessonsPageVC") as! LessonsPageVC
            nextViewController.lessonID = incompleteTasks[sender.tag].itemId
            self.present(nextViewController, animated:true, completion:nil)
        } else if (task.itemType == "CLASSROOM_SESSION_STUDENT" || task.itemType == "CLASSROOM_SESSION") {
            
        } else if (task.itemType == "ASSESSMENT" || task.itemType == "LESSON_ASSESSMENT") {
            let storyBoard : UIStoryboard = UIStoryboard(name: "assessment", bundle:nil)
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "AssessmentVC") as! AssessmentVC
            nextViewController.taskID = incompleteTasks[sender.tag].id!
            nextViewController.userID = userID
            self.present(nextViewController, animated:true, completion:nil)
            
        } else if task.itemType == "LESSON_VIDEO" { //
            
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if completedTasks.count != 0 {
            if indexPath.row == 0 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TodaysTaskCell", for: indexPath) as! TodaysTaskCell
                cell.tasksCompletedTitleLabel.text = "\(completedTasks.count) Tasks Completed"
                cell.tableView.dataSource = self
                cell.tableView.delegate = self
                cell.tableView.tag = -1000
                cell.tableView.rowHeight = UITableViewAutomaticDimension
                cell.tableView.estimatedRowHeight = 140
                
                return cell
            } else {
                // -1 done in each index becausea the first that is added is todays task card
                print("\(incompleteTasks[indexPath.row-1].title) -- at -- \(indexPath.row)")
                //indexPath = IndexPath(row: indexPath.row-1, section: 0)
                if incompleteTasks[indexPath.row-1].itemType == "LESSON_PRESENTATION" {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "presentationCell", for: indexPath) as! PresentationCell
                    
                    cell.headerLabel.text = incompleteTasks[indexPath.row-1].header?.uppercased()
                    cell.titleLabel.text = incompleteTasks[indexPath.row-1].title
                    cell.descriptionLabel.text = incompleteTasks[indexPath.row-1].description
                    //loadImageAsync(url: incompleteTasks[indexPath.row-1].imageURL!, imgView: cell.lessonImage)
                    setTaskImage(imgUrl: incompleteTasks[indexPath.row-1].imageURL!, taskID: incompleteTasks[indexPath.row-1].id!, imageView: cell.lessonImage)
                    cell.videoImg.isHidden = true
                    cell.watchBtn.tag = indexPath.row-1
                    cell.watchBtn.backgroundColor = UIColor.Custom.themeColor
                    cell.watchBtn.setImage(UIImage(named: "presentation"), for: .normal)
                    cell.watchBtn.tintColor = UIColor.white
                    cell.watchBtn.imageEdgeInsets = UIEdgeInsets(top: 9, left: 10, bottom: 9, right: 20)
                    cell.watchBtn.addTarget(self, action: #selector(startBtnTapped), for: UIControlEvents.touchUpInside)
                    
                    return cell
                } else if (incompleteTasks[indexPath.row-1].itemType == "CLASSROOM_SESSION_STUDENT"  || incompleteTasks[indexPath.row-1].itemType == "CLASSROOM_SESSION") {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ClassCell", for: indexPath) as! ClassCell
                    
                    print(indexPath.row-1)
                    cell.headerLabel.text = incompleteTasks[indexPath.row-1].header?.uppercased()
                    cell.titleLabel.text = incompleteTasks[indexPath.row-1].title
                    //loadImageAsync(url: incompleteTasks[indexPath.row-1].imageURL!, imgView: cell.assessmentImg)
                    
                    setTaskImage(imgUrl: incompleteTasks[indexPath.row-1].imageURL!, taskID: incompleteTasks[indexPath.row-1].id!, imageView: cell.classImg)
                    
                    if let hrs = incompleteTasks[indexPath.row-1].durationHours {
                        cell.timeLabel.text = String(hrs) + " hrs"
                    }
                    
                    if let classRoomId = incompleteTasks[indexPath.row-1].classRoomId {
                        cell.locationLabel.text = "Room #" + String(classRoomId)
                    }
                    if let group = incompleteTasks[indexPath.row-1].groupName {
                        cell.batchLabel.text = group
                    }
                    
                    print(incompleteTasks[indexPath.row-1].id)
                    cell.startBtn.setTitle("START CLASS", for: .normal)
                    cell.startBtn.tag = indexPath.row-1
                    cell.startBtn.backgroundColor = UIColor.Custom.themeColor
                    cell.startBtn.setImage(UIImage(named: "play_icon"), for: .normal)
                    cell.startBtn.tintColor = UIColor.white
                    cell.startBtn.imageEdgeInsets = UIEdgeInsets(top: 8, left: 10, bottom: 8, right: 20)
                    cell.startBtn.addTarget(self, action: #selector(startBtnTapped), for: UIControlEvents.touchUpInside)
                    
                    return cell
                } else if (incompleteTasks[indexPath.row-1].itemType == "ASSESSMENT" || incompleteTasks[indexPath.row].itemType == "LESSON_ASSESSMENT") {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "assessmentCell", for: indexPath) as! AssessmentCell
                    
                    print(indexPath.row-1)
                    cell.headerLabel.text = incompleteTasks[indexPath.row-1].header?.uppercased()
                    cell.titleLabel.text = incompleteTasks[indexPath.row-1].title
                    cell.descriptionLabel.text = incompleteTasks[indexPath.row-1].description
                    if incompleteTasks[indexPath.row-1].imageURL != nil {
                        //loadImageAsync(url: incompleteTasks[indexPath.row-1].imageURL!, imgView: cell.assessmentImg)
                        setTaskImage(imgUrl: incompleteTasks[indexPath.row-1].imageURL!, taskID: incompleteTasks[indexPath.row-1].id!, imageView: cell.assessmentImg)
                    }
                    
                    if let ques = incompleteTasks[indexPath.row-1].numberOfQuestions {
                        cell.numOfQuesLabel.text = String(ques)
                    }
                    
                    if let y = incompleteTasks[indexPath.row-1].itemPoints {
                        cell.pointsLabel.text = String(y)
                    }
                    
                    if let dur = incompleteTasks[indexPath.row-1].duration {
                        cell.durationLabel.text = String(dur)
                    }
                    
                    cell.xpText.text = "Experience"
                    cell.quesText.text = "Questions"
                    cell.timeText.text = "Duration"
                    cell.startBtn.setTitle("START ASSESSMENT", for: .normal)
                    cell.startBtn.tag = indexPath.row-1
                    cell.startBtn.backgroundColor = UIColor.Custom.themeColor
                    cell.startBtn.setImage(UIImage(named: "assessment_icon"), for: .normal)
                    cell.startBtn.tintColor = UIColor.white
                    cell.startBtn.imageEdgeInsets = UIEdgeInsets(top: 9, left: 10, bottom: 9, right: 20)
                    cell.startBtn.addTarget(self, action: #selector(startBtnTapped), for: UIControlEvents.touchUpInside)
                    
                    return cell
                    
                } else if incompleteTasks[indexPath.row-1].itemType == "LESSON_VIDEO"{
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "presentationCell", for: indexPath) as! PresentationCell
                    
                    print(indexPath.row-1)
                    cell.headerLabel.text = incompleteTasks[indexPath.row-1].header?.uppercased()
                    cell.titleLabel.text = incompleteTasks[indexPath.row-1].title
                    cell.descriptionLabel.text = incompleteTasks[indexPath.row-1].description
                    //loadImageAsync(url: incompleteTasks[indexPath.row-1].imageURL!, imgView: cell.lessonImage)
                    setTaskImage(imgUrl: incompleteTasks[indexPath.row-1].imageURL!, taskID: incompleteTasks[indexPath.row-1].id!, imageView: cell.lessonImage)
                    
                    cell.videoImg.isHidden = false
                    cell.watchBtn.tag = indexPath.row-1
                    cell.watchBtn.backgroundColor = UIColor.Custom.themeColor
                    cell.watchBtn.addTarget(self, action: #selector(startBtnTapped), for: UIControlEvents.touchUpInside)
                    
                    return cell
                } else {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "presentationCell", for: indexPath) as! PresentationCell
                    //loadImageAsync(url: incompleteTasks[indexPath.row-1].imageURL!, imgView: cell.lessonImage)
                    setTaskImage(imgUrl: incompleteTasks[indexPath.row-1].imageURL!, taskID: incompleteTasks[indexPath.row-1].id!, imageView: cell.lessonImage)
                    cell.headerLabel.text = incompleteTasks[indexPath.row-1].header?.uppercased()
                    cell.titleLabel.text = incompleteTasks[indexPath.row-1].title
                    cell.descriptionLabel.text = incompleteTasks[indexPath.row-1].description
                    cell.watchBtn.tag = indexPath.row-1
                    cell.videoImg.isHidden = true
                    //cell.watchBtn.setTitle("START WEBINAR", for: .normal)
                    cell.watchBtn.backgroundColor = UIColor.Custom.themeColor
                    cell.watchBtn.addTarget(self, action: #selector(startBtnTapped), for: UIControlEvents.touchUpInside)
                    print(incompleteTasks[indexPath.row-1].itemType)
                    return cell
                }
            }
        } else {
            if incompleteTasks[indexPath.row].itemType == "LESSON_PRESENTATION" {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "presentationCell", for: indexPath) as! PresentationCell
                
                
                cell.headerLabel.text = incompleteTasks[indexPath.row].header?.uppercased()
                cell.titleLabel.text = incompleteTasks[indexPath.row].title
                cell.descriptionLabel.text = incompleteTasks[indexPath.row].description
                //loadImageAsync(url: incompleteTasks[indexPath.row].imageURL!, imgView: cell.lessonImage)
                setTaskImage(imgUrl: incompleteTasks[indexPath.row].imageURL!, taskID: incompleteTasks[indexPath.row].id!, imageView: cell.lessonImage)
                cell.videoImg.isHidden = true
                cell.watchBtn.tag = indexPath.row
                cell.watchBtn.backgroundColor = UIColor.Custom.themeColor
                cell.watchBtn.setImage(UIImage(named: "presentation"), for: .normal)
                cell.watchBtn.tintColor = UIColor.white
                cell.watchBtn.imageEdgeInsets = UIEdgeInsets(top: 9, left: 10, bottom: 9, right: 20)
                cell.watchBtn.addTarget(self, action: #selector(startBtnTapped), for: UIControlEvents.touchUpInside)
                
                return cell
            } else if (incompleteTasks[indexPath.row].itemType == "CLASSROOM_SESSION_STUDENT" /*|| incompleteTasks[indexPath.row].itemType == "WEBINAR_STUDENT"*/ || incompleteTasks[indexPath.row].itemType == "CLASSROOM_SESSION") {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ClassCell", for: indexPath) as! ClassCell
                
                cell.headerLabel.text = incompleteTasks[indexPath.row].header?.uppercased()
                cell.titleLabel.text = incompleteTasks[indexPath.row].title
                //loadImageAsync(url: incompleteTasks[indexPath.row].imageURL!, imgView: cell.assessmentImg)
                setTaskImage(imgUrl: incompleteTasks[indexPath.row].imageURL!, taskID: incompleteTasks[indexPath.row].id!, imageView: cell.classImg)
                
                if let hrs = incompleteTasks[indexPath.row].durationHours {
                    cell.timeLabel.text = String(hrs) + " hrs"
                }
                
                if let classRoomId = incompleteTasks[indexPath.row].classRoomId {
                    cell.locationLabel.text = "#" + String(classRoomId)
                }
                
                if let group = incompleteTasks[indexPath.row].groupName {
                    cell.batchLabel.text = group
                }
                
                cell.startBtn.setTitle("START CLASS", for: .normal)
                cell.startBtn.tag = indexPath.row
                cell.startBtn.backgroundColor = UIColor.Custom.themeColor
                cell.startBtn.setImage(UIImage(named: "play_icon"), for: .normal)
                cell.startBtn.tintColor = UIColor.white
                cell.startBtn.imageEdgeInsets = UIEdgeInsets(top: 8, left: 10, bottom: 8, right: 20)
                cell.startBtn.addTarget(self, action: #selector(startBtnTapped), for: UIControlEvents.touchUpInside)
                
                return cell
            } else if (incompleteTasks[indexPath.row].itemType == "ASSESSMENT" || incompleteTasks[indexPath.row].itemType == "LESSON_ASSESSMENT") {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "assessmentCell", for: indexPath) as! AssessmentCell
                
                cell.headerLabel.text = incompleteTasks[indexPath.row].header?.uppercased()
                cell.titleLabel.text = incompleteTasks[indexPath.row].title
                cell.descriptionLabel.text = incompleteTasks[indexPath.row].description
                if incompleteTasks[indexPath.row].imageURL != nil {
                    //loadImageAsync(url: incompleteTasks[indexPath.row].imageURL!, imgView: cell.assessmentImg)
                    setTaskImage(imgUrl: incompleteTasks[indexPath.row].imageURL!, taskID: incompleteTasks[indexPath.row].id!, imageView: cell.assessmentImg)
                }
                
                if let ques = incompleteTasks[indexPath.row].numberOfQuestions {
                    cell.numOfQuesLabel.text = String(ques)
                }
                
                if let y = incompleteTasks[indexPath.row].itemPoints {
                    cell.pointsLabel.text = String(y)
                }
                
                if let dur = incompleteTasks[indexPath.row].duration {
                    cell.durationLabel.text = String(dur)
                }
                cell.xpText.text = "Experience"
                cell.quesText.text = "Questions"
                cell.timeText.text = "Duration"
                cell.startBtn.setTitle("START ASSESSMENT", for: .normal)
                cell.startBtn.tag = indexPath.row
                cell.startBtn.backgroundColor = UIColor.Custom.themeColor
                cell.startBtn.setImage(UIImage(named: "assessment_icon"), for: .normal)
                cell.startBtn.tintColor = UIColor.white
                cell.startBtn.imageEdgeInsets = UIEdgeInsets(top: 9, left: 10, bottom: 9, right: 20)
                cell.startBtn.addTarget(self, action: #selector(startBtnTapped), for: UIControlEvents.touchUpInside)
                
                return cell
                
            }else if incompleteTasks[indexPath.row].itemType == "LESSON_VIDEO"{
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "presentationCell", for: indexPath) as! PresentationCell
                
                cell.headerLabel.text = incompleteTasks[indexPath.row].header?.uppercased()
                cell.titleLabel.text = incompleteTasks[indexPath.row].title
                cell.descriptionLabel.text = incompleteTasks[indexPath.row].description
                //loadImageAsync(url: incompleteTasks[indexPath.row].imageURL!, imgView: cell.lessonImage)
                setTaskImage(imgUrl: incompleteTasks[indexPath.row].imageURL!, taskID: incompleteTasks[indexPath.row].id!, imageView: cell.lessonImage)
                
                cell.videoImg.isHidden = false
                cell.watchBtn.tag = indexPath.row
                cell.watchBtn.backgroundColor = UIColor.Custom.themeColor
                cell.watchBtn.addTarget(self, action: #selector(startBtnTapped), for: UIControlEvents.touchUpInside)
                
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "presentationCell", for: indexPath) as! PresentationCell
                //loadImageAsync(url: incompleteTasks[indexPath.row].imageURL!, imgView: cell.lessonImage)
                setTaskImage(imgUrl: incompleteTasks[indexPath.row].imageURL!, taskID: incompleteTasks[indexPath.row].id!, imageView: cell.lessonImage)
                cell.headerLabel.text = incompleteTasks[indexPath.row].header?.uppercased()
                cell.titleLabel.text = incompleteTasks[indexPath.row].title
                cell.descriptionLabel.text = incompleteTasks[indexPath.row].description
                cell.watchBtn.tag = indexPath.row
                cell.videoImg.isHidden = true
                //cell.watchBtn.setTitle("START WEBINAR", for: .normal)
                cell.watchBtn.backgroundColor = UIColor.Custom.themeColor
                cell.watchBtn.addTarget(self, action: #selector(startBtnTapped), for: UIControlEvents.touchUpInside)
                print(incompleteTasks[indexPath.row].itemType)
                return cell
            }
        }
        
    }
    
    func setTaskImage(imgUrl: String, taskID: Int, imageView: UIImageView) {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let finalPath = path + "/Viksit/Viksit_TASKS/\(taskID)/\(imgUrl.components(separatedBy: "/").last!)"
        print(finalPath)
        let fileExists = FileManager().fileExists(atPath: finalPath)
        if fileExists {
            imageView.image = UIImage(contentsOfFile: finalPath)
            //profileBtn.setBackgroundImage(UIImage(contentsOfFile: finalPath), for: .normal)
            print("found")
        } else {
            print("\(finalPath) not found")
            loadImageAsync(url: imgUrl, imgView: imageView)
        }
        
        //profileBtn.makeButtonRound(borderWidth: 2.5, borderColor: UIColor.white)
    }
    

}
extension TasksVC: UICollectionViewDelegate, UIScrollViewDelegate {
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        if scrollView.tag == -1000 { //so table view scrolling doesnt get effected by the scrollview delegate methods
            return
        }
        let layout = cards.collectionViewLayout as! AnimatedCollectionViewLayout
        let cellWidthIncludingSpacing = layout.itemSize.width + layout.minimumLineSpacing
        
        var offset = targetContentOffset.pointee
        var index = (offset.x + scrollView.contentInset.left)/cellWidthIncludingSpacing
        
        let roundedIndex = round(index)
        offset = CGPoint(x: roundedIndex * cellWidthIncludingSpacing - scrollView.contentInset.left, y: -scrollView.contentInset.top)
        targetContentOffset.pointee = offset
     
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        if scrollView.tag == -1000 { //so table view scrolling doesnt get effected by the scrollview delegate methods
            return
        }
        let pageWidth = scrollView.frame.width
        self.currentPage = Int((scrollView.contentOffset.x + pageWidth / 2) / pageWidth)
        self.pageControl.currentPage = self.currentPage % dotsCount
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        if scrollView.tag == -1000 { //so  table view scrolling doesnt get effected by the scrollview delegate methods
            return
        }
        
        var visibleRect = CGRect()
        visibleRect.origin = cards.contentOffset
        visibleRect.size = cards.bounds.size
        
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        let visibleIndexPath: IndexPath = cards.indexPathForItem(at: visiblePoint)!
        
        //print(visibleIndexPath.row)
        self.visibleCellIndex = visibleIndexPath
        //self.visibleCellIndex = collectionView.indexPathsForVisibleItems.first!
        //print(self.visibleCellIndex.row)
    }
    
}

extension TasksVC: UITableViewDataSource, UITableViewDelegate {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return completedTasks.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.separatorStyle = .none
        
        tableView.showsVerticalScrollIndicator = false
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodaysTaskItemCell", for: indexPath) as! TodaysTaskItemCell
        cell.selectionStyle = .none
        let calendar = Calendar.current
        let comp = calendar.dateComponents([.hour, .minute], from: completedTasks[indexPath.row].dateFormat!)
        let hour = comp.hour
        let minute = comp.minute
        cell.itemTitleLabel.text = completedTasks[indexPath.row].title
        cell.itemTimeLabel.text = "at \(hour!):\(minute!)"
        //inserting image from url async for roleImage
        if completedTasks[indexPath.row].itemType == "ASSESSMENT" {
            cell.itemImage.image = UIImage(named: "assessment_icon")
            
        } else if (completedTasks[indexPath.row].itemType == "PRESENTATION" || completedTasks[indexPath.row].itemType == "LESSON_PRESENTATION") {
            cell.itemImage.image = UIImage(named: "presentation")
        }
        
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        print(completedTasks[indexPath.row].title)
        
        if completedTasks[indexPath.row].itemType == "ASSESSMENT" {
            if let complexCache = DataCache.sharedInstance.cache["complexObject"] {
                if let reports = (ComplexObject(JSONString: complexCache).assessmentreports) {
                    //let report = reports.first({$0.id == completedTasks[indexPath.row].itemId}) //filtering with id
                    if let report = reports.first(where: { $0.id == completedTasks[indexPath.row].itemId }) {
                        print(report.id)
                    } 
                    
                }
                
            }

        } else if (completedTasks[indexPath.row].itemType == "PRESENTATION" || completedTasks[indexPath.row].itemType == "LESSON_PRESENTATION") {
            let storyBoard : UIStoryboard = UIStoryboard(name: "Lesson", bundle:nil)
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "LessonsPageVC") as! LessonsPageVC
            nextViewController.lessonID = completedTasks[indexPath.row].itemId
            self.present(nextViewController, animated:true, completion:nil)
        }
    }

}


