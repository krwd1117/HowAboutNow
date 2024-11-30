import SwiftUI
import Core

public struct DiaryListView: View {
    @State private var viewModel: DiaryListViewModel
    
    public init(viewModel: DiaryListViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        List(viewModel.diaries) { diary in
            VStack(alignment: .leading) {
                Text(diary.content)
                    .font(.body)
                Text(diary.emotion)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .onAppear {
            viewModel.fetchDiaries()
        }
    }
}
