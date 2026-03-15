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
            print("[Zeta] Notification authorization granted: \(granted)")
        } catch {
            print("[Zeta] Failed to request notification authorization: \(error)")
        }
    }
    
    func checkAuthorizationStatus() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        isAuthorized = settings.authorizationStatus == .authorized
        print("[Zeta] Notification authorization status: \(isAuthorized)")
    }
    
    func scheduleNotification(for task: TaskItem) async {
        guard let scheduledDate = task.scheduledDate else {
            print("[Zeta] No scheduled date for task: \(task.title ?? "unknown")")
            return
        }
        
        let now = Date()
        guard scheduledDate > now else {
            print("[Zeta] Scheduled date is in the past: \(scheduledDate), now: \(now)")
            return
        }
        
        if !isAuthorized {
            print("[Zeta] Notifications not authorized, requesting...")
            await requestAuthorization()
        }
        
        guard isAuthorized else {
            print("[Zeta] Cannot schedule notification - not authorized")
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = "Task Reminder"
        content.body = task.title ?? "Untitled Task"
        content.sound = UNNotificationSound.default
        content.interruptionLevel = .timeSensitive
        
        let timeInterval = scheduledDate.timeIntervalSince(now)
        print("[Zeta] Scheduling notification in \(timeInterval) seconds for task: \(task.title ?? "unknown")")
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        
        let identifier = task.id.uuidString
        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )
        
        do {
            try await UNUserNotificationCenter.current().add(request)
            print("[Zeta] Successfully scheduled notification for: \(task.title ?? "unknown") at \(scheduledDate)")
            
            printPendingNotifications()
        } catch {
            print("[Zeta] Failed to schedule notification: \(error)")
        }
    }
    
    func sendTestNotification() async {
        if !isAuthorized {
            await requestAuthorization()
        }
        
        guard isAuthorized else {
            print("[Zeta] Cannot send test notification - not authorized")
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = "Test Notification"
        content.body = "If you see this, notifications are working!"
        content.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "test-notification",
            content: content,
            trigger: trigger
        )
        
        do {
            try await UNUserNotificationCenter.current().add(request)
            print("[Zeta] Test notification scheduled - check in 3 seconds")
        } catch {
            print("[Zeta] Failed to send test notification: \(error)")
        }
    }
    
    func cancelNotification(for task: TaskItem) {
        let identifier = task.id.uuidString
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: [identifier]
        )
        print("[Zeta] Cancelled notification for task: \(task.title ?? "unknown")")
    }
    
    private func printPendingNotifications() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            print("[Zeta] Pending notifications count: \(requests.count)")
            for request in requests {
                print("[Zeta] - \(request.identifier): \(request.content.body)")
            }
        }
    }
}
