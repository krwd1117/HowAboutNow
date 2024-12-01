import SwiftUI
import Domain

public struct CalendarView: View {
    @Binding var selectedDate: Date
    let diaries: [Diary]
    let onDateSelected: (Date) -> Void
    
    private let calendar = Calendar.current
    private let daysInWeek = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    
    @State private var currentMonth: Date = Date()
    
    public init(selectedDate: Binding<Date>, diaries: [Diary], onDateSelected: @escaping (Date) -> Void) {
        self._selectedDate = selectedDate
        self.diaries = diaries
        self.onDateSelected = onDateSelected
    }
    
    public var body: some View {
        VStack(spacing: 20) {
            monthHeader
            daysHeader
            daysGrid
        }
    }
    
    private var monthHeader: some View {
        HStack {
            Button(action: previousMonth) {
                Image(systemName: "chevron.left")
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Text(currentMonth.formatted(.dateTime.year().month()))
                .font(.title2.bold())
            
            Spacer()
            
            Button(action: nextMonth) {
                Image(systemName: "chevron.right")
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal)
    }
    
    private var daysHeader: some View {
        HStack {
            ForEach(daysInWeek, id: \.self) { day in
                Text(LocalizedStringKey(day))
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
            }
        }
    }
    
    private var daysGrid: some View {
        let days = getDaysInMonth()
        
        return LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
            ForEach(days.indices, id: \.self) { index in
                if let day = days[index] {
                    let diariesForDay = diaries.filter { Calendar.current.isDate($0.date, inSameDayAs: day) }
                    
                    DayCell(
                        date: day,
                        isSelected: calendar.isDate(day, inSameDayAs: selectedDate),
                        diaryCount: diariesForDay.count
                    )
                    .onTapGesture {
                        withAnimation {
                            selectedDate = day
                            onDateSelected(day)
                        }
                    }
                } else {
                    Color.clear
                }
            }
        }
    }
    
    private func getDaysInMonth() -> [Date?] {
        let interval = calendar.dateInterval(of: .month, for: currentMonth)!
        let firstDay = interval.start
        
        // Get the first day of the week for this month
        let firstWeekday = calendar.component(.weekday, from: firstDay)
        let offsetDays = firstWeekday - 1
        
        // Get the last day of the month
        let lastDay = interval.end
        let daysInMonth = calendar.dateComponents([.day], from: firstDay, to: lastDay).day!
        
        var days: [Date?] = Array(repeating: nil, count: offsetDays)
        
        for day in 0..<daysInMonth {
            if let date = calendar.date(byAdding: .day, value: day, to: firstDay) {
                days.append(date)
            }
        }
        
        // Fill the remaining days of the last week with nil
        let remainingDays = 7 - (days.count % 7)
        if remainingDays < 7 {
            days += Array(repeating: nil, count: remainingDays)
        }
        
        return days
    }
    
    private func previousMonth() {
        withAnimation {
            currentMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
        }
    }
    
    private func nextMonth() {
        withAnimation {
            currentMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
        }
    }
}

private struct DayCell: View {
    let date: Date
    let isSelected: Bool
    let diaryCount: Int
    
    private let calendar = Calendar.current
    
    private var isToday: Bool {
        calendar.isDateInToday(date)
    }
    
    var body: some View {
        VStack(spacing: 4) {
            Text("\(calendar.component(.day, from: date))")
                .font(.system(.body, design: .rounded))
                .fontWeight(isToday ? .bold : .regular)
                .foregroundStyle(isToday ? .pink : .primary)
            
            if diaryCount > 0 {
                Text("\(diaryCount)")
                    .font(.system(.caption, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundStyle(.pink)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background {
                        Capsule()
                            .fill(.pink.opacity(0.1))
                    }
            }
        }
        .frame(height: 50)
        .frame(maxWidth: .infinity)
        .background {
            if isSelected {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(.pink.opacity(0.1))
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay {
            if isSelected {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .strokeBorder(.pink, lineWidth: 1)
            }
        }
    }
}
