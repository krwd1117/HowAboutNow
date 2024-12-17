import SwiftUI
import Domain

public struct DiaryListView: View {
    @ObservedObject private var coordinator: DiaryCoordinator

    @StateObject private var viewModel: DiaryListViewModel
    @State private var showingListView = false

    public init(coordinator: DiaryCoordinator) {
        self.coordinator = coordinator
        self._viewModel = StateObject(
            wrappedValue: DiaryListViewModel(diContainer: coordinator.diContainer)
        )
    }

    public var body: some View {
        ZStack {
            ScrollView {
                CustomNavigationBar(
                    coordinator: coordinator,
                    title: "",
                    showBackButton: false,
                    rightButton: {
                        AnyView(ListToggleButton(
                            showingListView: $showingListView
                        ))
                    }
                )

                if !showingListView {
                    DiaryCalendarSection(viewModel: viewModel)
                    Divider().padding(.vertical)
                }

                DiaryList(coordinator: coordinator, diaries: viewModel.diaries)
            }

            FloatingActionButton(coordinator: coordinator)
        }
        .task {
            await viewModel.loadDiaries()
        }
    }
}

fileprivate struct ListToggleButton: View {
    @Binding var showingListView: Bool

    var body: some View {
        Button(
            action: {
                withAnimation {
                    showingListView.toggle()
                }
            }, label: {
                Image(systemName: showingListView ? "calendar" : "list.bullet")
            })
    }
}

// MARK: - Subviews

fileprivate struct DiaryCalendarSection: View {
    @ObservedObject var viewModel: DiaryListViewModel

    var body: some View {
        CalendarView(
            selectedDate: $viewModel.selectedDate,
            diaries: viewModel.diaries,
            onDateSelected: { date in
                withAnimation {
                    viewModel.selectedDate = date
                }
            }
        )
        .padding(.horizontal)
    }
}

//fileprivate struct DiaryContentSection: View {
//    @EnvironmentObject private var diaryCoordinator: DiaryCoordinator
//    @ObservedObject var viewModel: DiaryListViewModel
//    let showingListView: Bool
//
//    var body: some View {
//        Group {
//            let diariesToShow = showingListView ? viewModel.diaries : viewModel.filteredDiaries
//            let emptyTitle = showingListView ? LocalizedStringKey("empty_diary") : LocalizedStringKey("empty_diary_for_date")
//            let emptyDescription = showingListView ? LocalizedStringKey("write_first_diary") : LocalizedStringKey("write_diary_for_date")
//
//            if diariesToShow.isEmpty {
//                EmptyStateView(
//                    viewModel: viewModel,
//                    title: emptyTitle,
//                    description: emptyDescription,
//                    buttonTitle: LocalizedStringKey("write_new_diary")
//                ) {}
//            } else {
//                DiaryList(diaries: diariesToShow)
//                    .environmentObject(diaryCoordinator)
//            }
//        }
//    }
//}

fileprivate struct DiaryList: View {
    @ObservedObject var coordinator: DiaryCoordinator

    let diaries: [Diary]

    var body: some View {
        LazyVStack(spacing: 16) {
            ForEach(diaries) { diary in
                Button(action: {
                    coordinator.push(route: .detail(diary))
                }, label: {
                    DiaryCardView(diary: diary)
                })
            }
        }
        .padding()
    }
}
