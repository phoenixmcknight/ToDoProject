//
//  ViewController.swift
//  ToDoApp
//
//  Created by Phoenix McKnight on 4/21/20.
//  Copyright © 2020 Phoenix McKnight. All rights reserved.
//

import UIKit

class ToDoViewController: UIViewController {
    
    @IBOutlet weak var toDoTableView: UITableView!
    
    
    private var tasks:[[TaskModel]] = [[TaskModel](),[TaskModel]()] {
        didSet {
            do { try ToDoListPersistenceManager.manager.saveToDoListArray(tasks: tasks[0] + tasks[1]) } catch {print(error)}
            toDoTableView.isUserInteractionEnabled = true
        }
    }
    
    private var appIsLoading:Bool = true
    
    private var isTaskSectionEmpty:[Bool] = [true,true] 
    
    lazy var alertTextfield:UITextField = UITextField()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setDelegates()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        view.setGradientBackground(colorTop: #colorLiteral(red: 0.5740930438, green: 0.5706835389, blue: 0.5767160058, alpha: 1), colorBottom: #colorLiteral(red: 0.4551740885, green: 0.4572850466, blue: 0.4624292254, alpha: 1))
        toDoTableView.backgroundColor = .clear
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        returnSavedTasks()
    }
    
    private func returnSavedTasks() {
        
        do {
            _ = try ToDoListPersistenceManager.manager.getSavedTasks().forEach { (task) in

                if task.isTaskComplete() == false {
                    tasks[0].append(task)
                    isTaskSectionEmpty[0] = false
                } else {
                    tasks[1].append(task)
                    isTaskSectionEmpty[1] = false
                }
            }
        } catch {
            print(error)
        }
        toDoTableView.reloadData()
        
    }
    
    private func setDelegates() {
        toDoTableView.dataSource = self
        toDoTableView.delegate = self
    }
    
    @IBAction func createNewTaskAction(_ sender: UIButton) {
        appIsLoading = false
        newTaskAlert(title: "Create New Task", message: "↓ Enter Information Here ↓")
    }
    
    
    
    private func newTaskAlert (title:String,message:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addTextField { [weak self](titleTextField) in
            self?.formatAlertTextFields(textFieldStyle: .title, textField: titleTextField)
        }
        alert.addTextField { [weak self] (dueDateTextField) in
            self?.formatAlertTextFields(textFieldStyle: .dueDate, textField: dueDateTextField)
        }
        
        let enter = UIAlertAction(title: "Enter", style: .default) { [weak self](_) in
            
            self?.handleAlertEnterButtonPressed(titleTextField: alert.textFields?.first?.text, dueDateTextField: alert.textFields?.last?.text)
        }
        let cancel = UIAlertAction(title: "cancel", style: .cancel, handler: nil)
        alert.addAction(cancel)
        alert.addAction(enter)
        present(alert,animated: true)
    }
    
    
    
    private func formatAlertTextFields(textFieldStyle:alertTextFieldStyle,textField:UITextField) {
        
        switch textFieldStyle {
            
        case .title:
            textField.placeholder = "Title"
        case .dueDate:
            textField.placeholder = "Due Date"
            textField.inputView = confingureDatePicker()
            textField.inputAccessoryView = UIToolbar().createToolBar(textField: textField, doneButton: UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(toolBarDoneButtonPressed)))
            textField.delegate = self
            alertTextfield = textField
        }
    }
    
    private func confingureDatePicker() -> UIDatePicker {
        let datePicker = UIDatePicker()
        datePicker.date = Date()
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(self.dateValueChanged(sender:)), for: .valueChanged)
        return datePicker
    }
    
    @objc private func dateValueChanged(sender:UIDatePicker) {
        
        alertTextfield.text = sender.date.returnCurrentDate()
    }
    
    @objc private func toolBarDoneButtonPressed() {
        alertTextfield.endEditing(true)
    }
    
    private func handleAlertEnterButtonPressed(titleTextField:String?,dueDateTextField:String?) {
        
        createNewTask(title: titleTextField, dueDate: dueDateTextField)
        
        if self.isTaskSectionEmpty[0] == true {
            self.isTaskSectionEmpty[0] = false
    
           toDoTableView.reloadSections([0], with: .none)
        } else {
            UIView.animate(withDuration: 0.5) {
                  self.insertTableViewRow(section:0, animation: .fade)
            }
          
        }
    }
    
    private func createNewTask(title:String?,dueDate:String?) {
        guard let title = title, let dueDate = dueDate else {return}
        var task:TaskModel? = nil
        switch (title == "", dueDate == "") {
            
        case (true,true):
          
            task = TaskModel.createTask(title: "New Task", dueDate: "01/01/2100",date: Date())
        case (true,false):
            
            task = TaskModel.createTask(title: "New Task", dueDate: dueDate,date: Date())
        case (false,true):

            task = TaskModel.createTask(title: title, dueDate: "01/01/2100",date: Date())
        case (false,false):
            task = TaskModel.createTask(title: title, dueDate: dueDate,date: Date())
        }
        tasks[0].append(task!)
    }
    
   
}

