import SwiftUI

public struct SettingsView: View {
    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    
    public init() {}
    
    public var body: some View {
        List {
            Section {
                HStack {
                    Text("앱 버전")
                    Spacer()
                    Text(appVersion)
                        .foregroundStyle(.secondary)
                }
            }
            
            Section {
                Link(destination: URL(string: "mailto:krwd1117@icloud.com")!) {
                    HStack {
                        Text("문의하기")
                        Spacer()
                        Image(systemName: "envelope")
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .navigationTitle("설정")
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}
