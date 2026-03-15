import Foundation
import CoreData

final class DataController {
    static let shared = DataController()
    
    let container: NSPersistentContainer
    
    private init() {
        container = NSPersistentContainer(name: "Zeta")
        
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                fatalError("Failed to load persistent stores: \(error), \(error.userInfo)")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    var mainContext: NSManagedObjectContext {
        container.viewContext
    }
    
    func save() {
        let context = mainContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Failed to save context: \(error)")
            }
        }
    }
}
