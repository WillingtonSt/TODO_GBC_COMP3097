//
//  ReminderViewController.swift
//  TODO_COMP3097
//
//  Created by Will Steep on 2025-04-03.
//

import UIKit

class ReminderViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var listPicker: UIPickerView!

    var lists: [List] = []
    var selectedList: List?

    override func viewDidLoad() {
        super.viewDidLoad()

        listPicker.delegate = self
        listPicker.dataSource = self

        if let email = UserDefaults.standard.string(forKey: "currentUserEmail") {
            lists = CoreDataManager.shared.fetchListsForCurrentUser(withEmail: email)
        }

        // Set default selection
        if !lists.isEmpty {
            selectedList = lists[0]
        }

        // Prevent past dates
        datePicker.minimumDate = Date()
    }

    @IBAction func saveReminderButtonTapped(_ sender: UIButton) {
       
        
        guard let selectedList = selectedList else {
            showAlert("Please select a list")
            return
        }

        let dueDate = datePicker.date
        CoreDataManager.shared.saveReminder(dueDate: dueDate, list: selectedList)

        showAlert("Reminder saved successfully!") {
            self.navigationController?.popViewController(animated: true)
        }
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return lists.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return lists[row].title
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedList = lists[row]
    }

    func showAlert(_ message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: "Notice", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in completion?() }))
        present(alert, animated: true)
    }
}
