
import Foundation

public class Notifications {
    
	public var id : Int?
	public var message : String?
	public var status : String?
	public var imageURL : String?
	public var time : String?
    public var timeFormat: Date?
	public var itemType : String?
    public var itemId : Int?
    public var item : Item?

    init (json: [String: Any]) {
        
        if json["id"] != nil {
            self.id = json["id"] as? Int
            //print("skill id is ",self.id! )
        }
	
        if json["message"] != nil {
            self.message = json["message"] as? String
            //print("skill id is ",self.id! )
        }

        if json["status"] != nil {
            self.status = json["status"] as? String
            //print("skill id is ",self.id! )
        }

        if json["imageURL"] != nil {
            self.imageURL = json["imageURL"] as? String
            //print("skill id is ",self.id! )
        }

        if json["time"] != nil {
            self.time = json["time"] as? String
            var dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            self.timeFormat = dateFormatter.date(from: time!)
        }
        

        if json["itemType"] != nil {
            self.itemType = json["itemType"] as? String
        }
        
        if json["itemId"] != nil {
            self.itemId = json["itemId"] as? Int
            //print("notification itemId is ",self.itemId! )
        }
        
		
		if (json["item"] != nil) {
            self.item = Item(json: json["item"] as! [String:Any])
        }
	}    

}
