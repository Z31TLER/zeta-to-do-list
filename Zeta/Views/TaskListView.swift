import SwiftUI

struct TaskListView: View {
    let list: TaskList
    @ObservedObject var viewModel: TaskListViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var newTaskTitle = ""
    @State private var newTaskScheduledDate: Date?
    @State private var showingDatePicker = false
    @State private var editingTask: TaskItem?
    
    var sortedTasks: [TaskItem] {
        list.tasksArray
    }
    
    var body: some View {
        VStack(spacing: 0) {
            header
            
            Divider()
            
            if sortedTasks.isEmpty {
                emptyState
            } else {
                tasksList
            }
            
            Divider()
            
            addTaskBar
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(nsColor: .windowBackgroundColor))
    }
    
    private var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.title3)
                }
                .buttonStyle(.plain)
                
                Spacer()
            }
            
            Text(list.title)
                .font(.system(size: 28, weight: .bold))
            
            HStack {
                Text("\(list.completedCount) of \(list.totalCount) tasks completed")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("\(Int(list.progress * 100))%")
                    .font(.subheadline.bold())
                    .foregroundColor(progressColor)
            }
            
            ProgressBar(progress: list.progress)
        }
        .padding(24)
    }
    
    private var progressColor: Color {
        if list.progress >= 1.0 { return .green }
        else if list.progress >= 0.5 { return .orange }
        else { return .blue }
    }
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "checklist")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            Text("No tasks yet")
                .font(.title3)
                .foregroundColor(.secondary)
            Text("Add your first task below")
                .font(.body)
                .foregroundColor(.secondary)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
    
    private var tasksList: some View {
        ScrollView {
            LazyVStack(spacing: 4) {
                ForEach(sortedTasks) { task in
                    TaskRow(
                        task: task,
                        onToggle: {
                            viewModel.toggleTaskCompletion(task)
                        },
                        onDelete: {
                            viewModel.deleteTask(task)
                        }
                    )
                    .onTapGesture(count: 2) {
                        editingTask = task
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
    }
    
    private var addTaskBar: some View {
        VStack(spacing: 12) {
            if showingDatePicker {
                DatePicker(
                    "Schedule",
                    selection: Binding(
                        get: { newTaskScheduledDate ?? Date() },
                        set: { newTaskScheduledDate = $0 }
                    ),
                    displayedComponents: [.date, .hourAndMinute]
                )
                .datePickerStyle(.graphical)
                .labelsHidden()
                .frame(height: 200)
            }
            
            HStack(spacing: 12) {
                Button(action: { showingDatePicker.toggle() }) {
                    Image(systemName: showingDatePicker ? "calendar.badge.minus" : "calendar.badge.plus")
                        .font(.title3)
                        .foregroundColor(showingDatePicker ? .blue : .secondary)
                }
                .buttonStyle(.plain)
                
                TextField("Add a new task...", text: $newTaskTitle)
                    .textFieldStyle(.plain)
                    .onSubmit {
                        addTask()
                    }
                
                Button(action: addTask) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
                .buttonStyle(.plain)
                .disabled(newTaskTitle.isEmpty)
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(nsColor: .controlBackgroundColor))
            )
        }
        .padding(16)
    }
    
    private func addTask() {
        guard !newTaskTitle.isEmpty else { return }
        viewModel.createTask(
            in: list,
            title: newTaskTitle,
            scheduledDate: newTaskScheduledDate
        )
        newTaskTitle = ""
        newTaskScheduledDate = nil
        showingDatePicker = false
    }
}

struct EditListDetailView: View {
    let list: TaskList
    @ObservedObject var viewModel: TaskListViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var editedTitle: String
    
    init(list: TaskList, viewModel: TaskListViewModel) {
        self.list = list
        self.viewModel = viewModel
        _editedTitle = State(initialValue: list.title)
    }
    
    var sortedTasks: [TaskItem] {
        list.tasksArray
    }
    
    var body: some View {
        VStack(spacing: 0) {
            header
            
            Divider()
            
            if sortedTasks.isEmpty {
                emptyState
            } else {
                tasksList
            }
            
            Divider()
            
            addTaskBar
        }
        .frame(width: 500, height: 600)
    }
    
    private var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                
                Spacer()
                
                Text("Edit List")
                    .font(.headline)
                
                Spacer()
                
                Button("Done") {
                    viewModel.updateTaskList(list, title: editedTitle)
                    dismiss()
                }
                .disabled(editedTitle.isEmpty)
            }
            
            TextField("List name", text: $editedTitle)
                .textFieldStyle(.roundedBorder)
                .font(.title2)
        }
        .padding(16)
    }
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "checklist")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            Text("No tasks yet")
                .font(.title3)
                .foregroundColor(.secondary)
            Spacer()
        }
    }
    
    private var tasksList: some View {
        List {
            ForEach(sortedTasks) { task in
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
        .listStyle(.plain)
    }
    
    private var addTaskBar: some View {
        HStack(spacing: 12) {
            TextField("Add a new task...", text: .init(
                get: { "" },
                set: { newValue in
                    if !newValue.isEmpty {
                        viewModel.createTask(in: list, title: newValue)
                    }
                }
            ))
            .textFieldStyle(.plain)
            
            Button(action: {}) {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
            }
            .buttonStyle(.plain)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(nsColor: .controlBackgroundColor))
        )
        .padding(16)
    }
}

struct EditTaskView: View {
    let task: TaskItem
    @ObservedObject var viewModel: TaskListViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var editedTitle: String
    @State private var editedScheduledDate: Date?
    @State private var hasDate: Bool
    
    init(task: TaskItem, viewModel: TaskListViewModel) {
        self.task = task
        self.viewModel = viewModel
        _editedTitle = State(initialValue: task.title)
        _editedScheduledDate = State(initialValue: task.scheduledDate)
        _hasDate = State(initialValue: task.scheduledDate != nil)
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Edit Task")
                .font(.title2.bold())
            
            TextField("Task title", text: $editedTitle)
                .textFieldStyle(.roundedBorder)
                .frame(width: 300)
            
            Toggle("Schedule for later", isOn: $hasDate)
                .onChange(of: hasDate) { newValue in
                    if newValue {
                        editedScheduledDate = Date()
                    } else {
                        editedScheduledDate = nil
                    }
                }
            
            if hasDate {
                DatePicker(
                    "Date",
                    selection: Binding(
                        get: { editedScheduledDate ?? Date() },
                        set: { editedScheduledDate = $0 }
                    ),
                    displayedComponents: [.date, .hourAndMinute]
                )
            }
            
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)
                
                Button("Save") {
                    viewModel.updateTask(
                        task,
                        title: editedTitle,
                        scheduledDate: editedScheduledDate
                    )
                    dismiss()
                }
                .keyboardShortcut(.defaultAction)
                .disabled(editedTitle.isEmpty)
            }
        }
        .padding(24)
    }
}

#Preview {
    let context = DataController.shared.mainContext
    let list = TaskList(context: context)
    list.id = UUID()
    list.title = "Sample List"
    list.createdAt = Date()
    list.order = 0
    
    return TaskListView(list: list, viewModel: TaskListViewModel())
        .environment(\.managedObjectContext, context)
        .frame(width: 500, height: 600)
}
