//
//  WordCollectionViewCell.swift
//  DetectFaceLandmarks
//
//  Created by tommy19970714 on 2019/10/27.
//  Copyright © 2019 mathieu. All rights reserved.
//

import UIKit

// CollectionViewのセル設定
class WordCollectionViewCell: UICollectionViewCell {
    private let cellNameLabel: UILabel = {
        let label = UILabel()
        label.frame = CGRect(x: 0, y: 0, width: 200, height: 100)
        label.font = .systemFont(ofSize: 25, weight: UIFont.Weight(rawValue: 1))
        label.textColor = UIColor.white
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        contentView.addSubview(cellNameLabel)
    }
    
    func setUpContents(textName: String) {
        cellNameLabel.text = textName
    }
}
