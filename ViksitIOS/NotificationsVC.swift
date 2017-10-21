
import UIKit

class NotificationsVC: UIViewController {

    var notifications: Array<Notifications> = []
    @IBOutlet var tableView: UITableView!
    
    @IBOutlet var topActionBar: UIView!
    @IBAction func onBackPressed(_ sender: UIButton) {
        
        let storyBoard : UIStoryboard = UIStoryboard(name: "Tab", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "TabBarController") as! TabBarController
        nextViewController.selectedIndex = 0
        self.present(nextViewController, animated:true, completion:nil)
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        topActionBar.backgroundColor = UIColor.Custom.themeColor
        tableView.backgroundColor = UIColor(red:0.96, green:0.96, blue:0.98, alpha:1.0)
        tableView.showsVerticalScrollIndicator = true
        
        if let complexCache = DataCache.sharedInstance.cache["complexObject"] {
            let complexObject = ComplexObject(JSONString: complexCache)
            notifications = complexObject.notifications!
        }
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 140

    }

    
}

extension NotificationsVC: UITableViewDataSource, UITableViewDelegate {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("\(notifications[indexPath.row].id!)   -   \(notifications[indexPath.row].itemType)")
        
        if notifications[indexPath.row].itemType == "ASSESSMENT" || notifications[indexPath.row].itemType == "LESSON_ASSESSMENT" {

            let storyBoard : UIStoryboard = UIStoryboard(name: "assessment", bundle:nil)
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "AssessmentVC")
            self.present(nextViewController, animated:true, completion:nil)
        } else if notifications[indexPath.row].itemType == "LESSON_PRESENTATION" || notifications[indexPath.row].itemType == "PRESENTATION" {
            let storyBoard : UIStoryboard = UIStoryboard(name: "Lesson", bundle:nil)
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "LessonsPageVC") as! LessonsPageVC
            nextViewController.lessonID = notifications[indexPath.row].itemId
            self.present(nextViewController, animated:true, completion:nil)
        } else if notifications[indexPath.row].itemType == "CLASSROOM_SESSION_STUDENT" {
            
        }
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        let cell = tableView.dequeueReusableCell(withIdentifier: "notificationCell", for: indexPath) as! NotificationTableCell
        setNotificationImage(imgUrl: notifications[indexPath.row].imageURL!, imageView: cell.notificationImage)
        
        /*
        //loading image from url async
        do {
            let url = URL(string: notifications[indexPath.row].imageURL!)
            DispatchQueue.global().async {
                let data = try? Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
                DispatchQueue.main.async {
                    if data != nil {
                        cell.notificationImage.image = UIImage(data: data!)
                    } else {
                        cell.notificationImage.image = UIImage(named: "coins")
                    }
                    
                }
            }
        } catch let error as NSError {
            print(" Error \(error)")
        }*/
        
        if notifications[indexPath.row].itemType != "ASSESSMENT" || notifications[indexPath.row].itemType != "LESSON_ASSESSMENT"{
            cell.notificationImage.makeImageRound()
        }
        //
       
        //
        var tempDate = Date()
        let calendar = Calendar.current
        tempDate = calendar.date(byAdding: .hour, value: 5, to: tempDate)!
        tempDate = calendar.date(byAdding: .minute, value: 30, to: tempDate)!
        if notifications[indexPath.row].timeFormat == tempDate {
            let calendar = Calendar.current
            let comp = calendar.dateComponents([.hour, .minute], from: notifications[indexPath.row].timeFormat!)
            let hour = comp.hour
            let minute = comp.minute
            cell.notificationDuration.text = "at \(hour!):\(minute!)"
        } else {
            let calendar = Calendar.current
            let date = calendar.startOfDay(for: notifications[indexPath.row].timeFormat!)
            let components = calendar.dateComponents([.day], from: date, to: Date())
            if components.day! > 30 {
                let month = components.day!/30
                cell.notificationDuration.text = "\(month) month ago"
            } else {
                cell.notificationDuration.text = "\(components.day!) days ago"
            }
            
        }
        cell.contentView.backgroundColor = UIColor(red:0.96, green:0.96, blue:0.98, alpha:1.0)
        
        //cell.notificationMessage.attributedText = Helper.setHTMLString(testString: notifications[indexPath.row].message!, fontsize: "14")
        cell.notificationMessage.font = cell.notificationMessage.font.withSize(11)
        cell.notificationMessage.setHTMLFromString(htmlText: notifications[indexPath.row].message!)
        
        return cell
    }
    
    func setNotificationImage(imgUrl: String, imageView: UIImageView) {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let finalPath = path + "/Viksit/Viksit_NOTIFICATION/\(imgUrl.components(separatedBy: "/").last!)"
        print(finalPath)
        let fileExists = FileManager().fileExists(atPath: finalPath)
        if fileExists {
            imageView.image = UIImage(contentsOfFile: finalPath)
            print("found")
        } else {
            print("\(finalPath) not found")
            ImageAsyncLoader.loadImageAsync(url: imgUrl, imgView: imageView)
        }
    }

}
