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
        let defaults = UserDefaults.standard
        
        if (defaults.object(forKey: "showFavourites") != nil) {
            switcher.isOn = defaults.bool(forKey: "showFavourites")
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func switchShowFavourites(sender: AnyObject) {
        let defaults = UserDefaults.standard
        
        // сохранение значения переключателя в пользовательских настройках
        if switcher.isOn {
            defaults.set(true, forKey: "showFavourites")
        } else {
            defaults.set(false, forKey: "showFavourites")
        }
    }

}
