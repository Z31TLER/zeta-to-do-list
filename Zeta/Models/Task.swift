import Foundation
import CoreData

@objc(TaskItem)
public class TaskItem: NSManagedObject, Identifiable {
    @NSManaged public var id: UUID
    @NSManaged public var title: String
    @NSManaged public var isCompleted: Bool
    @NSManaged public var createdAt: Date
    @NSManaged public var scheduledDate: Date?
    @NSManaged public var order: Int
    @NSManaged public var list: TaskList?
}

extension TaskItem {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<TaskItem> {
        return NSFetchRequest<TaskItem>(entityName: "TaskItem")
    }
}
