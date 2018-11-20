//
//  SettingsShowFavouritesCell.swift
//  Picture Viewer
//
//  Created by Admin on 22.02.16.
//  Copyright © 2016 AndreevAE. All rights reserved.
//

import UIKit

class SettingsShowFavouritesCell: UITableViewCell {

    @IBOutlet weak var labelName: UILabel!
    // переключатель для показа исключительно избранных изображениий
    @IBOutlet weak var switcher: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let defaults = NSUserDefaults.standardUserDefaults()
        
        if (defaults.objectForKey("showFavourites") != nil) {
            switcher.on = defaults.boolForKey("showFavourites")
        }
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func switchShowFavourites(sender: AnyObject) {
        let defaults = NSUserDefaults.standardUserDefaults()
        
        // сохранение значения переключателя в пользовательских настройках
        if switcher.on {
            defaults.setBool(true, forKey: "showFavourites")
        } else {
            defaults.setBool(false, forKey: "showFavourites")
        }
    }

}