extension ToDoViewController:UITableViewDataSource,UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        tasks.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if isTaskSectionEmpty[section] == false {
            return tasks[section].count
        }
        else {
            return 1
        }
    }
    
   
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard isTaskSectionEmpty[indexPath.section] == false else {
            let cell = UITableViewCell()
            cell.backgroundColor = .clear
            switch indexPath.section {
            case 0:
                
                cell.textLabel?.text = "No Outstanding Tasks"
                return cell
                
            case 1:
                cell.textLabel?.text = "No Completed Tasks"
                return cell
            default:
                return UITableViewCell()
            }
        }
        
        let currentTask = tasks[indexPath.section][indexPath.row]
        
        guard let cell = toDoTableView.dequeueReusableCell(withIdentifier: indexPath.section == 0 ? CellIdentifier.outstanding.rawValue : CellIdentifier.completed.rawValue) as? ToDoTableViewCell else {return UITableViewCell()}
        
        cell.configureCell(task: currentTask, indexPath: indexPath)
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
       updateTableViewHeaderText(section: section)
        switch section {
        case 0:
            return  "Outstanding (\(tasks[section].count))"
        case 1:
            return "Completed (\(tasks[section].count))"
        default:
            return "none"
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if appIsLoading == true || tasks[indexPath.section].count <= 1 {
            cell.cellAnimation( indexPath: indexPath)
        }
    }
    
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor.white
        header.textLabel?.textAlignment = .center
        header.contentView.backgroundColor = #colorLiteral(red: 0.2202990353, green: 0.2189959288, blue: 0.2213048935, alpha: 1)
    }
}
extension ToDoViewController:ToDoButtonClickedDelegate {
    func buttonClicked(buttonClicked: ButtonClicked, section: Int,creationDate:Date) {
      
        let index = tasks[section].firstIndex(where: {$0.returnUnmodifiedDate() == creationDate  })
        
        UIView.animate(withDuration: 0.5) {
            
        switch buttonClicked {
        case .completed:
            self.appIsLoading = false

            self.moveTableViewRow(cellIndexPath: IndexPath(row: index ?? 0, section: section))
            
        case .delete:
            self.appIsLoading = false
            self.deleteTableViewRow(cellIndexPath: IndexPath(row: index ?? 0, section: section),animation: .left)
        }
        }
}
}
extension ToDoViewController:UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return false
    }
}

extension ToDoViewController {
    
    private func insertTableViewRow(section:Int,animation:UITableView.RowAnimation) {
        
           let firstIndex = IndexPath(row: tasks[section].count - 1, section: section)
           toDoTableView.beginUpdates()
           
           toDoTableView.insertRows(at: [firstIndex], with: animation)
           toDoTableView.endUpdates()
       }
       
       private func deleteTableViewRow(cellIndexPath:IndexPath,animation:UITableView.RowAnimation) {
           
           if tasks[cellIndexPath.section].count > 1 {
               toDoTableView.beginUpdates()
               toDoTableView.deleteRows(at: [cellIndexPath], with: animation)
               tasks[cellIndexPath.section].remove(at: cellIndexPath.row)
               toDoTableView.endUpdates()
           } else {
               tasks[cellIndexPath.section].remove(at: 0)
               isTaskSectionEmpty[cellIndexPath.section] = true
             
            toDoTableView.reloadSections([cellIndexPath.section], with: .none)
           }
       }
       
       private func moveTableViewRow(cellIndexPath:IndexPath) {
           
           if tasks[1].count == 0 {
               isTaskSectionEmpty[1] = false
            
            toDoTableView.reloadSections([1], with: .none)
           }
    
              self.toDoTableView.beginUpdates()
            self.toDoTableView.isUserInteractionEnabled = false
                  

            var selectedTask = self.tasks[0][cellIndexPath.row]
            selectedTask.setTaskToComplete()
            self.tasks[1].append(selectedTask)
     
                      self.deleteTableViewRow(cellIndexPath: cellIndexPath,animation: .left)
                      self.insertTableViewRow(section: 1, animation: .right)
                      self.toDoTableView.endUpdates()
    
    }
    
    private func updateTableViewHeaderText(section:Int) {
        if let header =  toDoTableView.headerView(forSection: section) {
        header.textLabel?.adjustsFontSizeToFitWidth = true
        
         let headerText = header.textLabel?.text?.components(separatedBy: " ")
        
        header.textLabel?.text = (headerText?.first!)! + " " + "(\(tasks[section].count))"
        }
    }
    private enum alertTextFieldStyle {
        case title
        case dueDate
    }
}
