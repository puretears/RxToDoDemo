//
//  PhotoCell.swift
//  ToDoDemo
//
//  Created by Mars on 21/05/2017.
//  Copyright © 2017 Mars. All rights reserved.
//

import UIKit
import RxSwift

class PhotoCell: UICollectionViewCell {
    @IBOutlet var imageView: UIImageView!
    @IBOutlet weak var checkmark: UIImageView!
    
    var representedAssetIdentifier: String!
    var isCheckmarked: Bool = false
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageView.image = nil
    }
    
    func flipCheckmark() {
        self.isCheckmarked = !self.isCheckmarked
    }
    
    func selected() {
        self.flipCheckmark()
        setNeedsDisplay()
        
        UIView.animate(withDuration: 0.1,
            animations: { [weak self] in
                
            if let isCheckmarked = self?.isCheckmarked {
                self?.checkmark.alpha = isCheckmarked ? 1 : 0
            }
        })
    }
}
