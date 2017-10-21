//
//  CalenderVC.swift
//  ViksitIOS
//
//  Created by Akshay Kumar Both on 7/26/17.
//  Copyright © 2017 Istar Feroz. All rights reserved.
//

import UIKit
import JTAppleCalendar

class CalenderVC: UIViewController {
    var filteredEvents: Array<Events> = []
    var events: Array<Events> = []
    let formatter = DateFormatter()
    var selectedDate: Date! = Date()
    
    @IBOutlet var calendarContainerYConstraint: NSLayoutConstraint!
    @IBOutlet var prevBtn: UIButton!
    @IBOutlet var nextBtn: UIButton!
    @IBOutlet var calendarView: JTAppleCalendarView!
    @IBOutlet var monthLabel: UILabel!
    @IBOutlet var yearLabel: UILabel!
    
    @IBOutlet var profileBtn: UIButton!
    @IBOutlet var coinsBtn: UIButton!
    @IBOutlet var experiencePointsLabel: UILabel!
    
    @IBOutlet var topActionBar: UIView!
    @IBOutlet var tableView: UITableView!
    
    @IBAction func onCoinsPressed(_ sender: UIButton) {
        goto(storyBoardName: "Profile", storyBoardID: "LeaderboardVC")
    }
    
    @IBAction func onProfilePressed(_ sender: UIButton) {
        goto(storyBoardName: "Profile", storyBoardID: "ProfileTBC")
    }
    
    @IBAction func onNotificationPressed(_ sender: UIButton) {
        goto(storyBoardName: "Modules", storyBoardID: "NotificationsVC")
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        topActionBar.backgroundColor = UIColor.Custom.themeColor
        
        var profileImgUrl: String = ""
        var xp: Int = 0
        var coins: Int = 0
        if let complexCache = DataCache.sharedInstance.cache["complexObject"] {
            events = ComplexObject(JSONString: complexCache).events!
            events.sort { $0.startingDate! < $1.startingDate! }
            
            filteredEvents  = events.filter({$0.startingDate! >= selectedDate})
            //print(filteredEvents.count)
            
            profileImgUrl = (ComplexObject(JSONString: complexCache).studentProfile?.profileImage)!
            xp = (ComplexObject(JSONString: complexCache).studentProfile?.experiencePoints)!
            coins = (ComplexObject(JSONString: complexCache).studentProfile?.coins)!
            
            setProfileImage(profileImgUrl: profileImgUrl)
        }
        
        coinsBtn.setTitle(" " + String(coins), for: .normal)
        experiencePointsLabel.text = String(xp)
        
        //adjust table cell according to its content
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 140
        
        //for calendar
        calendarView.scrollToDate(Date(), animateScroll: false)
        calendarView.selectDates([Date()])
        setUpCalendar()
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
    
    func makeButtonRound(button: UIButton, borderWidth: CGFloat, color: UIColor)-> UIButton{
        button.layer.cornerRadius = button.frame.width/2
        button.layer.masksToBounds = true
        button.layer.borderWidth = borderWidth
        button.layer.borderColor = color.cgColor
        
        return button
    }
    
    func goto(storyBoardName: String, storyBoardID: String) {
        let storyBoard : UIStoryboard = UIStoryboard(name: storyBoardName, bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: storyBoardID)
        self.present(nextViewController, animated:true, completion:nil)
    }
    
    func getMonth(monthIndex: String) -> String {
         //months: [Int: String] = [:]
        let months:[String:String] = [ "01":"JAN", "02":"FEB", "03":"MAR", "04":"APR", "05":"MAY", "06":"JUN", "07":"JUL", "08":"AUG", "09":"SEP", "10":"OCT", "11":"NOV", "12":"DEC" ]
        
        return months[monthIndex]!
    }
    
    func setTimeFormat(dateString: String)-> String {
        let hours = getSubstring(str: dateString, startOffest: 10, endOffset: -6)
        let trimmedhours = hours.trimmingCharacters(in: .whitespacesAndNewlines)
        print("hours - > ",trimmedhours)
        let hrs = Int(trimmedhours)
        if hrs! > 12 {
            let hourNumber = hrs! - 12
            return String(hourNumber) + getSubstring(str: dateString, startOffest: 13, endOffset: -3) + " PM"
        } else if hrs! == 00{
            return "12" + getSubstring(str: dateString, startOffest: 13, endOffset: -3) + " AM"
        } else {
            return hours + getSubstring(str: dateString, startOffest: 13, endOffset: -3) + " AM"
        }
        
    }
    
    func getSubstring (str: String, startOffest: Int, endOffset: Int) -> String {
        let start = str.index(str.startIndex, offsetBy: startOffest)
        let end = str.index(str.endIndex, offsetBy: endOffset)
        let range = start..<end
        
        return str[range]
    }
    
    // for calendar view
    @IBAction func showCalendar(_ sender: UIButton) {
        calendarContainerYConstraint.constant = 0
        
        UIView.animate(withDuration: 0.4, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    @IBAction func hideCalendar(_ sender: UIButton) {
        calendarContainerYConstraint.constant = -1000
        
        UIView.animate(withDuration: 0.2, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    @IBAction func showNext(_ sender: UIButton) {
        //calendarView.scrollToDate(formatter.date(from: "2017 01 01")!, animateScroll: false)
        //calendarView.scroll
        calendarView.scrollToSegment(.next)
    }
    
    @IBAction func showPrev(_ sender: UIButton) {
        calendarView.scrollToSegment(.previous)
    }
    
    func setUpCalendar() {
        calendarView.minimumLineSpacing = 0
        calendarView.minimumInteritemSpacing = 0
        
        //setup label
        calendarView.visibleDates { visibleDates in
            self.setupViewsOfCalendar(from: visibleDates)
        }
    }
    
}

extension CalenderVC: UITableViewDataSource, UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredEvents.count
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("\(filteredEvents[indexPath.row].id!) -- \(filteredEvents[indexPath.row].itemType!)")
        
        if filteredEvents[indexPath.row].itemType == "ASSESSMENT" {
            
        } else if (filteredEvents[indexPath.row].itemType == "PRESENTATION" || filteredEvents[indexPath.row].itemType == "LESSON_PRESENTATION") {
            let storyBoard : UIStoryboard = UIStoryboard(name: "Lesson", bundle:nil)
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "LessonsPageVC") as! LessonsPageVC
            nextViewController.lessonID = filteredEvents[indexPath.row].itemId
            self.present(nextViewController, animated:true, completion:nil)
        }
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "calenderCell", for: indexPath) as! CalenderTableCell
        
        // get start date // "2017-07-31 13:43:00"
        let month = getMonth(monthIndex: getSubstring(str: filteredEvents[indexPath.row].startDate!, startOffest: 5, endOffset: -12))
        let date = getSubstring(str: filteredEvents[indexPath.row].startDate!, startOffest: 8, endOffset: -9)
        cell.eventDateLabel.text = date
        cell.eventMonthLabel.text = month
        cell.eventDateLabel.isHidden = false
        cell.eventMonthLabel.isHidden = false

        if indexPath.row != 0 {
            if (getMonth(monthIndex: getSubstring(str: filteredEvents[indexPath.row].startDate!, startOffest: 5, endOffset: -12)) == getMonth(monthIndex: getSubstring(str: filteredEvents[indexPath.row-1].startDate!, startOffest: 5, endOffset: -12)) && getSubstring(str: filteredEvents[indexPath.row].startDate!, startOffest: 8, endOffset: -9) == getSubstring(str: filteredEvents[indexPath.row-1].startDate!, startOffest: 8, endOffset: -9)) {
                
                cell.eventDateLabel.isHidden = true
                cell.eventMonthLabel.isHidden = true
            }
        }
        
        //we are getting the exact time but india's timezone is diiferent , i.e. UTC + 5:30
        var tempDate = Date()
        let calendar = Calendar.current
        tempDate = calendar.date(byAdding: .hour, value: 5, to: tempDate)!
        tempDate = calendar.date(byAdding: .minute, value: 30, to: tempDate)!
        
        if (filteredEvents[indexPath.row].startingDate! >= tempDate  && filteredEvents[indexPath.row].endingDate! <= tempDate){
            cell.eventCardView.backgroundColor = UIColor.Custom.skyBlueColor
        }
        
        let starthours = setTimeFormat(dateString: filteredEvents[indexPath.row].startDate!)
        cell.eventDurationLabel.text = starthours /*+ getSubstring(str: events[indexPath.row].startDate!, startOffest: 13, endOffset: -3)*/
        cell.eventName.font = cell.eventName.font.withSize(12)
        cell.eventName.setHTMLFromString(htmlText: filteredEvents[indexPath.row].name!)
        
        return cell
    }

}

extension CalenderVC: JTAppleCalendarViewDataSource {
    
