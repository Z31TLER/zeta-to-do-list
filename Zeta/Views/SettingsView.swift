import SwiftUI

struct SettingsView: View {
    @AppStorage("notificationsEnabled") private var notificationsEnabled = false
    @AppStorage("themeMode") private var themeMode = 0
    
    @StateObject private var notificationManager = NotificationManager.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            
            Divider()
            
            settingsContent
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(nsColor: .windowBackgroundColor))
    }
    
    private var header: some View {
        Text("Settings")
            .font(.system(size: 28, weight: .bold))
            .padding(.horizontal, 24)
            .padding(.vertical, 20)
    }
    
    private var settingsContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                notificationsSection
                
                Divider()
                
                appearanceSection
                
                Divider()
                
                aboutSection
            }
            .padding(24)
        }
    }
    
    private var notificationsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("Notifications", systemImage: "bell.fill")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 8) {
                Toggle("Enable Notifications", isOn: $notificationsEnabled)
                    .onChange(of: notificationsEnabled) { _ in
                        Task {
                            await notificationManager.requestAuthorization()
                        }
                    }
                
                Text("Receive reminders for scheduled tasks")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(nsColor: .controlBackgroundColor))
            )
        }
    }
    
    private var appearanceSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("Appearance", systemImage: "paintbrush.fill")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Theme")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Picker("Theme", selection: $themeMode) {
                    Text("System").tag(0)
                    Text("Light").tag(1)
                    Text("Dark").tag(2)
                }
                .pickerStyle(.segmented)
                .frame(maxWidth: 300)
                
                Text("Choose your preferred appearance")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(nsColor: .controlBackgroundColor))
            )
        }
    }
    
    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("About", systemImage: "info.circle.fill")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Zeta")
                        .font(.headline)
                    Spacer()
                    Text("Version 1.4.0")
                        .foregroundColor(.secondary)
                }
                
                Text("A minimalistic task management app for daily organization.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(nsColor: .controlBackgroundColor))
            )
        }
    }
}

#Preview {
    SettingsView()
        .frame(width: 500, height: 600)
}
