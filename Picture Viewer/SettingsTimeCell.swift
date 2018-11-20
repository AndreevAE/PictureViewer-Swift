//
//  SettingsTimeCell.swift
//  Picture Viewer
//
//  Created by Admin on 22.02.16.
//  Copyright © 2016 AndreevAE. All rights reserved.
//

import UIKit

class SettingsTimeCell: UITableViewCell {

    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelTime: UILabel!
    // выбор времени смены изображения в автоматическом режиме
    @IBOutlet weak var timeStepper: UIStepper!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let defaults = NSUserDefaults.standardUserDefaults()
        
        if (defaults.objectForKey("timeToSlide") != nil) {
            timeStepper.value = defaults.doubleForKey("timeToSlide")
        }
        
        var string = Int(timeStepper.value).description
        string += " sec"
        labelTime.text = string
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func timeStepperValueChanged(sender: UIStepper) {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setDouble(timeStepper.value, forKey: "timeToSlide")
        
        var string = Int(sender.value).description
        string += " sec"
        labelTime.text = string
    }

}
