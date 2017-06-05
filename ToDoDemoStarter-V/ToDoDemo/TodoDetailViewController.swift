//
//  TodoDetailViewController.swift
//  ToDoDemo
//
//  Created by Mars on 26/04/2017.
//  Copyright © 2017 Mars. All rights reserved.
//

import UIKit
import RxSwift

class TodoDetailViewController: UITableViewController {
    fileprivate let images = Variable<[UIImage]>([])
    fileprivate var todoCollage: UIImage?
    
    fileprivate let todoSubject = PublishSubject<TodoItem>()
    var todo: Observable<TodoItem> {
        return todoSubject.asObservable()
    }
    var bag = DisposeBag()

    var todoItem: TodoItem!

    @IBOutlet weak var todoName: UITextField!
    @IBOutlet weak var isFinished: UISwitch!
    @IBOutlet weak var doneBarBtn: UIBarButtonItem!
    @IBOutlet weak var memoCollageBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        todoName.becomeFirstResponder()

        images.asObservable().subscribe(onNext: {
            [weak self] images in
            guard let `self` = self else { return }
            guard !images.isEmpty else {
                self.resetMemoBtn()
                return
            }

            /// 1. Merge photos
            self.todoCollage = UIImage.collage(images: images, in: self.memoCollageBtn.frame.size)
            /// 2. Set the merged photo as the background image of the button
            self.setMemoBtn(bkImage: self.todoCollage ?? UIImage())
        }).addDisposableTo(bag)

        if let todoItem = todoItem {
            self.todoName.text = todoItem.name
            self.isFinished.isOn = todoItem.isFinished
            
            if todoItem.pictureMemoFilename != "" {
                let url = getDocumentsDir().appendingPathComponent(todoItem.pictureMemoFilename)
                if let data = try? Data(contentsOf: url) {
                    self.memoCollageBtn.setBackgroundImage(UIImage(data: data), for: .normal)
                    self.memoCollageBtn.setTitle("", for: .normal)
                }
            }
            
            doneBarBtn.isEnabled = true
        }
        else {
            todoItem = TodoItem()
        }


    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    @IBAction func cancel() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func done() {
        todoItem.name = todoName.text!
        todoItem.isFinished = isFinished.isOn
        todoItem.pictureMemoFilename = savePictureMemos()

        todoSubject.onNext(todoItem)
        todoSubject.onCompleted()
        dismiss(animated: true, completion: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let photoCollectionViewController =
                segue.destination as! PhotoCollectionViewController
        images.value.removeAll()
        resetMemoBtn()

        // TODO: Subscribe all selected photos here
        let selectedPhotos = photoCollectionViewController.selectedPhotos
        selectedPhotos.subscribe(onNext: { image in
            self.images.value.append(image)
        }, onDisposed: {
            print("Finished choosing photo memos.")
        }).addDisposableTo(photoCollectionViewController.bag)
    }
}

extension TodoDetailViewController {
    fileprivate func getDocumentsDir() -> URL {
        return FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask)[0]
    }
    
    fileprivate func resetMemoBtn() {
        // Todo: Reset the add picture memo btn style
        memoCollageBtn.setBackgroundImage(nil, for: .normal)
        memoCollageBtn.setTitle("Tap here to add your picture memos.", for: .normal)
    }
    
    fileprivate func setMemoBtn(bkImage: UIImage) {
        // Todo: Set the background and title of add picture memo btn
        memoCollageBtn.setBackgroundImage(bkImage, for: .normal)
        memoCollageBtn.setTitle("", for: .normal)
    }
    
    fileprivate func savePictureMemos() -> String {
        // Todo: Save the picture memos preview as a png
        // file and return its file name.

        if let todoCollage = self.todoCollage,
            let data = UIImagePNGRepresentation(todoCollage) {
            let path = getDocumentsDir()
            let filename = self.todoName.text! + UUID().uuidString + ".png"
            let memoImageUrl = path.appendingPathComponent(filename)

            try? data.write(to: memoImageUrl)

            return filename
        }

        return self.todoItem.pictureMemoFilename
    }
}

extension TodoDetailViewController {
    override func tableView(_ tableView: UITableView,
                            willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return nil
    }
    
    func setMemoSectionHederText() {
        // Todo: Set section header to the number of
        // pictures selected.
        guard !images.value.isEmpty,
              let headerView = self.tableView.headerView(forSection: 2) else { return }

        headerView.textLabel?.text = "\(images.value.count) MEMOS"
    }
}

extension TodoDetailViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        let oldText = textField.text! as NSString
        let newText = oldText.replacingCharacters(in: range, with: string) as NSString
        
        doneBarBtn.isEnabled = newText.length > 0
        
        return true
    }
}
