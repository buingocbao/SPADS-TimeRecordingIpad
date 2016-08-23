//
//  ManagerViewController.swift
//  SPADS-TimeRecordingIpad
//
//  Created by BBaoBao on 7/16/15.
//  Copyright (c) 2015 buingocbao. All rights reserved.
//

import UIKit

class ManagerViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var employeeTableView: UITableView!
    
    var employeeArray:NSArray = NSArray()
    var groupUser:String = String()
    var backButton:MKButton = MKButton()
    var settingButton:ActionButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Table View Data Source and Delegate
        employeeTableView.dataSource = self
        employeeTableView.delegate = self
        
        // Query Parse
        queryParseMethod("Day")
        
        // Check Group User
        let user = PFUser.currentUser()
        
        // Add Left Button on Navigation Bar
        self.addLeftNavItemOnView()
        
        // Add Setting Button on Navigation Bar
        self.addRightNavItemOnView()
    }
    
    func addLeftNavItemOnView (){
        // hide default navigation bar button item
        self.navigationItem.backBarButtonItem = nil;
        self.navigationItem.leftBarButtonItem = nil;
        self.navigationItem.hidesBackButton = true;
        
        backButton.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        backButton.backgroundColor = UIColor.MKColor.Red
        backButton.cornerRadius = 20
        backButton.backgroundLayerCornerRadius = 20
        backButton.maskEnabled = false
        backButton.ripplePercent = 1.75
        backButton.rippleLocation = .Center
        
        backButton.layer.shadowOpacity = 0.75
        backButton.layer.shadowRadius = 3.5
        backButton.layer.shadowColor = UIColor.blackColor().CGColor
        backButton.layer.shadowOffset = CGSize(width: 1.0, height: 5.5)
        //backButton.setImage(UIImage(named: "Back"), forState: UIControlState.Normal)
        backButton.setTitle("<", forState: UIControlState.Normal)
        backButton.titleLabel?.font = UIFont(name: "Helvetica Neue", size: 20)
        backButton.addTarget(self, action: "backButtonClick:", forControlEvents: UIControlEvents.TouchUpInside)
        
        let leftBarButtonItem: UIBarButtonItem = UIBarButtonItem(customView: backButton)
        self.navigationItem.setLeftBarButtonItem(leftBarButtonItem, animated: false)
        
        self.navigationItem.title = ""
    }
    
    // Back function
    func backButtonClick(sender:UIButton!){
        PFUser.logOut()
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    // Add Right Button on Nav
    func addRightNavItemOnView(){
        let setting1 = ActionButtonItem(title: "Day", image: nil)
        setting1.action = { item in
            // Find Employee in Day
            self.queryParseMethod("Day")
        }
        
        let setting2 = ActionButtonItem(title: "Month", image: nil)
        setting2.action = { item in
            // Find Employee in Month
            self.queryParseMethod("Month")
        }
        
        let setting3 = ActionButtonItem(title: "Year", image: nil)
        setting3.action = { item in
            // Find Employee in Month
            self.queryParseMethod("Year")
        }
        
        settingButton = ActionButton(attachedToView: self.view, items: [setting1,setting2,setting3])
        settingButton.action = { button in button.toggleMenu()}
    }
    
    func queryParseMethod(filter: String) {
        // Check day
        let date = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Hour, .Minute, .Day, .Month, .Year], fromDate: date)
        let day = String(components.day)
        let month = String(components.month)
        let year = String(components.year)
        
        let daymonthyear = "\(day)-\(month)-\(year)"
        
        switch filter {
        case "Day":
            print("Start query day")
            let query = PFQuery(className: "TimeRecording").orderByDescending("Date").whereKey("Date", equalTo: daymonthyear)
            query.findObjectsInBackgroundWithBlock {
                (objects, error) -> Void in
                if error == nil {
                    // The find succeeded.
                    print("Successfully retrieved \(objects!.count) employees.")
                    self.employeeArray = objects!
                    //println(self.promotionsFileArray)
                }
                self.employeeTableView.reloadData()
            }
        case "Month":
            print("Start query month")
            let query = PFQuery(className: "TimeRecording").orderByDescending("Date").whereKey("Date", containsString: "-\(month)-\(year)")
            query.findObjectsInBackgroundWithBlock {
                (objects, error) -> Void in
                if error == nil {
                    // The find succeeded.
                    print("Successfully retrieved \(objects!.count) employees.")
                    self.employeeArray = objects!
                    //println(self.promotionsFileArray)
                }
                self.employeeTableView.reloadData()
            }
        case "Year":
            print("Start query year")
            let query = PFQuery(className: "TimeRecording").orderByDescending("Date").whereKey("Date", containsString: "-\(year)")
            query.findObjectsInBackgroundWithBlock {
                (objects, error) -> Void in
                if error == nil {
                    // The find succeeded.
                    print("Successfully retrieved \(objects!.count) employees.")
                    self.employeeArray = objects!
                    //println(self.promotionsFileArray)
                }
                self.employeeTableView.reloadData()
            }
        default:
            break
        }
    }
    
    // MARK: - Table view data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return employeeArray.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("EmployeeCell", forIndexPath: indexPath) as! EmployeeTableViewCell
    
        // Configure the cell...
        cell.backgroundColor = UIColor.MKColor.Green
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            cell.displayData(self.employeeArray, indexPath: indexPath)
        })
        
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        employeeTableView.deselectRowAtIndexPath(indexPath, animated: false)
        
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.separatorInset = UIEdgeInsetsZero
        cell.preservesSuperviewLayoutMargins = false
        cell.layoutMargins = UIEdgeInsetsZero
    }
    
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    // Return NO if you do not want the specified item to be editable.
    return true
    }
    */
    
    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    if editingStyle == .Delete {
    // Delete the row from the data source
    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
    } else if editingStyle == .Insert {
    // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
    }
    */
    
    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
    
    }
    */
    
    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    // Return NO if you do not want the item to be re-orderable.
    return true
    }
    */
}
