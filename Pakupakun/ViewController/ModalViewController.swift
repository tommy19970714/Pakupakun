//
//  ModalViewController.swift
//  DetectFaceLandmarks
//
//  Created by tommy19970714 on 2019/10/27.
//  Copyright © 2019 mathieu. All rights reserved.
//

import UIKit
import BubbleTransition

class ModalViewController: UIViewController {
    @IBOutlet weak var closeButton: UIButton!
    weak var interactiveTransition: BubbleInteractiveTransition?
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var textLabel: UILabel!
    
    var inputs: [String] = []
    
    var data: [String] = []
  
    override func viewDidLoad() {
        super.viewDidLoad()
        closeButton.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 4)
        
        collectionView.register(WordCollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(catchNotification(notification:)), name: .receiveSocket, object: nil)
    }
  
    @IBAction func closeAction(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)

        // NOTE: when using interactive gestures, if you want to dismiss with a button instead, you need to call finish on the interactive transition to avoid having the animation stuck
        interactiveTransition?.finish()
    }
  
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.setStatusBarStyle(.lightContent, animated: true)
    }
  
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.setStatusBarStyle(.default, animated: true)
    }
    
    @objc func catchNotification(notification: Notification) {
        switch notification.name {
        case .receiveSocket:
            if let text = notification.userInfo?["text"] as? [String] {
                textLabel.text = text.first
            }
        default:
            break
        }
    }
}


extension ModalViewController: UICollectionViewDelegate {
    // セル選択時の処理
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(data[indexPath.row])
    }
}

extension ModalViewController: UICollectionViewDataSource {
    // セルの数を返す
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
    
    // セルの設定
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell",for: indexPath as IndexPath) as! WordCollectionViewCell
        let cellText = data[indexPath.item]
        cell.setUpContents(textName: cellText)
        return cell
    }
}

extension ModalViewController:  UICollectionViewDelegateFlowLayout {
    // セルの大きさ
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 200, height: 100)
    }
    
    // セルの余白
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 50, left: 50, bottom: 50, right: 50)
    }
}
