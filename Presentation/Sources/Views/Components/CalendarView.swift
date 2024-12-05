import SwiftUI
import Domain

/// 캘린더 표시 뷰
public struct CalendarView: View {
    /// 선택된 날짜
    @Binding var selectedDate: Date
    /// 캘린더에 표시할 일기 배열
    let diaries: [Diary]
    /// 날짜 선택 시 호출할 함수
    let onDateSelected: (Date) -> Void
    
    /// 현재 달력의 달
    @State private var currentMonth: Date = Date()
    
    /// 초기화
    /// - Parameters:
    ///   - selectedDate: 선택된 날짜 바인딩
    ///   - diaries: 캘린더에 표시할 일기 배열
    ///   - onDateSelected: 날짜 선택 시 호출할 함수
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
    
    /// 달력 헤더 뷰
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
    
    /// 요일 헤더 뷰
    private var daysHeader: some View {
        HStack {
            ForEach(["sun", "mon", "tue", "wed", "thu", "fri", "sat"], id: \.self) { day in
                Text(LocalizedStringKey(day))
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
            }
        }
    }
    
    /// 날짜 그리드 뷰
    private var daysGrid: some View {
        let days = getDaysInMonth()
        
        return LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
            ForEach(days.indices, id: \.self) { index in
                if let day = days[index] {
                    let diariesForDay = diaries.filter { Calendar.current.isDate($0.date, inSameDayAs: day) }
                    
                    DayCell(
                        date: day,
                        isSelected: Calendar.current.isDate(day, inSameDayAs: selectedDate),
                        diaries: diariesForDay
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
    
    /// 달의 날짜 배열 계산
    private func getDaysInMonth() -> [Date?] {
        let interval = Calendar.current.dateInterval(of: .month, for: currentMonth)!
        let firstDay = interval.start
        
        // Get the first day of the week for this month
        let firstWeekday = Calendar.current.component(.weekday, from: firstDay)
        let offsetDays = firstWeekday - 1
        
        // Get the last day of the month
        let lastDay = interval.end
        let daysInMonth = Calendar.current.dateComponents([.day], from: firstDay, to: lastDay).day!
        
        var days: [Date?] = Array(repeating: nil, count: offsetDays)
        
        for day in 0..<daysInMonth {
            if let date = Calendar.current.date(byAdding: .day, value: day, to: firstDay) {
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
    
    /// 이전 달로 이동
    private func previousMonth() {
        withAnimation {
            currentMonth = Calendar.current.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
        }
    }
    
    /// 다음 달로 이동
    private func nextMonth() {
        withAnimation {
            currentMonth = Calendar.current.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
        }
    }
}

/// 날짜 표시 뷰
private struct DayCell: View {
    /// 표시할 날짜
    let date: Date
    /// 선택 여부
    let isSelected: Bool
    /// 해당 날짜의 일기들
    let diaries: [Diary]
    
    var body: some View {
        VStack(spacing: 4) {
            Text("\(Calendar.current.component(.day, from: date))")
                .font(.system(.body, design: .rounded))
                .fontWeight(Calendar.current.isDateInToday(date) ? .bold : .regular)
                .foregroundStyle(Calendar.current.isDateInToday(date) ? .pink : .primary)
            
            if !diaries.isEmpty {
                if diaries.count == 1 {
                    EmotionIcon(emotion: diaries[0].emotion)
                } else {
                    Text("\(diaries.count)")
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