    func handleCellTextColor(view: JTAppleCell?, cellState: CellState) {
        guard let validCell = view as? CalenderCell else { return }
        
        let today = Date()
        if today == cellState.date {
            validCell.dataLabel.textColor = UIColor.blue
        }
        
        if cellState.isSelected {
            validCell.dataLabel.textColor = UIColor.white
        } else {
            if cellState.dateBelongsTo == .thisMonth {
                validCell.dataLabel.textColor = UIColor.black
            } else {
                validCell.dataLabel.textColor = UIColor.lightGray
            }
            
        }
    }
    
    func handleCellSelected(view: JTAppleCell?, cellState: CellState) {
        guard let validCell = view as? CalenderCell else { return }
        
        if cellState.isSelected {
            validCell.selectedView.isHidden = false
            selectedDate = cellState.date
            filteredEvents  = events.filter({$0.startingDate! >= selectedDate})
            tableView.reloadData()
            print(selectedDate)
        } else {
            validCell.selectedView.isHidden = true
        }
    }
    
    func setupViewsOfCalendar(from visibleDates: DateSegmentInfo) {
        let date = visibleDates.monthDates.first!.date
        
        self.formatter.dateFormat = "yyyy"
        self.yearLabel.text = self.formatter.string(from: date)
        
        self.formatter.dateFormat = "MMMM"
        self.monthLabel.text = self.formatter.string(from: date)
    }
    
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        formatter.dateFormat = "yyyy MM dd"
        formatter.timeZone = Calendar.current.timeZone
        formatter.locale = Calendar.current.locale
        
        // setting start and end dates for the calendar
        let startDate = formatter.date(from: "2016 01 01")!
        let endDate = formatter.date(from: "2023 12 31")!
        
        let parameters = ConfigurationParameters(startDate: startDate, endDate: endDate)
        return parameters
    }
    
}

extension CalenderVC: JTAppleCalendarViewDelegate {
    
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "CalenderCell", for: indexPath) as! CalenderCell
        cell.dataLabel.text = cellState.text
        
        handleCellSelected(view: cell, cellState: cellState)
        handleCellTextColor(view: cell, cellState: cellState)
        return cell
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        handleCellSelected(view: cell, cellState: cellState)
        handleCellTextColor(view: cell, cellState: cellState)
        //print(date)
        
        //get the date, filter list by date and reload data of event's table view 
        //startDate = date
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        handleCellSelected(view: cell, cellState: cellState)
        handleCellTextColor(view: cell, cellState: cellState)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        setupViewsOfCalendar(from: visibleDates)
        
    }
}


