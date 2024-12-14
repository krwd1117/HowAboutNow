import SwiftUI
import UIKit

/// SwiftUI View에 키보드 관련 기능을 추가하는 extension
public extension View {
    /// 키보드를 숨기는 메서드
    func dismissKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }
}
