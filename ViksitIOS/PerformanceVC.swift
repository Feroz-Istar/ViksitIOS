//
//  PerformanceVC.swift
//  ViksitIOS
//
//  Created by Akshay Kumar Both on 8/3/17.
//  Copyright © 2017 Istar Feroz. All rights reserved.
//

import UIKit

class PerformanceVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITableViewDelegate, UITableViewDataSource {
    
    var studentProfile: StudentProfile?
    var skills: [Skills] = []
    var childSkills: [Skills] = []
    var grandChildSkills: [Skills] = []
    var selectedRowIndex: IndexPath = IndexPath(row: -1, section: 0)
    var isExpanded: Bool = false
    
    
    @IBOutlet var subSkillTableView: UITableView!
    
    @IBOutlet var skillCollections: UICollectionView!
    
    @IBOutlet var profileImage: CircularImage!
    @IBOutlet var userXPLabel: UILabel!
    @IBOutlet var userBatchRankLabel: UILabel!
    @IBOutlet var userNameLabel: UILabel!
    
    @IBAction func uploadPhotoPressed(_ sender: CircularButton) {
        
    }
    
    @IBAction func onBackPressed(_ sender: UIButton) {
        goto(storyBoardName: "Tab", storyBoardID: "TabBarController")
    }
    
    @IBAction func onLogoutPressed(_ sender: UIButton) {
        goto(storyBoardName: "Tab", storyBoardID: "TabBarController")
    }
    
    func goto(storyBoardName: String, storyBoardID: String) {
        let storyBoard : UIStoryboard = UIStoryboard(name: storyBoardName, bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: storyBoardID)
        self.present(nextViewController, animated:true, completion:nil)
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
                        imgView.image = UIImage(named: "coins")
                        
                    }
                }
            }
            
        }catch let error as NSError {
            print(" Error \(error)")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let complexCache = DataCache.sharedInstance.cache["complexObject"] {
            studentProfile = ComplexObject(JSONString: complexCache).studentProfile!
            skills = ComplexObject(JSONString: complexCache).skills!
        }
        
        loadImageAsync(url: (studentProfile?.profileImage)!, imgView: profileImage)
        if let xp = studentProfile?.experiencePoints {
            userXPLabel.text = "\(xp)"
        }
        
        if let rank = studentProfile?.batchRank {
            userBatchRankLabel.text = "#" + "\(rank)"
        }
        
        if let name = studentProfile?.firstName {
            userNameLabel.text = name
        }
        childSkills = (skills.first?.skills)!
        
        
        
        // Do any additional setup after loading the view.
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return skills.count
    }

    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "superSkillCell", for: indexPath) as! SuperSkillCell
            
        cell.superSkillName.text = skills[indexPath.row].name
        //loading image async
        loadImageAsync(url: (skills[indexPath.row].imageURL)!, imgView: cell.superSkillImage)

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        return CGSize(width: skillCollections.frame.height * 0.9, height: skillCollections.frame.height) //use height whatever you wants.
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        print((skills[indexPath.row].name)!)
        
        for skill in skills{
            if skill.name == (skills[indexPath.row].name)! {
                childSkills = skill.skills!
            }
        }
        
        self.subSkillTableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let openViewHeight: Int = 70
        
        if (indexPath.row == selectedRowIndex.row && isExpanded == false){
            isExpanded = true
            return CGFloat(openViewHeight + 38 * (childSkills[indexPath.row].skills?.count)!)
            
        } else if (indexPath.row == selectedRowIndex.row && isExpanded == true){
            isExpanded = false
            return CGFloat(openViewHeight)
        } else {
            isExpanded = false
            return CGFloat(openViewHeight)
        }
        
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return childSkills.count
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(childSkills[indexPath.row].name)
        selectedRowIndex = indexPath
        tableView.beginUpdates()
        
        
        //let cell = tableView.dequeueReusableCell(withIdentifier: "SubSkillTableCell", for: indexPath) as! SubSkillTableCell
        let cell = tableView.cellForRow(at: indexPath) as! SubSkillTableCell
        
        for subview in cell.grandSkillStack.subviews {
            subview.removeFromSuperview()
        }
        
        var grandSkillView: GrandChildSkillItem
        grandChildSkills = (childSkills[indexPath.row].skills)!
        for grandchildskill in grandChildSkills {
            grandSkillView = GrandChildSkillItem(frame: CGRect(x: 0, y: 0, width: 300, height: 30))
            grandSkillView.grandChildSkillNameLabel.text = grandchildskill.name
            grandSkillView.grandChildSkillProgress.progress = Float(grandchildskill.percentage!)
            
            cell.grandSkillStack.addArrangedSubview(grandSkillView)
        }
        
        tableView.endUpdates()
        
    }
    

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SubSkillTableCell", for: indexPath) as! SubSkillTableCell
        cell.subSkillName.text = childSkills[indexPath.row].name
        cell.subSkillProgress.progress = Float(childSkills[indexPath.row].percentage!)
        
        if let uPoints = childSkills[indexPath.row].userPoints  {
            if let tPoints = childSkills[indexPath.row].totalPoints {
                if let count = childSkills[indexPath.row].skills?.count {
                    cell.subSkillDetail.text = "\(uPoints)" + "/" + "\(tPoints)" + "XP \u{2022} " + "\(count)" + " subskills"
                }
                
            }
        }
        
        return cell
    }

}
