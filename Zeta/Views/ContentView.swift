import SwiftUI
import SwiftData

enum NavigationItem: String, CaseIterable, Identifiable {
    case today = "Today"
    case scheduled = "Scheduled"
    case settings = "Settings"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .today: return "sun.max.fill"
        case .scheduled: return "calendar"
        case .settings: return "gearshape.fill"
        }
    }
}

struct ContentView: View {
    @StateObject private var viewModel = TaskListViewModel()
    @State private var selectedItem: NavigationItem? = .today
    @State private var selectedList: TaskList?
    @State private var columnVisibility: NavigationSplitViewVisibility = .all
    
    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            sidebarContent
        } detail: {
            detailContent
        }
        .navigationSplitViewStyle(.balanced)
        .frame(minWidth: 900, minHeight: 600)
    }
    
    private var sidebarContent: some View {
        List(selection: $selectedItem) {
            Section("Views") {
                ForEach(NavigationItem.allCases) { item in
                    NavigationLink(value: item) {
                        Label(item.rawValue, systemImage: item.icon)
                    }
                }
            }
            
            Section("Lists") {
                ForEach(viewModel.taskLists) { list in
                    Button(action: { selectedList = list }) {
                        HStack {
                            Image(systemName: "list.bullet")
                            Text(list.title)
                            Spacer()
                            Text("\(list.completedCount)/\(list.totalCount)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .listStyle(.sidebar)
        .frame(minWidth: 220)
    }
    
    @ViewBuilder
    private var detailContent: some View {
        if let list = selectedList {
            TaskListView(list: list, viewModel: viewModel)
        } else {
            switch selectedItem {
            case .today:
                TodayView(viewModel: viewModel)
            case .scheduled:
                ScheduledView(viewModel: viewModel)
            case .settings:
                SettingsView()
            case .none:
                TodayView(viewModel: viewModel)
            }
        }
    }
}

struct TodayView: View {
    @ObservedObject var viewModel: TaskListViewModel
    
    var todayTasks: [TaskItem] {
        viewModel.getTodayTasks()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            
            Divider()
            
            if todayTasks.isEmpty {
                emptyState
            } else {
                tasksList
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(nsColor: .windowBackgroundColor))
    }
    
    private var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Today")
                .font(.system(size: 28, weight: .bold))
            
            HStack {
                Text(formattedDate(Date()))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("\(todayTasks.filter { $0.isCompleted }.count)/\(todayTasks.count) completed")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 20)
    }
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "sun.max")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            Text("No tasks for today")
                .font(.title2)
                .foregroundColor(.secondary)
            Text("Enjoy your free time or schedule some tasks")
                .font(.body)
                .foregroundColor(.secondary)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
    
    private var tasksList: some View {
        ScrollView {
            LazyVStack(spacing: 4) {
                ForEach(todayTasks) { task in
                    TaskRow(
                        task: task,
                        onToggle: {
                            viewModel.toggleTaskCompletion(task)
                        },
                        onDelete: {
                            viewModel.deleteTask(task)
                        }
                    )
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter.string(from: date)
    }
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext, DataController.shared.mainContext)
}
