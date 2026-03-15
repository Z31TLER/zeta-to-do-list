import Foundation
import CoreData
import SwiftUI

@MainActor
final class TaskListViewModel: ObservableObject {
    @Published var taskLists: [TaskList] = []
    @Published var scheduledTasks: [TaskItem] = []
    
    private let modelContext = DataController.shared.mainContext
    private let notificationManager = NotificationManager.shared
    
    init() {
        fetchTaskLists()
        fetchScheduledTasks()
    }
    
    func fetchTaskLists() {
        let request = TaskList.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \TaskList.order, ascending: true)]
        
        do {
            taskLists = try modelContext.fetch(request)
        } catch {
            print("Failed to fetch task lists: \(error)")
        }
    }
    
    func fetchScheduledTasks() {
        let request = TaskItem.fetchRequest()
        request.predicate = NSPredicate(format: "scheduledDate != nil")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \TaskItem.scheduledDate, ascending: true)]
        
        do {
            scheduledTasks = try modelContext.fetch(request)
        } catch {
            print("Failed to fetch scheduled tasks: \(error)")
        }
    }
    
    func createTaskList(title: String) {
        let newList = TaskList(context: modelContext)
        newList.id = UUID()
        newList.title = title
        newList.createdAt = Date()
        newList.order = taskLists.count
        newList.tasks = NSSet()
        
        saveContext()
        fetchTaskLists()
    }
    
    func deleteTaskList(_ list: TaskList) {
        if let tasks = list.tasks as? Set<TaskItem> {
            for task in tasks {
                notificationManager.cancelNotification(for: task)
            }
        }
        modelContext.delete(list)
        saveContext()
        fetchTaskLists()
    }
    
    func updateTaskList(_ list: TaskList, title: String) {
        list.title = title
        saveContext()
        fetchTaskLists()
    }
    
    func createTask(in list: TaskList, title: String, scheduledDate: Date? = nil) {
        let newTask = TaskItem(context: modelContext)
        newTask.id = UUID()
        newTask.title = title
        newTask.isCompleted = false
        newTask.createdAt = Date()
        newTask.order = list.tasksArray.count
        newTask.list = list
        newTask.scheduledDate = scheduledDate
        
        if let date = scheduledDate {
            Task {
                await notificationManager.scheduleNotification(for: newTask)
            }
        }
        
        saveContext()
        fetchScheduledTasks()
    }
    
    func updateTask(_ task: TaskItem, title: String, scheduledDate: Date?) {
        notificationManager.cancelNotification(for: task)
        
        task.title = title
        task.scheduledDate = scheduledDate
        
        if let date = scheduledDate {
            Task {
                await notificationManager.scheduleNotification(for: task)
            }
        }
        
        saveContext()
        fetchScheduledTasks()
    }
    
    func toggleTaskCompletion(_ task: TaskItem) {
        task.isCompleted.toggle()
        saveContext()
        fetchTaskLists()
    }
    
    func deleteTask(_ task: TaskItem) {
        notificationManager.cancelNotification(for: task)
        modelContext.delete(task)
        saveContext()
        fetchTaskLists()
        fetchScheduledTasks()
    }
    
    func moveTask(from source: IndexSet, to destination: Int, in list: TaskList) {
        var tasks = list.tasksArray
        tasks.move(fromOffsets: source, toOffset: destination)
        
        for (index, task) in tasks.enumerated() {
            task.order = index
        }
        
        saveContext()
    }
    
    func getTodayTasks() -> [TaskItem] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        return taskLists.flatMap { $0.tasksArray }.filter { task in
            guard let scheduledDate = task.scheduledDate else {
                return calendar.isDateInToday(task.createdAt)
            }
            return scheduledDate >= startOfDay && scheduledDate < endOfDay
        }
    }
    
    private func saveContext() {
        DataController.shared.save()
    }
}
