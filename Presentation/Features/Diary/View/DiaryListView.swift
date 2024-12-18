import SwiftUI
import Domain

public struct DiaryListView: View {
    @ObservedObject private var coordinator: DiaryCoordinator
    @StateObject private var viewModel: DiaryListViewModel

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
                            showingListView: $viewModel.showingListView
                        ))
                    }
                )

                if !viewModel.showingListView {
                    DiaryCalendarSection(viewModel: viewModel)
                    Divider().padding(.vertical)
                }

                DiaryContentSection(
                    coordinator: coordinator,
                    viewModel: viewModel
                )
            }

            FloatingActionButton(coordinator: coordinator)
        }
        .task {
            viewModel.loadDiaries()
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
                viewModel.selectedDate = date
            }
        )
        .padding(.horizontal)
    }
}

fileprivate struct DiaryContentSection: View {
    @ObservedObject var coordinator: DiaryCoordinator
    @ObservedObject var viewModel: DiaryListViewModel

    var body: some View {
        let emptyTitle = viewModel.showingListView ? LocalizedStringKey("empty_diary") : LocalizedStringKey("empty_diary_for_date")
        let emptyDescription = viewModel.showingListView ? LocalizedStringKey("write_first_diary") : LocalizedStringKey("write_diary_for_date")

        if viewModel.filteredDiaries.isEmpty {
            EmptyStateView(
                viewModel: viewModel,
                title: emptyTitle,
                description: emptyDescription,
                buttonTitle: LocalizedStringKey("write_new_diary")
            ) {}
        } else {
            DiaryList(
                coordinator: coordinator,
                viewModel: viewModel
            )
        }
    }
}

fileprivate struct DiaryList: View {
    @ObservedObject var coordinator: DiaryCoordinator
    @ObservedObject var viewModel: DiaryListViewModel

    var body: some View {
        LazyVStack(spacing: 16) {
            ForEach(viewModel.filteredDiaries) { diary in
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
