//
//  PhotoCollectionViewController.swift
//  ToDoDemo
//
//  Created by Mars on 21/05/2017.
//  Copyright © 2017 Mars. All rights reserved.
//

import UIKit
import Photos
import RxSwift

class PhotoCollectionViewController: UICollectionViewController {
    fileprivate lazy var photos = PhotoCollectionViewController.loadPhotos()
    fileprivate lazy var imageManager = PHCachingImageManager()

    fileprivate let selectedPhotosSubject = PublishSubject<UIImage>()
    var selectedPhotos: Observable<UIImage> {
        return selectedPhotosSubject.asObservable()
    }
    let bag = DisposeBag()
    
    fileprivate lazy var thumbnailsize: CGSize = {
        let cellSize = (self.collectionViewLayout as! UICollectionViewFlowLayout).itemSize
        
        return CGSize(width: cellSize.width * UIScreen.main.scale,
                      height: cellSize.height * UIScreen.main.scale)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setCellSpace()

        let isAuthorized = PHPhotoLibrary.isAuthorized.share()

        isAuthorized
            .skipWhile { $0 == false }
            .take(1)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: {
                [weak self] _ in
                // Reload the photo collection view
                if let `self` = self {
                    self.photos = PhotoCollectionViewController.loadPhotos()
                    self.collectionView?.reloadData()
                }
            })
            .addDisposableTo(bag)

        isAuthorized
            .distinctUntilChanged()
            .takeLast(1)
            .filter(!)
            .subscribe(onNext: { _ in
                self.flash(title: "Cannot access your photo library",
                    message: "You can authorize access from the Settings.",
                    callback: { _ in
                        self.navigationController?.popViewController(animated: true)
                    })
            })
            .addDisposableTo(bag)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        selectedPhotosSubject.onCompleted()
    }
}

// Photo library
extension PhotoCollectionViewController {
    
    static func loadPhotos() -> PHFetchResult<PHAsset> {
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        
        return PHAsset.fetchAssets(with: options)
    }
}

// Collection view related
extension PhotoCollectionViewController {
    func setCellSpace() {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        let width = UIScreen.main.bounds.width
        layout.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        layout.itemSize = CGSize(width: (width-40) / 4, height: (width-40) / 4)
        collectionView!.collectionViewLayout = layout
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let asset = photos.object(at: indexPath.item)
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "PhotoMemo", for: indexPath) as! PhotoCell
        
        cell.representedAssetIdentifier = asset.localIdentifier
        
        imageManager.requestImage(for: asset,
            targetSize: thumbnailsize,
            contentMode: .aspectFill,
            options: nil,
            resultHandler: { (image, _) in
                guard let image = image else { return }
            
                if cell.representedAssetIdentifier == asset.localIdentifier {
                    cell.imageView.image = image
                }
            }
        )
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 didSelectItemAt indexPath: IndexPath) {
        let asset = photos.object(at: indexPath.item)

        if let cell = collectionView.cellForItem(at: indexPath) as? PhotoCell {
            cell.selected()
        }

        imageManager.requestImage(for: asset,
            targetSize: view.frame.size,
            contentMode: .aspectFill,
            options: nil,
            resultHandler: { [weak self] (image, info) in
                guard let image = image, let info = info else { return }

                if let isThumbnail = info[PHImageResultIsDegradedKey] as? Bool,
                   !isThumbnail {

                    self?.selectedPhotosSubject.onNext(image)
                }
            })
    }

}
