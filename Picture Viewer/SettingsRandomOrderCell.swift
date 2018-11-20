//
//  SettingsRandomOrderCell.swift
//  Picture Viewer
//
//  Created by Admin on 22.02.16.
//  Copyright © 2016 AndreevAE. All rights reserved.
//

import UIKit

class SettingsRandomOrderCell: UITableViewCell {

    @IBOutlet weak var labelName: UILabel!
    // переключатель случайного порядка показа изображений
    @IBOutlet weak var switcher: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let defaults = UserDefaults.standard
        
        if (defaults.object(forKey: "randomOrder") != nil) {
            switcher.isOn = defaults.bool(forKey: "randomOrder")
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func switchRandomOrder(sender: AnyObject) {
        let defaults = UserDefaults.standard
        
        // сохранение значения переключателя в пользовательских настройках
        if switcher.isOn {
            defaults.set(true, forKey: "randomOrder")
        } else {
            defaults.set(false, forKey: "randomOrder")
        }
    }

}
