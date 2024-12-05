import SwiftUI

public struct DeleteConfirmationAlert {
    let isPresented: Binding<Bool>
    let onDelete: () -> Void
    
    public init(isPresented: Binding<Bool>, onDelete: @escaping () -> Void) {
        self.isPresented = isPresented
        self.onDelete = onDelete
    }
    
    public var alert: Alert {
        Alert(
            title: Text("delete_diary"),
            message: Text("delete_diary_confirm"),
            primaryButton: .destructive(Text("delete")) {
                onDelete()
            },
            secondaryButton: .cancel(Text("cancel"))
        )
    }
}
