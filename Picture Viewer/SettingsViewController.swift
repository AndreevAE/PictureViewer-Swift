//
//  SettingsViewController.swift
//  Picture Viewer
//
//  Created by Admin on 22.02.16.
//  Copyright © 2016 AndreevAE. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableItems: UITableView!
    
    // список настроек
    let arrayOfCells: [String] = ["SettingsItemCell", "SettingsTimeCell", "SettingsShowFavouritesCell", "SettingsRandomOrderCell", "SettingsAnimationCell"]
    // список анимаций
    var animations: [String] = ["Simple", "Swipe", "Dissappearance"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        tableItems.delegate = self
        tableItems.dataSource = self
        
        //tableItems.separatorStyle = UITableViewCellSeparatorStyle.None
        //tableItems.separatorStyle = .None
        tableItems.tableFooterView = UIView()
    }
    
    //MARK: - UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayOfCells.count   //array.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //let cell = tableItems.dequeueReusableCellWithIdentifier("SettingsItemCell") as! SettingsItemCell
        //var item = array[indexParh.row]
        //cell.switcher.enabled = true
        let cell = tableItems.dequeueReusableCellWithIdentifier(arrayOfCells[indexPath.row])! as UITableViewCell
        return cell
    }

    //MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //только что выделили ячейку == нажали на "кнопку"
        //здесь обычно некий переход на другой экран
    }
    
    //MARK: - Picker View
    
    // количество компонент в PickerView
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // количество анимаций
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return animations.count
    }
    
    // выбор анимации, сохранение номера анимации в пользовательских настройках
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setInteger(row, forKey: "animation")
        return animations[row]
    }
}
