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
    var timer = Timer()
    // массив икдексов избранных изображений
    var favouriteIndex: [Int] = []
    // словарь комментариев к избранным изображениям
    var favouriteComments: [Int: String] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // загружаем список изображений из Pictures.plist
        // по ключу guid строка с именем файла
        let path = Bundle.main.path(forResource: "Pictures", ofType: "plist")
        let array = NSArray(contentsOfFile: path!)
        
        var imagesListArray: [UIImage] = []
        for item in array! {
            // TODO: CHECK THIS LINE
            if let imageName = (item as AnyObject).value(forKey: "guid") {
                if let image = UIImage(named: imageName as! String) {
                    imagesListArray.append(image)
                }
            }
        }
        
        imageView.animationImages = imagesListArray
        
        imageView.image = imageView.animationImages![indexOfImage]
        favouriteLabelShowComment()
        
        // инициализация распознавания свайп-жестов
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: Selector(("handleSwipes:")))
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: Selector(("handleSwipes:")))
        
        leftSwipe.direction = .left
        rightSwipe.direction = .right
        
        view.addGestureRecognizer(leftSwipe)
        view.addGestureRecognizer(rightSwipe)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // представление появилось на экране
        // проверяем настройки и при необходимости запускаем авто слайд-шоу
        // let numberOfImages: Double = Double(imageView.animationImages!.count)
        let defaults = UserDefaults.standard
        var timeToSlide: Double = 1 // по умолчанию
        if (defaults.object(forKey: "timeToSlide") != nil) {
            timeToSlide = defaults.double(forKey: "timeToSlide")
        }
        
        // создадим автоматическое слайд-шоу вручную, используя NSTimer
        // проверка переключателя авто вкл/выкл
        if (defaults.object(forKey: "autoSlideShow") != nil) {
            if defaults.bool(forKey: "autoSlideShow") {
                // интервал в секундах
                timer = Timer(timeInterval: timeToSlide, target:  self, selector: #selector(PicturesViewController.viewNextImage), userInfo: nil, repeats: true)
                
                // погрешность таймера
                // timer.tolerance = timeToSlide / 10
                
                // добавим в текущий событийный цикл
                RunLoop.main.add(timer, forMode: RunLoop.Mode.default)
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        // представление скрыто
        // отключение таймера
        // timer.invalidate()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // представление будет скрыто
        timer.invalidate()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // представление будет открыто
    }
    
    // функция управления свайпами
    func handleSwipes(sender: UISwipeGestureRecognizer) {
        if (sender.direction == .left) {
            // влево - следующее изображение
            viewNextImage()
        }
        
        if (sender.direction == .right) {
            // вправо - предыдущее изображение
            viewPrevImage()
        }
    }
    
    // функция для выполнения таймером
    // выводим следующее изображение, увеличиваем счетчик
    @objc func viewNextImage() {
        // проверка настройки "Random Order"
        let defaults = UserDefaults.standard
        if (defaults.object(forKey: "randomOrder") != nil) {
            if defaults.bool(forKey: "randomOrder") { // если случайны порядок
                indexOfImage = Int(arc4random_uniform(UInt32(imageView.animationImages!.count-1)))
            } else { // по порядку
                indexOfImage = (indexOfImage + 1) % (imageView.animationImages?.count)!
            }
        }
        
        // проверка настройки "Show Favourites"
        if (defaults.object(forKey: "showFavourites") != nil) {
            if defaults.bool(forKey: "showFavourites") { // показывать только Favourites
                if favouriteIndex.isEmpty { // если Favourites изображения отсутствуют
                    // выведем предупреждение и остановим автопоказ
                    if #available(iOS 8.0, *) {
                        let alert = UIAlertController(title: "Sorry", message: "Missing list of Favourites", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "OK", style: .default) {
                            action in
                            defaults.set(false, forKey: "showFavourites")
                        }
                        alert.addAction(okAction)
                        self.present(alert, animated: true, completion: nil)
                    } else {
                        // Fallback on earlier versions
                        defaults.set(false, forKey: "showFavourites")
                    }
                } else { // если массив индексов Favourites все же не пуст
                    if favouriteIndex.contains(indexOfImage) { // изображение в Favourites
                        // анимация для ухода с экрана текущего изображения
                        // работает не так, как предполагается, анимация запускается после смены изображения
                        // в итоге новое изображение после появления тут же пропадает
//                        animationSwipeRightTo()
//                        animationFadeOut()
                        imageView.image = imageView.animationImages![indexOfImage]
                        if (defaults.object(forKey: "animation") != nil) {
                            switch defaults.integer(forKey: "animation") {
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
                if (defaults.object(forKey: "animation") != nil) {
                    switch defaults.integer(forKey: "animation") {
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
        let defaults = UserDefaults.standard
        // проверка настройки "Random Order"
        if (defaults.object(forKey: "randomOrder") != nil) {
            if defaults.bool(forKey: "randomOrder") { // если случайны порядок
                indexOfImage = Int(arc4random_uniform(UInt32(imageView.animationImages!.count-1)))
            } else { // по порядку
                indexOfImage = indexOfImage - 1
                if indexOfImage == -1 {
                    indexOfImage = imageView.animationImages!.count - 1
                }
            }
        }
        
        // проверка настройки "Show Favourites"
        if (defaults.object(forKey: "showFavourites") != nil) {
            if defaults.bool(forKey: "showFavourites") { // показывать только Favourites
                if favouriteIndex.isEmpty { // если Favourites изображения отсутствуют
                    // выведем предупреждение и остановим автопоказ
                    if #available(iOS 8.0, *) {
                        let alert = UIAlertController(title: "Sorry", message: "Missing list of Favourites", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "OK", style: .default) {
                            action in
                            defaults.set(false, forKey: "showFavourites")
                        }
                        alert.addAction(okAction)
                        self.present(alert, animated: true, completion: nil)
                    } else {
                        // Fallback on earlier versions
                        defaults.set(false, forKey: "showFavourites")
                    }
                } else { // если массив индексов Favourites все же не пуст
                    if favouriteIndex.contains(indexOfImage) { // изображение в Favourites
//                        animationSwipeLeftTo()
//                        animationFadeOut()
                        imageView.image = imageView.animationImages![indexOfImage]
                        if (defaults.object(forKey: "animation") != nil) {
                            switch defaults.integer(forKey: "animation") {
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
                if (defaults.object(forKey: "animation") != nil) {
                    switch defaults.integer(forKey: "animation") {
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
            favouriteButton.style = .done
        } else {
            favouriteButton.style = .plain
//            favouriteButton.style = .bordered
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
        UIView.animate(withDuration: 0.5) {
            self.imageView.center.x += self.view.bounds.width
            self.labelComment.center.x += self.view.bounds.width
        }
    }
    // слева направо: для нового изображения
    func animationSwipeToRight() {
        imageView.center.x -= view.bounds.width
        labelComment.center.x -= view.bounds.width
        UIView.animate(withDuration: 0.5) {
            self.imageView.center.x += self.view.bounds.width
            self.labelComment.center.x += self.view.bounds.width
        }
    }
    // справа налево: для старого изображения
    func animationSwipeRightTo() {
        imageView.center.x = view.center.x
        labelComment.center.x = view.center.x
        UIView.animate(withDuration: 0.5) {
            self.imageView.center.x -= self.view.bounds.width
            self.labelComment.center.x -= self.view.bounds.width
        }
    }
    //справа налево: для нового изображения
    func animationSwipeToLeft() {
        imageView.center.x += view.bounds.width
        labelComment.center.x += view.bounds.width
        UIView.animate(withDuration: 0.5) {
            self.imageView.center.x -= self.view.bounds.width
            self.labelComment.center.x -= self.view.bounds.width
        }
    }
    
    // анимация исчезновения Dissapearance
    func animationFadeOut() {
        imageView.alpha = 1.0
        labelComment.alpha = 1.0
        UIView.animate(withDuration: 1.0) {
            self.imageView.alpha = 0.0
            self.imageView.alpha = 0.0
        }
    }
    
    // анимация появления Dissapearance
    func animationFadeIn() {
        imageView.alpha = 0.0
        labelComment.alpha = 0.0
        UIView.animate(withDuration: 1.0) {
            self.imageView.alpha = 1.0
            self.imageView.alpha = 1.0
        }
    }
    
    @IBAction func addToFavourite(sender: AnyObject) {
        // добавление/удаление в списке избранных изображений
        // если изображение уже есть в избранных, то удалить
        if favouriteIndex.contains(indexOfImage) {
            favouriteIndex.remove(at: indexOfImage)
//            favouriteIndex.removeAtIndex(favouriteIndex.indexOf(indexOfImage)!)
            favouriteButton.style = .plain
//            favouriteButton.style = .bordered
            favouriteComments[indexOfImage] = nil
            favouriteLabelShowComment()
        } else {
            // иначе, добавить в массив избранных
            favouriteIndex.append(indexOfImage)
            favouriteButton.style = .done
            // выведем окно с вводом комментария
            if #available(iOS 8.0, *) {
                var commentTextField: UITextField?
                let alertController = UIAlertController(
                    title: "Favourite",
                    message: "Please enter your comment",
                    preferredStyle: UIAlertController.Style.alert)
                let commentAction = UIAlertAction(title: "Save comment", style: UIAlertAction.Style.default) {
                    (action) -> Void in
                    if let comment = commentTextField?.text {
                        self.favouriteComments[self.indexOfImage] = comment
                        self.favouriteLabelShowComment()
                    } else {
                        print("No comment entered")
                    }
                }
                alertController.addTextField {
                        (txtComment) -> Void in
                        commentTextField = txtComment
                        commentTextField!.placeholder = "<Your comment here>"
                    }
                alertController.addAction(commentAction)
                self.present(alertController, animated: true, completion: nil)
            } else {
                // Fallback on earlier versions
                // комментирование доступно только для устройств с iOS 8.0 и выше
                print("Please, update your device to new version of iOS")
            }
        }
        
    }
}
