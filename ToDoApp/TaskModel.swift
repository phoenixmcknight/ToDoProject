//
//  TaskModel.swift
//  ToDoApp
//
//  Created by Phoenix McKnight on 4/21/20.
//  Copyright © 2020 Phoenix McKnight. All rights reserved.
//

import Foundation

struct TaskModel:Codable {
  
   private var dueDate:String
   private var title:String
   private var createdDate:Date
    
   private var completed:Bool = false
   private var completedDate:String? = nil
  
    static func createTask(title:String,dueDate:String,date:Date) -> TaskModel {
        return TaskModel(dueDate: dueDate, title: title,createdDate:date)
    }
    
    mutating public func setTaskToComplete() {
        completedDate = Date().returnCurrentDate()
        completed = true
    }
    
    public func isTaskComplete() -> Bool {
        return completed
    }
    
    public func returnCreatedDateAsString() -> String {
        return "Created: \(createdDate.returnCurrentDate())"
    }
    
    public func returnCompletedDate() -> String {
        return "Completed : \(completedDate ?? "N/A")"
    }
    
    public func returnDueDate() -> String {
    return "Due Date: \(dueDate)"
    }
    
    public func returnUnmodifiedDate() -> Date {
        return createdDate
    }
    
    public func returnTaskTitle() -> String {
        return title
    }
    
    public func convertDueDateToTypeDate() -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        return formatter.date(from: dueDate)
    }
   
}
