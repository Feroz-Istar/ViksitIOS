
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
        
        if let complexCache = DataCache.sharedInstance.cache["complexObject"] {
            let complexObject = ComplexObject(JSONString: complexCache)
            notifications = complexObject.notifications!
        }
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 140

        // Do any additional setup after loading the view.
    }

    
}

extension NotificationsVC: UITableViewDataSource, UITableViewDelegate {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(notifications[indexPath.row].id!)
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        let cell = tableView.dequeueReusableCell(withIdentifier: "notificationCell", for: indexPath) as! NotificationTableCell
        
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
        }
        if notifications[indexPath.row].itemType != "ASSESSMENT" {
            cell.notificationImage.makeImageRound()
        }
        
        cell.contentView.backgroundColor = UIColor(red:0.96, green:0.96, blue:0.98, alpha:1.0)
        cell.notificationDuration.text = notifications[indexPath.row].time
        //cell.notificationMessage.attributedText = Helper.setHTMLString(testString: notifications[indexPath.row].message!, fontsize: "14")
        cell.notificationMessage.font = cell.notificationMessage.font.withSize(11)
        cell.notificationMessage.setHTMLFromString(htmlText: notifications[indexPath.row].message!)
        
        
        return cell
    }


}
