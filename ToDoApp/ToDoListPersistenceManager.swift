

import Foundation

struct ToDoListPersistenceManager {
    static let manager = ToDoListPersistenceManager()
    
    func saveToDoListArray(tasks:[TaskModel]) throws {
        try persistenceHelper.saveArray(newElement: tasks)
    }
    
    func getSavedTasks() throws -> [TaskModel] {
        
        return try persistenceHelper.getObjects()
    }
    
    private let persistenceHelper = PersistenceHelper<TaskModel>(fileName: "ToDoList.plist")
    
    private init() {}
}

