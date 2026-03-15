import SwiftUI

struct ScheduledView: View {
    @ObservedObject var viewModel: TaskListViewModel
    @State private var showingNewTaskSheet = false
    @State private var newTaskTitle = ""
    @State private var newTaskDate = Date()
    @State private var selectedListForTask: TaskList?
    
    var groupedTasks: [(Date, [TaskItem])] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: viewModel.scheduledTasks) { task -> Date in
            guard let date = task.scheduledDate else { return Date() }
            return calendar.startOfDay(for: date)
        }
        return grouped.sorted { $0.key < $1.key }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            
            Divider()
            
            if viewModel.scheduledTasks.isEmpty {
                emptyState
            } else {
                scheduledTasksList
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(nsColor: .windowBackgroundColor))
        .sheet(isPresented: $showingNewTaskSheet) {
            newTaskSheet
        }
    }
    
    private var header: some View {
        HStack {
            Text("Scheduled")
                .font(.system(size: 28, weight: .bold))
            
            Spacer()
            
            Button(action: { showingNewTaskSheet = true }) {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
            }
            .buttonStyle(.plain)
            
            Text("\(viewModel.scheduledTasks.count) tasks")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 20)
    }
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "calendar")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            Text("No scheduled tasks")
                .font(.title2)
                .foregroundColor(.secondary)
            Text("Schedule tasks from your lists to see them here")
                .font(.body)
                .foregroundColor(.secondary)
            Button("Schedule a Task") {
                showingNewTaskSheet = true
            }
            .buttonStyle(.borderedProminent)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
    
    private var scheduledTasksList: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 24) {
                ForEach(groupedTasks, id: \.0) { date, tasks in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(formattedDate(date))
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Text(tasks.count == 1 ? "1 task" : "\(tasks.count) tasks")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        VStack(spacing: 4) {
                            ForEach(tasks) { task in
                                ScheduledTaskRow(
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
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(nsColor: .controlBackgroundColor))
                        )
                    }
                    .padding(.horizontal, 24)
                }
            }
            .padding(.vertical, 16)
        }
    }
    
    private var newTaskSheet: some View {
        VStack(spacing: 20) {
            Text("New Scheduled Task")
                .font(.title2.bold())
            
            TextField("Task title", text: $newTaskTitle)
                .textFieldStyle(.roundedBorder)
                .frame(width: 300)
            
            DatePicker("Schedule for", selection: $newTaskDate, displayedComponents: [.date, .hourAndMinute])
                .labelsHidden()
            
            if viewModel.taskLists.isEmpty {
                Text("Create a list first to add tasks")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            } else {
                Picker("Add to list", selection: $selectedListForTask) {
                    Text("Select a list").tag(nil as TaskList?)
                    ForEach(viewModel.taskLists) { list in
                        Text(list.title).tag(list as TaskList?)
                    }
                }
                .labelsHidden()
                .frame(width: 300)
            }
            
            HStack {
                Button("Cancel") {
                    newTaskTitle = ""
                    newTaskDate = Date()
                    selectedListForTask = nil
                    showingNewTaskSheet = false
                }
                .keyboardShortcut(.cancelAction)
                
                Button("Create") {
                    if let list = selectedListForTask, !newTaskTitle.isEmpty {
                        viewModel.createTask(in: list, title: newTaskTitle, scheduledDate: newTaskDate)
                        newTaskTitle = ""
                        newTaskDate = Date()
                        selectedListForTask = nil
                        showingNewTaskSheet = false
                    }
                }
                .keyboardShortcut(.defaultAction)
                .disabled(newTaskTitle.isEmpty || selectedListForTask == nil)
            }
        }
        .padding(24)
        .frame(width: 400, height: 320)
    }
    
    private func formattedDate(_ date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInTomorrow(date) {
            return "Tomorrow"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return formatter.string(from: date)
        }
    }
}

struct ScheduledTaskRow: View {
    let task: TaskItem
    let onToggle: () -> Void
    let onDelete: () -> Void
    
    @State private var isHovered = false
    
    var body: some View {
        HStack(spacing: 12) {
            Button(action: onToggle) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 20))
                    .foregroundColor(task.isCompleted ? .green : .secondary)
            }
            .buttonStyle(.plain)
            
            Text(task.title)
                .font(.body)
                .strikethrough(task.isCompleted)
                .foregroundColor(task.isCompleted ? .secondary : .primary)
            
            Spacer()
            
            if let scheduledDate = task.scheduledDate {
                Text(formattedTime(scheduledDate))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            if isHovered {
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 4)
        .onHover { hovering in
            isHovered = hovering
        }
    }
    
    private func formattedTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

#Preview {
    ScheduledView(viewModel: TaskListViewModel())
        .frame(width: 500, height: 600)
}
