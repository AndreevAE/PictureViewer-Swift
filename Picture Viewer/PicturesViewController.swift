//
//  PicturesViewController.swift
//  Picture Viewer
//
//  Created by Admin on 22.02.16.
//  Copyright © 2016 AndreevAE. All rights reserved.
//

import UIKit
import Foundation

final class PicturesViewController: UIViewController {

    private enum Constants {
        static let animationDuration = 0.5
        static let otherAnimationDuration = 1.0
    }

    @IBOutlet weak var labelComment: UILabel!
    @IBOutlet weak var favouriteButton: UIBarButtonItem!
    @IBOutlet weak var imageView: UIImageView!

    private var timer = Timer()
    private var favouriteIndex = [Int]()
    private var favouriteComments = [Int: String]()
    private var images = [UIImage]()
    private var selectedImageIndex = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        let path = Bundle.main.path(forResource: "Pictures", ofType: "plist")!
        let array = NSArray(contentsOfFile: path)!

        for item in array {
            if let imageName = (item as AnyObject).value(forKey: "guid") as? String,
               let image = UIImage(named: imageName) {
                images.append(image)
            }
        }

        imageView.image = images[selectedImageIndex]
        favouriteLabelShowComment()

        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes))
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes))

        leftSwipe.direction = .left
        rightSwipe.direction = .right

        view.addGestureRecognizer(leftSwipe)
        view.addGestureRecognizer(rightSwipe)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        var timeToSlide: Double = 1
        if let _ = UserDefaults.standard.object(forKey: .UserDefaultsKey.timeToSlide) {
            timeToSlide = UserDefaults.standard.double(forKey: .UserDefaultsKey.timeToSlide)
        }

        if UserDefaults.standard.bool(forKey: .UserDefaultsKey.autoSlideShow) {
            // интервал в секундах
            timer = Timer(
                timeInterval: timeToSlide,
                target:  self,
                selector: #selector(PicturesViewController.viewNextImage),
                userInfo: nil,
                repeats: true
            )

            // погрешность таймера
            // timer.tolerance = timeToSlide / 10

            // добавим в текущий событийный цикл
            RunLoop.main.add(timer, forMode: .default)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer.invalidate()
    }

    @objc func handleSwipes(sender: UISwipeGestureRecognizer) {
        switch sender.direction {
        case .left: viewNextImage()
        case .right: viewPrevImage()
        default: break
        }
    }

    @objc func viewNextImage() {
        print(#function, selectedImageIndex)
        if UserDefaults.standard.bool(forKey: .UserDefaultsKey.randomOrder) {
            let newIndex = Set(0 ..< images.count).subtracting([selectedImageIndex]).randomElement() ?? selectedImageIndex
            selectedImageIndex = newIndex
        } else {
            selectedImageIndex = (selectedImageIndex + 1) % images.count
        }

        if UserDefaults.standard.bool(forKey: .UserDefaultsKey.showFavourites) {
            if favouriteIndex.isEmpty {
                let alert = UIAlertController(title: "Sorry", message: "Missing list of Favourites", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default) { _ in
                    UserDefaults.standard.set(false, forKey: .UserDefaultsKey.showFavourites)
                }
                alert.addAction(okAction)
                self.present(alert, animated: true)
            } else {
                if favouriteIndex.contains(selectedImageIndex) {
                    // анимация для ухода с экрана текущего изображения
                    // работает не так, как предполагается, анимация запускается после смены изображения
                    // в итоге новое изображение после появления тут же пропадает
                    //                        animationSwipeRightTo()
                    //                        animationFadeOut()
                    imageView.image = images[selectedImageIndex]
                    if UserDefaults.standard.object(forKey: .UserDefaultsKey.animation) != nil {
                        switch UserDefaults.standard.integer(forKey: .UserDefaultsKey.animation) {
                        case 0: break // Simple
                        case 1: animationSwipeToLeft() // Swipe
                        case 2: animationFadeIn() // Dissappearance
                        default: break // Simple
                        }
                    }
                    favouriteButtonStyle()
                    favouriteLabelShowComment()
                } else {
                    viewNextImage()
                }
            }
        } else { // показывать все
            //                animationSwipeRightTo()
            //                animationFadeOut()
            imageView.image = images[selectedImageIndex]
            if UserDefaults.standard.object(forKey: .UserDefaultsKey.animation) != nil {
                switch UserDefaults.standard.integer(forKey: .UserDefaultsKey.animation) {
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

    func viewPrevImage() {
        if UserDefaults.standard.bool(forKey: .UserDefaultsKey.randomOrder) {
            selectedImageIndex = Int(arc4random_uniform(UInt32(images.count-1)))
        } else {
            selectedImageIndex = selectedImageIndex - 1 >= 0 ? selectedImageIndex - 1 : images.count - 1
        }

        if UserDefaults.standard.bool(forKey: .UserDefaultsKey.showFavourites) {
            if favouriteIndex.isEmpty {
                let alert = UIAlertController(title: "Sorry", message: "Missing list of Favourites", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default) { _ in
                    UserDefaults.standard.set(false, forKey: .UserDefaultsKey.showFavourites)
                }
                alert.addAction(okAction)
                self.present(alert, animated: true, completion: nil)
            } else { // если массив индексов Favourites все же не пуст
                if favouriteIndex.contains(selectedImageIndex) { // изображение в Favourites
                    //                        animationSwipeLeftTo()
                    //                        animationFadeOut()
                    imageView.image = images[selectedImageIndex]
                    if UserDefaults.standard.object(forKey: .UserDefaultsKey.animation) != nil {
                        switch UserDefaults.standard.integer(forKey: .UserDefaultsKey.animation) {
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
            imageView.image = images[selectedImageIndex]
            if UserDefaults.standard.object(forKey: .UserDefaultsKey.animation) != nil {
                switch UserDefaults.standard.integer(forKey: .UserDefaultsKey.animation) {
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

    private func favouriteButtonStyle() {
        favouriteButton.style = favouriteIndex.contains(selectedImageIndex) ? .done : .plain
    }

    private func favouriteLabelShowComment() {
        labelComment.text = favouriteIndex.contains(selectedImageIndex) ? favouriteComments[selectedImageIndex] : ""
    }

    private func animationSwipeLeftTo() {
        imageView.center.x = view.center.x
        labelComment.center.x = view.center.x
        UIView.animate(withDuration: Constants.animationDuration) {
            self.imageView.center.x += self.view.bounds.width
            self.labelComment.center.x += self.view.bounds.width
        }
    }

    private func animationSwipeToRight() {
        imageView.center.x -= view.bounds.width
        labelComment.center.x -= view.bounds.width
        UIView.animate(withDuration: Constants.animationDuration) {
            self.imageView.center.x += self.view.bounds.width
            self.labelComment.center.x += self.view.bounds.width
        }
    }

    private func animationSwipeRightTo() {
        imageView.center.x = view.center.x
        labelComment.center.x = view.center.x
        UIView.animate(withDuration: Constants.animationDuration) {
            self.imageView.center.x -= self.view.bounds.width
            self.labelComment.center.x -= self.view.bounds.width
        }
    }

    private func animationSwipeToLeft() {
        imageView.center.x += view.bounds.width
        labelComment.center.x += view.bounds.width
        UIView.animate(withDuration: Constants.animationDuration) {
            self.imageView.center.x -= self.view.bounds.width
            self.labelComment.center.x -= self.view.bounds.width
        }
    }

    private func animationFadeOut() {
        imageView.alpha = 1.0
        labelComment.alpha = 1.0
        UIView.animate(withDuration: Constants.otherAnimationDuration) {
            self.imageView.alpha = 0.0
            self.imageView.alpha = 0.0
        }
    }

    private func animationFadeIn() {
        imageView.alpha = 0.0
        labelComment.alpha = 0.0
        UIView.animate(withDuration: Constants.otherAnimationDuration) {
            self.imageView.alpha = 1.0
            self.imageView.alpha = 1.0
        }
    }

    @IBAction func addToFavourite(sender: AnyObject) {
        if favouriteIndex.contains(selectedImageIndex) {
            favouriteIndex.remove(at: selectedImageIndex)
            favouriteButton.style = .plain
            favouriteComments[selectedImageIndex] = nil
            favouriteLabelShowComment()
        } else {
            favouriteIndex.append(selectedImageIndex)
            favouriteButton.style = .done
            var commentTextField: UITextField?
            let alertController = UIAlertController(
                title: "Favourite",
                message: "Please enter your comment",
                preferredStyle: UIAlertController.Style.alert)
            let commentAction = UIAlertAction(title: "Save comment", style: .default) { _ in
                if let comment = commentTextField?.text {
                    self.favouriteComments[self.selectedImageIndex] = comment
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
            self.present(alertController, animated: true)
        }
    }
}
