//
//  TodoListViewAlert.swift
//  ToDoDemo
//
//  Created by Mars on 29/04/2017.
//  Copyright © 2017 Mars. All rights reserved.
//

import UIKit


extension TodoListViewController {
    typealias AlertCallback =  ((UIAlertAction) -> Void)
    
    func flash(title: String, message: String, callback: AlertCallback? = nil) {
        let alertController = UIAlertController(
            title: title,
            message: message,
            preferredStyle: UIAlertControllerStyle.alert)
        
        let okAction = UIAlertAction(
            title: "OK",
            style: UIAlertActionStyle.default,
            handler: callback)
        
        alertController.addAction(okAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
}
