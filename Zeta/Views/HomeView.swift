import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: TaskListViewModel
    @State private var showingNewListSheet = false
    @State private var newListTitle = ""
    @State private var editingList: TaskList?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            
            if viewModel.taskLists.isEmpty {
                emptyState
            } else {
                taskListsScrollView
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(nsColor: .windowBackgroundColor))
        .sheet(isPresented: $showingNewListSheet) {
            newListSheet
        }
        .sheet(item: $editingList) { list in
            editListSheet(list: list)
        }
    }
    
    private var header: some View {
        HStack {
            Text("My Lists")
                .font(.system(size: 28, weight: .bold))
            
            Spacer()
            
            Button(action: { showingNewListSheet = true }) {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 20)
    }
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "list.bullet.clipboard")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            Text("No task lists yet")
                .font(.title2)
                .foregroundColor(.secondary)
            Text("Create your first list to get started")
                .font(.body)
                .foregroundColor(.secondary)
            Button("Create List") {
                showingNewListSheet = true
            }
            .buttonStyle(.borderedProminent)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
    
    private var taskListsScrollView: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(viewModel.taskLists) { list in
                    TaskListCard(
                        list: list,
                        onTap: {
                            editingList = list
                        },
                        onDelete: {
                            viewModel.deleteTaskList(list)
                        }
                    )
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
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
    }
    
    private func editListSheet(list: TaskList) -> some View {
        EditListDetailView(list: list, viewModel: viewModel)
    }
}

struct TaskListCard: View {
    let list: TaskList
    let onTap: () -> Void
    let onDelete: () -> Void
    
    @State private var isHovered = false
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(list.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    if isHovered {
                        Button(action: onDelete) {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                        .buttonStyle(.plain)
                    }
                }
                
                HStack {
                    Text("\(list.completedCount)/\(list.totalCount) completed")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("\(Int(list.progress * 100))%")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                ProgressBar(progress: list.progress)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(nsColor: .controlBackgroundColor))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            isHovered = hovering
        }
    }
}

#Preview {
    HomeView(viewModel: TaskListViewModel())
        .frame(width: 500, height: 600)
}
