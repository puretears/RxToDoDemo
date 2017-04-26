//
//  TodoListTableView.swift
//  ToDoDemo
//
//  Created by Mars on 25/04/2017.
//  Copyright © 2017 Mars. All rights reserved.
//

import UIKit

// UITableView delegate
extension TodoListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        
        if let cell = tableView.cellForRow(at: indexPath) {
            let todo = todoItems[indexPath.row]
            
            todo.toggleFinished()
            configureStatus(for: cell, with: todo)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView,
                   commit editingStyle: UITableViewCellEditingStyle,
                   forRowAt indexPath: IndexPath) {
        
        todoItems.remove(at: indexPath.row)
        
        // 2
        let indexPaths = [indexPath]
        tableView.deleteRows(at: indexPaths, with: .automatic)
    }
}

// UITableView data source
extension TodoListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return self.todoItems.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "TodoItem", for: indexPath)
        let todo = todoItems[indexPath.row]
        
        configureLabel(for: cell, with: todo)
        configureStatus(for: cell, with: todo)
        
        return cell
    }
}
