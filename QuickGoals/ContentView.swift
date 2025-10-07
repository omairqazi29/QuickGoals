import SwiftUI

struct ContentView: View {
    @State private var goals: [Goal] = []
    @State private var showingAddGoal = false
    @State private var newGoalTitle = ""
    @State private var newGoalDate = Date()

    private let userDefaultsKey = "savedGoals"

    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color(red: 0.3, green: 0.5, blue: 0.8), Color(red: 0.5, green: 0.3, blue: 0.7)]),
                             startPoint: .topLeading,
                             endPoint: .bottomTrailing)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    if goals.isEmpty {
                        VStack(spacing: 20) {
                            Image(systemName: "target")
                                .font(.system(size: 80))
                                .foregroundColor(.white.opacity(0.7))

                            Text("No Goals Yet")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)

                            Text("Tap + to add your first goal")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        ScrollView {
                            VStack(spacing: 12) {
                                ForEach(goals) { goal in
                                    GoalCard(goal: goal, onToggle: {
                                        toggleGoal(goal)
                                    }, onDelete: {
                                        deleteGoal(goal)
                                    })
                                }
                            }
                            .padding()
                        }
                    }
                }
            }
            .navigationTitle("QuickGoals")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddGoal = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                }
            }
            .sheet(isPresented: $showingAddGoal) {
                AddGoalView(isPresented: $showingAddGoal, onAdd: { title, date in
                    addGoal(title: title, targetDate: date)
                })
            }
            .onAppear {
                loadGoals()
            }
        }
    }

    private func addGoal(title: String, targetDate: Date) {
        let goal = Goal(title: title, targetDate: targetDate)
        goals.insert(goal, at: 0)
        saveGoals()
    }

    private func toggleGoal(_ goal: Goal) {
        if let index = goals.firstIndex(where: { $0.id == goal.id }) {
            goals[index].isCompleted.toggle()
            saveGoals()
        }
    }

    private func deleteGoal(_ goal: Goal) {
        goals.removeAll { $0.id == goal.id }
        saveGoals()
    }

    private func saveGoals() {
        if let encoded = try? JSONEncoder().encode(goals) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }

    private func loadGoals() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let decoded = try? JSONDecoder().decode([Goal].self, from: data) {
            goals = decoded
        }
    }
}

struct GoalCard: View {
    let goal: Goal
    let onToggle: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 15) {
            Button(action: onToggle) {
                Image(systemName: goal.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(goal.isCompleted ? .green : .white.opacity(0.7))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(goal.title)
                    .font(.headline)
                    .foregroundColor(.white)
                    .strikethrough(goal.isCompleted)

                HStack(spacing: 5) {
                    Image(systemName: "calendar")
                        .font(.caption)
                    Text(goalDateString)
                        .font(.caption)
                }
                .foregroundColor(statusColor)
            }

            Spacer()

            if !goal.isCompleted {
                VStack(alignment: .trailing) {
                    Text("\(abs(goal.daysRemaining))")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(statusColor)
                    Text(goal.daysRemaining >= 0 ? "days left" : "days ago")
                        .font(.caption2)
                        .foregroundColor(statusColor)
                }
            }

            Button(action: onDelete) {
                Image(systemName: "trash")
                    .font(.body)
                    .foregroundColor(.white.opacity(0.6))
            }
        }
        .padding()
        .background(Color.white.opacity(goal.isCompleted ? 0.15 : 0.2))
        .cornerRadius(12)
    }

    private var goalDateString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: goal.targetDate)
    }

    private var statusColor: Color {
        if goal.isCompleted {
            return .white.opacity(0.7)
        } else if goal.isOverdue {
            return .red.opacity(0.9)
        } else if goal.daysRemaining <= 3 {
            return .orange
        } else {
            return .white.opacity(0.8)
        }
    }
}

struct AddGoalView: View {
    @Binding var isPresented: Bool
    let onAdd: (String, Date) -> Void

    @State private var title = ""
    @State private var targetDate = Date()

    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color(red: 0.3, green: 0.5, blue: 0.8), Color(red: 0.5, green: 0.3, blue: 0.7)]),
                             startPoint: .topLeading,
                             endPoint: .bottomTrailing)
                    .ignoresSafeArea()

                VStack(spacing: 25) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Goal Title")
                            .font(.headline)
                            .foregroundColor(.white)

                        TextField("Enter your goal", text: $title)
                            .padding()
                            .background(Color.white.opacity(0.9))
                            .cornerRadius(10)
                            .font(.body)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Target Date")
                            .font(.headline)
                            .foregroundColor(.white)

                        DatePicker("", selection: $targetDate, displayedComponents: .date)
                            .datePickerStyle(.graphical)
                            .padding()
                            .background(Color.white.opacity(0.9))
                            .cornerRadius(10)
                    }

                    Spacer()

                    Button(action: {
                        if !title.isEmpty {
                            onAdd(title, targetDate)
                            isPresented = false
                        }
                    }) {
                        Text("Add Goal")
                            .font(.headline)
                            .foregroundColor(Color(red: 0.3, green: 0.5, blue: 0.8))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                    }
                    .disabled(title.isEmpty)
                    .opacity(title.isEmpty ? 0.6 : 1.0)
                }
                .padding()
            }
            .navigationTitle("New Goal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                    .foregroundColor(.white)
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
