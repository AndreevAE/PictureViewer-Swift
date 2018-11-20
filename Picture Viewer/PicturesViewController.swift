//
//  PicturesViewController.swift
//  Picture Viewer
//
//  Created by Admin on 22.02.16.
//  Copyright © 2016 AndreevAE. All rights reserved.
//

import UIKit
import Foundation

class PicturesViewController: UIViewController {
    
    @IBOutlet weak var labelComment: UILabel!
    @IBOutlet weak var favouriteButton: UIBarButtonItem!
    @IBOutlet weak var imageView: UIImageView!
    // index for images
    var indexOfImage: Int = 0
    // таймер для автоматической смены изображения
    var timer = NSTimer()
    // массив икдексов избранных изображений
    var favouriteIndex: [Int] = []
    // словарь комментариев к избранным изображениям
    var favouriteComments: [Int: String] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // загружаем список изображений из Pictures.plist
        // по ключу guid строка с именем файла
        let path = NSBundle.mainBundle().pathForResource("Pictures", ofType: "plist")
        let array = NSArray(contentsOfFile: path!)
        
        var imagesListArray: [UIImage] = []
        for item in array! {
            if let imageName = item.objectForKey("guid") {
                if let image = UIImage(named: imageName as! String) {
                    imagesListArray.append(image)
                }
            }
        }
        
        imageView.animationImages = imagesListArray
        
        imageView.image = imageView.animationImages![indexOfImage]
        favouriteLabelShowComment()
        
        // инициализация распознавания свайп-жестов
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipes:"))
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipes:"))
        
        leftSwipe.direction = .Left
        rightSwipe.direction = .Right
        
