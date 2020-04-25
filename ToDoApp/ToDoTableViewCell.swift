//
//  ToDoTableViewCell.swift
//  ToDoApp
//
//  Created by Phoenix McKnight on 4/21/20.
//  Copyright © 2020 Phoenix McKnight. All rights reserved.
//

import UIKit

enum ButtonClicked {
    case completed
    case delete
}

enum CellIdentifier:String {
    case outstanding
    case completed
}
protocol ToDoButtonClickedDelegate:AnyObject {
    func buttonClicked(buttonClicked:ButtonClicked,section:Int,creationDate:Date)
}


class ToDoTableViewCell: UITableViewCell {
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var setTaskToCompleteButton: UIButton!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    
    @IBOutlet weak var dueDateLabel: UILabel!
    
    @IBOutlet weak var deleteButton: UIButton!
    
    
    weak var delegate:ToDoButtonClickedDelegate?
    
    
   private var section:Int?
    
   private var creationDate:Date?
    
    @IBAction func completeButtonAction(_ sender: UIButton) {
        guard let section = section, let creationDate = creationDate  else {return}
        switch sender.tag {
        case 0:
            delegate?.buttonClicked(buttonClicked: .completed, section: section, creationDate: creationDate )
        default:
            delegate?.buttonClicked(buttonClicked: .delete, section: section, creationDate: creationDate)
        }
    }
    
    public func configureCell(task:TaskModel,indexPath:IndexPath) {
        descriptionLabel.text = task.returnTaskTitle()
        
        section = indexPath.section
        creationDate = task.returnUnmodifiedDate()
        
        switch task.isTaskComplete() {
        case true:
            dateLabel.text = task.returnCompletedDate()
            setTaskToCompleteButton.isHidden = true
            
            self.alpha = 0.4
            self.backgroundColor = .lightGray
        case false:
        
            if Date() > task.convertDueDateToTypeDate() ?? Date() {
                self.backgroundColor = #colorLiteral(red: 1, green: 0.5216899514, blue: 0.5296583772, alpha: 1)
            } else {
                self.backgroundColor = #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1)
            }
            dateLabel.text = task.returnCreatedDateAsString()
            dueDateLabel.text = task.returnDueDate()
        }
    }
 
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
