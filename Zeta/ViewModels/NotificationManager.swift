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
        } catch {
            print("[Zeta] Failed to request notification authorization: \(error)")
        }
    }
    
    func checkAuthorizationStatus() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        isAuthorized = settings.authorizationStatus == .authorized
    }
    
    func scheduleNotification(for task: TaskItem) async {
        guard let scheduledDate = task.scheduledDate else { return }
        
        let now = Date()
        guard scheduledDate > now else { return }
        
        if !isAuthorized {
            await requestAuthorization()
        }
        
        guard isAuthorized else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Task Reminder"
        content.body = task.title ?? "Untitled Task"
        content.sound = UNNotificationSound.default
        content.interruptionLevel = .timeSensitive
        
        let timeInterval = scheduledDate.timeIntervalSince(now)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        
        let identifier = task.id.uuidString
        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )
        
        do {
            try await UNUserNotificationCenter.current().add(request)
        } catch {
            print("[Zeta] Failed to schedule notification: \(error)")
        }
    }
    
    func cancelNotification(for task: TaskItem) {
        let identifier = task.id.uuidString
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: [identifier]
        )
    }
}
