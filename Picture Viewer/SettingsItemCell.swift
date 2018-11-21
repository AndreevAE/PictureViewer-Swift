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
        let defaults = UserDefaults.standard
        
        if (defaults.object(forKey: "autoSlideShow") != nil) {
            switcher.isOn = defaults.bool(forKey: "autoSlideShow")
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }

    @IBAction func saveSwitchState(_ sender: AnyObject) {
        let defaults = UserDefaults.standard
        // сохранение значения
        if switcher.isOn {
            defaults.set(true, forKey: "autoSlideShow")
        } else {
            defaults.set(false, forKey: "autoSlideShow")
        }
    }
}
