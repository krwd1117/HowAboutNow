import SwiftUI
import Domain

public struct SettingsView: View {
    public init() {}
    
    public var body: some View {
        List {
            Section {
                NavigationLink {
                    Text("계정 설정")
                } label: {
                    Label("계정", systemImage: "person.circle")
                }
                
                NavigationLink {
                    Text("알림 설정")
                } label: {
                    Label("알림", systemImage: "bell")
                }
            }
            
            Section {
                NavigationLink {
                    Text("앱 정보")
                } label: {
                    Label("앱 정보", systemImage: "info.circle")
                }
                
                Button(role: .destructive) {
                    // TODO: 로그아웃 처리
                } label: {
                    Label("로그아웃", systemImage: "rectangle.portrait.and.arrow.right")
                }
            }
        }
        .navigationTitle("설정")
    }
}
