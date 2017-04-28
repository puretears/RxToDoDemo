//
//  TodoDetailViewController.swift
//  ToDoDemo
//
//  Created by Mars on 26/04/2017.
//  Copyright © 2017 Mars. All rights reserved.
//

import UIKit

class TodoDetailViewController: UITableViewController {
    @IBOutlet weak var todoName: UITextField!
    @IBOutlet weak var isFinished: UISwitch!
    @IBOutlet weak var doneBarBtn: UIBarButtonItem!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        todoName.becomeFirstResponder()
    }
    
    @IBAction func cancel() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func done() {
        dismiss(animated: true, completion: nil)
    }
}

extension TodoDetailViewController {
    override func tableView(_ tableView: UITableView,
                            willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return nil
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
