import Foundation
import CoreData

@objc(TaskList)
public class TaskList: NSManagedObject, Identifiable {
    @NSManaged public var id: UUID
    @NSManaged public var title: String
    @NSManaged public var createdAt: Date
    @NSManaged public var order: Int
    @NSManaged public var tasks: NSSet?
}

extension TaskList {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<TaskList> {
        return NSFetchRequest<TaskList>(entityName: "TaskList")
    }
    
    var tasksArray: [TaskItem] {
        let set = tasks as? Set<TaskItem> ?? []
        return set.sorted { $0.order < $1.order }
    }
    
    var completedCount: Int {
        tasksArray.filter { $0.isCompleted }.count
    }
    
    var totalCount: Int {
        tasksArray.count
    }
    
    var progress: Double {
        guard totalCount > 0 else { return 0 }
        return Double(completedCount) / Double(totalCount)
    }
}
