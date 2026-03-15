import Foundation
import UserNotifications
import CoreData

@MainActor
final class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    @Published var isAuthorized: Bool = false
    
    private init() {}
    
    func requestAuthorization() async {
        do {
            let options: UNAuthorizationOptions = [.alert, .sound, .badge]
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: options)
            isAuthorized = granted
            UserDefaults.standard.set(granted, forKey: "notificationsEnabled")
            print("Notification authorization granted: \(granted)")
        } catch {
            print("Failed to request notification authorization: \(error)")
        }
    }
    
    func checkAuthorizationStatus() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        isAuthorized = settings.authorizationStatus == .authorized
        print("Notification authorization status: \(isAuthorized)")
    }
    
    func scheduleNotification(for task: TaskItem) async {
        guard let scheduledDate = task.scheduledDate else {
            print("No scheduled date for task: \(task.title ?? "unknown")")
            return
        }
        
        if !isAuthorized {
            print("Notifications not authorized, requesting...")
            await requestAuthorization()
        }
        
        guard isAuthorized else {
            print("Cannot schedule notification - not authorized")
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = "Task Reminder"
        content.body = task.title ?? "Untitled Task"
        content.sound = .default
        
        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: scheduledDate
        )
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        let identifier = task.id.uuidString
        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )
        
        do {
            try await UNUserNotificationCenter.current().add(request)
            print("Scheduled notification for task: \(task.title ?? "unknown") at \(scheduledDate)")
        } catch {
            print("Failed to schedule notification: \(error)")
        }
    }
    
    func cancelNotification(for task: TaskItem) {
        let identifier = task.id.uuidString
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: [identifier]
        )
        print("Cancelled notification for task: \(task.title ?? "unknown")")
    }
}
