import SwiftUI

@main
struct ZetaApp: App {
    @AppStorage("themeMode") private var themeMode = 0
    
    init() {
        Task {
            await NotificationManager.shared.checkAuthorizationStatus()
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, DataController.shared.mainContext)
                .preferredColorScheme(colorScheme)
        }
        .windowStyle(.automatic)
        .windowResizability(.contentMinSize)
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("New List") {
                    NotificationCenter.default.post(name: .newList, object: nil)
                }
                .keyboardShortcut("n", modifiers: .command)
            }
        }
    }
    
    private var colorScheme: ColorScheme? {
        switch themeMode {
        case 1: return .light
        case 2: return .dark
        default: return nil
        }
    }
}

extension Notification.Name {
    static let newList = Notification.Name("newList")
}