        view.addGestureRecognizer(leftSwipe)
        view.addGestureRecognizer(rightSwipe)
    }
    
    override func viewDidAppear(animated: Bool) {
        // представление появилось на экране
        // проверяем настройки и при необходимости запускаем авто слайд-шоу
        // let numberOfImages: Double = Double(imageView.animationImages!.count)
        let defaults = NSUserDefaults.standardUserDefaults()
        var timeToSlide: Double = 1 // по умолчанию
        if (defaults.objectForKey("timeToSlide") != nil) {
            timeToSlide = defaults.doubleForKey("timeToSlide")
        }
        
        // создадим автоматическое слайд-шоу вручную, используя NSTimer
        // проверка переключателя авто вкл/выкл
        if (defaults.objectForKey("autoSlideShow") != nil) {
            if defaults.boolForKey("autoSlideShow") {
                // интервал в секундах
                timer = NSTimer(timeInterval: timeToSlide, target:  self, selector: "viewNextImage", userInfo: nil, repeats: true)
                
                // погрешность таймера
                // timer.tolerance = timeToSlide / 10
                
                // добавим в текущий событийный цикл
                NSRunLoop.mainRunLoop().addTimer(timer, forMode: NSDefaultRunLoopMode)
            }
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        // представление скрыто
        // отключение таймера
        // timer.invalidate()
    }
    
    override func viewWillDisappear(animated: Bool) {
        // представление будет скрыто
        timer.invalidate()
    }
    
    override func viewWillAppear(animated: Bool) {
        // представление будет открыто
    }
    
    // функция управления свайпами
    func handleSwipes(sender: UISwipeGestureRecognizer) {
        if (sender.direction == .Left) {
            // влево - следующее изображение
            viewNextImage()
        }
        
        if (sender.direction == .Right) {
            // вправо - предыдущее изображение
            viewPrevImage()
        }
    }
    
    // функция для выполнения таймером
    // выводим следующее изображение, увеличиваем счетчик
    func viewNextImage() {
        // проверка настройки "Random Order"
        let defaults = NSUserDefaults.standardUserDefaults()
        if (defaults.objectForKey("randomOrder") != nil) {
            if defaults.boolForKey("randomOrder") { // если случайны порядок
                indexOfImage = Int(arc4random_uniform(UInt32(imageView.animationImages!.count-1)))
            } else { // по порядку
                indexOfImage = (indexOfImage + 1) % (imageView.animationImages?.count)!
            }
        }
        
        // проверка настройки "Show Favourites"
        if (defaults.objectForKey("showFavourites") != nil) {
            if defaults.boolForKey("showFavourites") { // показывать только Favourites
                if favouriteIndex.isEmpty { // если Favourites изображения отсутствуют
                    // выведем предупреждение и остановим автопоказ
                    if #available(iOS 8.0, *) {
                        let alert = UIAlertController(title: "Sorry", message: "Missing list of Favourites", preferredStyle: .Alert)
                        let okAction = UIAlertAction(title: "OK", style: .Default) {
                            action in
                            defaults.setBool(false, forKey: "showFavourites")
                        }
                        alert.addAction(okAction)
                        self.presentViewController(alert, animated: true, completion: nil)
                    } else {
                        // Fallback on earlier versions
                        defaults.setBool(false, forKey: "showFavourites")
                    }
                } else { // если массив индексов Favourites все же не пуст
                    if favouriteIndex.contains(indexOfImage) { // изображение в Favourites
                        // анимация для ухода с экрана текущего изображения
                        // работает не так, как предполагается, анимация запускается после смены изображения
                        // в итоге новое изображение после появления тут же пропадает
//                        animationSwipeRightTo()
//                        animationFadeOut()
                        imageView.image = imageView.animationImages![indexOfImage]
                        if (defaults.objectForKey("animation") != nil) {
                            switch defaults.integerForKey("animation") {
                            case 0: break // Simple
                            case 1: animationSwipeToLeft() // Swipe
                            case 2: animationFadeIn() // Dissappearance
                            default: break // Simple
                            }
                        }
                        favouriteButtonStyle()
                        favouriteLabelShowComment()
                    } else { // изображение не в Favourites, идем к следующему
                        viewNextImage()
                    }
                }
            } else { // показывать все
//                animationSwipeRightTo()
//                animationFadeOut()
                imageView.image = imageView.animationImages![indexOfImage]
                if (defaults.objectForKey("animation") != nil) {
                    switch defaults.integerForKey("animation") {
                    case 0: break // Simple
                    case 1: animationSwipeToLeft() // Swipe
                    case 2: animationFadeIn() // Dissappearance
                    default: break // Simple
                    }
                }
                favouriteButtonStyle()
                favouriteLabelShowComment()
            }
        }
    }
    
    // выводим предыдущее изображение, счетчик уменьшаем
    func viewPrevImage() {
        let defaults = NSUserDefaults.standardUserDefaults()
        // проверка настройки "Random Order"
        if (defaults.objectForKey("randomOrder") != nil) {
            if defaults.boolForKey("randomOrder") { // если случайны порядок
                indexOfImage = Int(arc4random_uniform(UInt32(imageView.animationImages!.count-1)))
            } else { // по порядку
                indexOfImage--
                if indexOfImage == -1 {
                    indexOfImage = imageView.animationImages!.count - 1
                }
            }
        }
        
        // проверка настройки "Show Favourites"
        if (defaults.objectForKey("showFavourites") != nil) {
            if defaults.boolForKey("showFavourites") { // показывать только Favourites
                if favouriteIndex.isEmpty { // если Favourites изображения отсутствуют
                    // выведем предупреждение и остановим автопоказ
                    if #available(iOS 8.0, *) {
                        let alert = UIAlertController(title: "Sorry", message: "Missing list of Favourites", preferredStyle: .Alert)
                        let okAction = UIAlertAction(title: "OK", style: .Default) {
                            action in
                            defaults.setBool(false, forKey: "showFavourites")
                        }
                        alert.addAction(okAction)
                        self.presentViewController(alert, animated: true, completion: nil)
                    } else {
                        // Fallback on earlier versions
                        defaults.setBool(false, forKey: "showFavourites")
                    }
                } else { // если массив индексов Favourites все же не пуст
                    if favouriteIndex.contains(indexOfImage) { // изображение в Favourites
//                        animationSwipeLeftTo()
//                        animationFadeOut()
                        imageView.image = imageView.animationImages![indexOfImage]
                        if (defaults.objectForKey("animation") != nil) {
                            switch defaults.integerForKey("animation") {
                            case 0: break // Simple
                            case 1: animationSwipeToRight() // Swipe
                            case 2: animationFadeIn() // Dissappearance
                            default: break // Simple
                            }
                        }
                        favouriteButtonStyle()
                        favouriteLabelShowComment()
                    } else { // изображение не в Favourites, идем к следующему
                        viewNextImage()
                    }
                }
            } else { // показывать все
//                animationSwipeLeftTo()
//                animationFadeOut()
                imageView.image = imageView.animationImages![indexOfImage]
                if (defaults.objectForKey("animation") != nil) {
                    switch defaults.integerForKey("animation") {
                    case 0: break // Simple
                    case 1: animationSwipeToRight() // Swipe
                    case 2: animationFadeIn() // Dissappearance
                    default: break // Simple
                    }
                }
                favouriteButtonStyle()
                favouriteLabelShowComment()
            }
        }
    }
    
    // функция, меняющая шрифт кнопки "Favourite"
    func favouriteButtonStyle() {
        if favouriteIndex.contains(indexOfImage) {
            favouriteButton.style = .Done
        } else {
            favouriteButton.style = .Bordered
        }
    }
    
    // функция, выводящая коммент к изображению, при его наличии
    func favouriteLabelShowComment() {
        if favouriteIndex.contains(indexOfImage) {
            labelComment.text = favouriteComments[indexOfImage]
        } else { // иначе выведем пустую строку
            labelComment.text = ""
        }
    }
    
    // анимация свайпа
    // слева направо: для старого изображения
    func animationSwipeLeftTo() {
        imageView.center.x = view.center.x
        labelComment.center.x = view.center.x
        UIView.animateWithDuration(0.5) {
            self.imageView.center.x += self.view.bounds.width
            self.labelComment.center.x += self.view.bounds.width
        }
    }
    // слева направо: для нового изображения
    func animationSwipeToRight() {
        imageView.center.x -= view.bounds.width
        labelComment.center.x -= view.bounds.width
        UIView.animateWithDuration(0.5) {
            self.imageView.center.x += self.view.bounds.width
            self.labelComment.center.x += self.view.bounds.width
        }
    }
    // справа налево: для старого изображения
    func animationSwipeRightTo() {
        imageView.center.x = view.center.x
        labelComment.center.x = view.center.x
        UIView.animateWithDuration(0.5) {
            self.imageView.center.x -= self.view.bounds.width
            self.labelComment.center.x -= self.view.bounds.width
        }
    }
    //справа налево: для нового изображения
    func animationSwipeToLeft() {
        imageView.center.x += view.bounds.width
        labelComment.center.x += view.bounds.width
        UIView.animateWithDuration(0.5) {
            self.imageView.center.x -= self.view.bounds.width
            self.labelComment.center.x -= self.view.bounds.width
        }
    }
    
    // анимация исчезновения Dissapearance
    func animationFadeOut() {
        imageView.alpha = 1.0
        labelComment.alpha = 1.0
        UIView.animateWithDuration(1.0) {
            self.imageView.alpha = 0.0
            self.imageView.alpha = 0.0
        }
    }
    
    // анимация появления Dissapearance
    func animationFadeIn() {
        imageView.alpha = 0.0
        labelComment.alpha = 0.0
        UIView.animateWithDuration(1.0) {
            self.imageView.alpha = 1.0
            self.imageView.alpha = 1.0
        }
    }
    
    @IBAction func addToFavourite(sender: AnyObject) {
        // добавление/удаление в списке избранных изображений
        // если изображение уже есть в избранных, то удалить
        if favouriteIndex.contains(indexOfImage) {
            favouriteIndex.removeAtIndex(favouriteIndex.indexOf(indexOfImage)!)
            favouriteButton.style = .Bordered
            favouriteComments[indexOfImage] = nil
            favouriteLabelShowComment()
        } else {
            // иначе, добавить в массив избранных
            favouriteIndex.append(indexOfImage)
            favouriteButton.style = .Done
            // выведем окно с вводом комментария
            if #available(iOS 8.0, *) {
                var commentTextField: UITextField?
                let alertController = UIAlertController(
                    title: "Favourite",
                    message: "Please enter your comment",
                    preferredStyle: UIAlertControllerStyle.Alert)
                let commentAction = UIAlertAction(title: "Save comment", style: UIAlertActionStyle.Default) {
                    (action) -> Void in
                    if let comment = commentTextField?.text {
                        self.favouriteComments[self.indexOfImage] = comment
                        self.favouriteLabelShowComment()
                    } else {
                        print("No comment entered")
                    }
                }
                alertController.addTextFieldWithConfigurationHandler {
                        (txtComment) -> Void in
                        commentTextField = txtComment
                        commentTextField!.placeholder = "<Your comment here>"
                    }
                alertController.addAction(commentAction)
                self.presentViewController(alertController, animated: true, completion: nil)
            } else {
                // Fallback on earlier versions
                // комментирование доступно только для устройств с iOS 8.0 и выше
                print("Please, update your device to new version of iOS")
            }
        }
        
    }
}
