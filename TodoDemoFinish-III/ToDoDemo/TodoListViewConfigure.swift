//
//  TodoListViewConfigure.swift
//  TodoDemo
//
//  Created by Mars on 24/04/2017.
//  Copyright © 2017 Mars. All rights reserved.
//

import UIKit
import RxSwift

let CELL_CHECKMARK_TAG = 1001
let CELL_TODO_TITLE_TAG = 1002

enum SaveTodoError: Error {
    case cannotSaveToLocalFile
    case iCloudIsNotEnabled
    case cannotReadLocalFile
    case cannotCreateFileOnCloud
}

extension TodoListViewController {
    func configureStatus(for cell: UITableViewCell, with item: TodoItem) {
        let label = cell.viewWithTag(CELL_CHECKMARK_TAG) as! UILabel
        
        if item.isFinished {
            label.text = "✓"
        }
        else {
            label.text = ""
        }
    }
    
    func configureLabel(for cell: UITableViewCell, with item: TodoItem) {
        let label = cell.viewWithTag(CELL_TODO_TITLE_TAG) as! UILabel
        
        label.text = item.name
    }
    
    func documentsDirectory() -> URL {
        let path = FileManager.default.urls(
            for: .documentDirectory, in: .userDomainMask)
        
        return path[0]
    }
    
    func dataFilePath() -> URL {
        return documentsDirectory().appendingPathComponent("TodoList.plist")
    }
    
    func ubiquityURL(_ filename: String) -> URL? {
        let ubiquityURL =
            FileManager.default.url(forUbiquityContainerIdentifier: nil)
        
        if ubiquityURL != nil {
            return ubiquityURL!.appendingPathComponent(filename)
        }
        
        return nil
    }
    
    func syncTodoToCloud() -> Observable<URL> {

        return Observable.create({ observer in
            guard let cloudUrl = self.ubiquityURL("Documents/TodoList.plist") else {
                observer.onError(SaveTodoError.iCloudIsNotEnabled)
                return Disposables.create()
            }

            guard let localData = NSData(contentsOf: self.dataFilePath()) else {
                observer.onError(SaveTodoError.cannotReadLocalFile)
                return Disposables.create()
            }

            let plist = PlistDocument(fileURL: cloudUrl, data: localData)

            plist.save(to: cloudUrl, for: .forOverwriting, completionHandler: {
                (success: Bool) -> Void in

                if success {
                    observer.onNext(cloudUrl)
                    observer.onCompleted()
                } else {
                    observer.onError(SaveTodoError.cannotCreateFileOnCloud)
                }
            })

            return Disposables.create()
        })
    }
    
    func saveTodoItems() -> Observable<Void> {
        let data = NSMutableData()
        let archiver = NSKeyedArchiver(forWritingWith: data)
        
        archiver.encode(todoItems.value, forKey: "TodoItems")
        archiver.finishEncoding()
        
        return Observable.create({ observer in
            
            let result = data.write(
                to: self.dataFilePath(), atomically: true)
            
            if !result {
                observer.onError(SaveTodoError.cannotSaveToLocalFile)
            }
            else {
                observer.onCompleted()
            }
            
            return Disposables.create()
        })
    }
    
    func loadTodoItems() {
        let path = dataFilePath()
        
        if let data = try? Data(contentsOf: path) {
            let unarchiver = NSKeyedUnarchiver(forReadingWith: data)
            todoItems.value = unarchiver.decodeObject(forKey: "TodoItems") as! [TodoItem]
            
            unarchiver.finishDecoding()
        }
    }
}
