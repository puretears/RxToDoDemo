//
//  TodoListViewConfigure.swift
//  TodoDemo
//
//  Created by Mars on 24/04/2017.
//  Copyright © 2017 Mars. All rights reserved.
//

import UIKit

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
            return ubiquityURL!.appendingPathComponent("filename")
        }
        
        return nil
    }
    
    func syncTodoToCloud() {
        guard let cloudUrl = ubiquityURL("Documents/TodoList.plist") else {
            self.flash(title: "Failed",
                    message: "You should enabled iCloud in Settings first.")

            return
        }

        guard let localData = NSData(contentsOf: dataFilePath()) else {
            self.flash(title: "Failed",
                    message: "Cannot read local file.")

            return
        }

        let plist = PlistDocument(fileURL: cloudUrl, data: localData)

        plist.save(to: cloudUrl, for: .forOverwriting, completionHandler: {
            (success: Bool) -> Void in
            print(cloudUrl)

            if success {
                self.flash(title: "Success",
                        message: "All todos are synced to cloud.")
            } else {
                self.flash(title: "Failed",
                        message: "Sync todos to cloud failed")
            }
        })
    }
    
    func saveTodoItems() {
        let data = NSMutableData()
        let archiver = NSKeyedArchiver(forWritingWith: data)
        
        archiver.encode(todoItems.value, forKey: "TodoItems")
        archiver.finishEncoding()
        
        data.write(to: dataFilePath(), atomically: true)
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
