//
//  SettingsItemCell.swift
//  Picture Viewer
//
//  Created by Admin on 22.02.16.
//  Copyright © 2016 AndreevAE. All rights reserved.
//

import UIKit

class SettingsItemCell: UITableViewCell {
    
    @IBOutlet weak var labelName: UILabel!
    // переключатель автоматического слайд-шоу
    @IBOutlet weak var switcher: UISwitch!
    
    //создан из сториборда (xib-файла)
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let defaults = NSUserDefaults.standardUserDefaults()
        
        if (defaults.objectForKey("autoSlideShow") != nil) {
            switcher.on = defaults.boolForKey("autoSlideShow")
        }
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }

    @IBAction func saveSwitchState(sender: AnyObject) {
        let defaults = NSUserDefaults.standardUserDefaults()
        // сохранение значения
        if switcher.on {
            defaults.setBool(true, forKey: "autoSlideShow")
        } else {
            defaults.setBool(false, forKey: "autoSlideShow")
        }
    }
}
