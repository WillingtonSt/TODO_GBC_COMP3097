//
//  ListViewController.swift
//  TODO_COMP3097
//
//  Created by Will on 2025-03-11.
//
import UIKit

class ListViewController: UIViewController {
    var newList: List?
    
    @IBOutlet weak var titleField: UITextField!
    
    override func viewDidLoad() {
        titleField.text = newList?.title
        super.viewDidLoad()
    }
    
}

