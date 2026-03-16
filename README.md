# Zeta

A minimalistic task management application for macOS designed to help you stay organized and productive.

![macOS](https://img.shields.io/badge/macOS-13.0+-brightgreen)
![Swift](https://img.shields.io/badge/Swift-5.9-blue)
![SwiftUI](https://img.shields.io/badge/SwiftUI-4.0-orange)

## Description

Zeta is a clean, focused task management app that helps you organize your daily tasks into customizable lists. With support for scheduling, progress tracking, and notifications, Zeta provides a distraction-free environment to manage your workload effectively.

## Features

### Core Functionality
- **Task Lists** – Create multiple categorized task lists to organize different areas of your life
- **Task Management** – Add, edit, complete, and delete tasks within each list
- **Progress Tracking** – Visual progress bars show completion percentage for each list
- **Task Scheduling** – Schedule tasks for specific dates and times

### Views & Navigation
- **Home View** – Overview of all your task lists with progress indicators
- **List Detail View** – View and manage tasks within a specific list
- **Scheduled View** – See all tasks scheduled for future dates grouped by day
- **Settings View** – Customize app preferences

### Customization
- **Theme Support** – Choose between System, Light, or Dark mode
- **Accent Colors** – Select your preferred accent color (Blue, Green, Red, Purple, Orange, Yellow, Gray)
- **Notifications** – Enable reminder notifications for scheduled tasks

### Data
- **Persistent Storage** – Tasks are stored locally using Core Data
- **Offline First** – Works entirely offline with no internet required

## Requirements

| Requirement | Version |
|-------------|---------|
| macOS | 13.0 (Ventura) or later |
| Xcode | 15.0 or later |
| Swift | 5.9 |

## Installation

### Pre-built Application

1. Download the latest release (`.dmg` file) from the [Releases](https://github.com/Z31TLER/zeta-to-do-list/releases) page
2. Open the downloaded `.dmg` file
3. Drag **Zeta.app** to your Applications folder
4. Launch Zeta from your Applications folder or Spotlight

### Building from Source

1. Clone the repository:
   ```bash
   git clone https://github.com/Z31TLER/zeta-to-do-list.git
   cd zeta
   ```

2. Open the project in Xcode:
   ```bash
   open Zeta.xcodeproj
   ```

3. Select the **Zeta** scheme and click **Run** (or press `Cmd + R`)

4. Alternatively, build from command line using XcodeGen:
   ```bash
   xcodegen generate
   xcodebuild -scheme Zeta -configuration Release build
   ```

## Usage

### Creating Your First List

1. Launch Zeta
2. Click the **+** button in the top-right corner
3. Enter a name for your list (e.g., "Work Tasks", "Shopping", "Personal Goals")
4. Click **Create**

### Adding Tasks

1. Open a list by clicking on it
2. Type your task in the text field at the bottom
3. Press `Enter` or click the **+** button
4. To schedule a task, click the calendar icon before adding

### Managing Tasks

- **Complete a task** – Click the circle next to the task
- **Edit a task** – Double-click on the task
- **Delete a task** – Hover over the task and click the trash icon

### Scheduling Tasks

1. In the task input field, click the calendar icon
2. Select a date and time using the date picker
3. Add your task – it will appear in the **Scheduled** view
4. View all scheduled tasks in the **Scheduled** tab

### Customizing Settings

Click the **Settings** tab to access:
- Toggle notification reminders
- Choose theme (System/Light/Dark)
- Select accent color

## Project Structure

```
Zeta/
├── App/
│   └── ZetaApp.swift           # Main app entry point
├── Models/
│   ├── Task.swift              # TaskItem Core Data model
│   └── TaskList.swift          # TaskList Core Data model
├── Views/
│   ├── ContentView.swift       # Main tab navigation
│   ├── HomeView.swift          # Lists overview
│   ├── TaskListView.swift      # Individual list view
│   ├── ScheduledView.swift     # Scheduled tasks view
│   └── SettingsView.swift      # App settings
├── ViewModels/
│   └── TaskListViewModel.swift # Business logic
├── Components/
│   ├── TaskRow.swift           # Task list item
│   └── ProgressBar.swift       # Progress indicator
├── Persistence/
│   └── DataController.swift   # Core Data stack
└── Resources/
    └── Assets.xcassets        # App icons and images
```

## Technology Stack

- **UI Framework**: SwiftUI
- **Persistence**: Core Data
- **Architecture**: MVVM (Model-View-ViewModel)
- **Target**: macOS 13.0+

## Acknowledgements

- Built with SwiftUI and Core Data
- Inspired by minimalistic task management design patterns

## License

MIT License

Copyright (c) 2025 Zeta

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

---

Made with ❤️ for macOS
