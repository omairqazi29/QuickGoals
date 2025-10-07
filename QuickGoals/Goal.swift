import Foundation

struct Goal: Identifiable, Codable {
    let id: UUID
    var title: String
    var targetDate: Date
    var isCompleted: Bool
    var createdDate: Date

    init(id: UUID = UUID(), title: String, targetDate: Date, isCompleted: Bool = false, createdDate: Date = Date()) {
        self.id = id
        self.title = title
        self.targetDate = targetDate
        self.isCompleted = isCompleted
        self.createdDate = createdDate
    }

    var daysRemaining: Int {
        let calendar = Calendar.current
        let now = calendar.startOfDay(for: Date())
        let target = calendar.startOfDay(for: targetDate)
        let components = calendar.dateComponents([.day], from: now, to: target)
        return components.day ?? 0
    }

    var isOverdue: Bool {
        return daysRemaining < 0 && !isCompleted
    }
}
