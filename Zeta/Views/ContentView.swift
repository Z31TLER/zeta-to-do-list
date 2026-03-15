import SwiftUI

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

enum SidebarItem: Hashable {
    case navigation(NavigationItem)
    case list(TaskList)
}

struct ContentView: View {
    @StateObject private var viewModel = TaskListViewModel()
    @State private var selectedItem: SidebarItem? = .navigation(.today)
    @State private var columnVisibility: NavigationSplitViewVisibility = .all
    @State private var showingNewListSheet = false
    @State private var newListTitle = ""
    
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
                    NavigationLink(value: SidebarItem.navigation(item)) {
                        Label(item.rawValue, systemImage: item.icon)
                    }
                }
            }
            
            Section {
                HStack {
                    Text("Lists")
                        .font(.headline)
                    Spacer()
                    Button(action: { showingNewListSheet = true }) {
                        Image(systemName: "plus")
                    }
                    .buttonStyle(.plain)
                }
                
                ForEach(viewModel.taskLists) { list in
                    HStack {
                        Image(systemName: "list.bullet")
                        Text(list.title)
                        Spacer()
                        Text("\(list.completedCount)/\(list.totalCount)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedItem = .list(list)
                    }
                    .contextMenu {
                        Button(role: .destructive) {
                            viewModel.deleteTaskList(list)
                        } label: {
                            Label("Delete List", systemImage: "trash")
                        }
                    }
                }
            }
        }
        .listStyle(.sidebar)
        .frame(minWidth: 220)
        .sheet(isPresented: $showingNewListSheet) {
            newListSheet
        }
    }
    
    @ViewBuilder
    private var detailContent: some View {
        switch selectedItem {
        case .navigation(let item):
            switch item {
            case .today:
                TodayView(viewModel: viewModel)
            case .scheduled:
                ScheduledView(viewModel: viewModel)
            case .settings:
                SettingsView()
            }
        case .list(let list):
            TaskListView(list: list, viewModel: viewModel, onBack: {
                selectedItem = .navigation(.today)
            })
        case .none:
            TodayView(viewModel: viewModel)
        }
    }
    
    private var newListSheet: some View {
        VStack(spacing: 20) {
            Text("New List")
                .font(.title2.bold())
            
            TextField("List name", text: $newListTitle)
                .textFieldStyle(.roundedBorder)
                .frame(width: 300)
            
            HStack {
                Button("Cancel") {
                    newListTitle = ""
                    showingNewListSheet = false
                }
                .keyboardShortcut(.cancelAction)
                
                Button("Create") {
                    if !newListTitle.isEmpty {
                        viewModel.createTaskList(title: newListTitle)
                        newListTitle = ""
                        showingNewListSheet = false
                    }
                }
                .keyboardShortcut(.defaultAction)
                .disabled(newListTitle.isEmpty)
            }
        }
        .padding(24)
        .frame(width: 400, height: 200)
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
                ForEach(todayTasks, id: \.objectID) { task in
                    TaskRow(
                        task: task,
                        onToggle: {
                            self.viewModel.toggleTaskCompletion(task)
                        },
                        onDelete: {
                            self.viewModel.deleteTask(task)
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
