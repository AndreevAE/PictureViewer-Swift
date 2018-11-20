//
//  SettingsAnimationCell.swift
//  Picture Viewer
//
//  Created by Admin on 22.02.16.
//  Copyright © 2016 AndreevAE. All rights reserved.
//

import UIKit

class SettingsAnimationCell: UITableViewCell {

    @IBOutlet weak var picker: UIPickerView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        // восстановим значение пикера из пользовательских настроек
        // всегда выбирает 1ую анимацию
//        let defaults = NSUserDefaults.standardUserDefaults()
//        if (defaults.objectForKey("animation") != nil) {
//            let selectedAnimation = defaults.integerForKey("animation")
//            picker.selectRow(selectedAnimation, inComponent: 0, animated: true)
//        }
    }
    
}
