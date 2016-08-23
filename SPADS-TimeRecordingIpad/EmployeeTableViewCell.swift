//
//  EmployeeTableViewCell.swift
//  SPADS-TimeRecordingIpad
//
//  Created by BBaoBao on 7/16/15.
//  Copyright (c) 2015 buingocbao. All rights reserved.
//

import UIKit

class EmployeeTableViewCell: UITableViewCell {

    @IBOutlet weak var lbEmployee: UILabel!
    @IBOutlet weak var lbStartTime: UILabel!
    @IBOutlet weak var lbEndTime: UILabel!
    @IBOutlet weak var lbGroup: UILabel!
    @IBOutlet weak var lbDay: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        lbEmployee.textColor = UIColor.whiteColor()
        lbStartTime.textColor = UIColor.whiteColor()
        lbEndTime.textColor = UIColor.whiteColor()
        lbGroup.textColor = UIColor.whiteColor()
        lbDay.textColor = UIColor.whiteColor()
        
        lbEmployee.text = "Employee"
        lbStartTime.text = "--:--"
        lbEndTime.text = "--:--"
        lbGroup.text = "Unknown"
        lbDay.text = "01/01/1993"
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func displayData(employeeArray: NSArray, indexPath: NSIndexPath) {
        let employeeObject:PFObject = employeeArray.objectAtIndex(indexPath.row) as! PFObject
        
        if let employeeName = employeeObject["Employee"] as? String {
            lbEmployee.text = employeeName
        }
        
        if let startTime = employeeObject["StartTimeRecord"] as? String {
            lbStartTime.text = startTime
        }
        
        if let endTime = employeeObject["EndTimeRecord"] as? String {
            lbEndTime.text = endTime
        }
        
        if let group = employeeObject["Group"] as? String {
            lbGroup.text = group
        }
        
        if let day = employeeObject["Date"] as? String {
            lbDay.text = day
        }
    }

}
