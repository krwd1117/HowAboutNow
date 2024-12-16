import SwiftUI

/// 설정 화면
public struct SettingsView: View {
    /// 앱 버전
    private let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    @Environment(\.colorScheme) private var colorScheme
    
    /// 초기화
    public init() {}
    
    public var body: some View {
        List {
            /// 앱 정보 섹션
            appInfoSection
            
            /// 연락처 섹션
            contactSection
            
            /// 정보 섹션
            aboutSection
        }
        .navigationTitle("settings")
        .listStyle(.insetGrouped)
        .tint(.pink)
    }
    
    /// 앱 정보 섹션
    private var appInfoSection: some View {
        Section {
            VStack(spacing: 16) {
                Image(systemName: "heart.square.fill")
                    .font(.system(size: 60))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(.pink)
                    .symbolEffect(.bounce)
                
                VStack(spacing: 4) {
                    Text("app_name")
                        .font(.title2.weight(.semibold))
                    
                    Text(String(format: String(localized: "version_format"), appVersion))
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .listRowBackground(Color.clear)
        }
    }
    
    /// 연락처 섹션
    private var contactSection: some View {
        Section {
            Link(destination: URL(string: "mailto:krwd1117@icloud.com")!) {
                HStack {
                    Label {
                        Text("contact_us")
                    } icon: {
                        Image(systemName: "envelope.fill")
                            .symbolRenderingMode(.hierarchical)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
            }
        } header: {
            Text("contact")
        }
    }
    
    /// 정보 섹션
    private var aboutSection: some View {
        Section {
            NavigationLink {
                List {
                    Section {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("about_app_description1")
                            
                            Text("about_app_description2")
                            
                            Text("about_app_description3")
                        }
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .padding(.vertical, 8)
                    }
                    
                    Section {
                        VStack(alignment: .leading, spacing: 12) {
                            Label("developer", systemImage: "hammer.fill")
                                .font(.headline)
                            
                            Text("developer_name")
                                .font(.body)
                        }
                        .padding(.vertical, 4)
                    }
                }
                .navigationTitle("about_app")
                .listStyle(.insetGrouped)
            } label: {
                Label {
                    Text("about_app")
                } icon: {
                    Image(systemName: "info.circle.fill")
                        .symbolRenderingMode(.hierarchical)
                }
            }
            
            Link(destination: URL(string: "https://krwd1117.tistory.com/entry/%EA%B0%9C%EC%9D%B8%EC%A0%95%EB%B3%B4-%EC%B2%98%EB%A6%AC%EB%B0%A9%EC%B9%A8")!) {
                HStack {
                    Label {
                        Text("privacy_policy")
                    } icon: {
                        Image(systemName: "hand.raised.fill")
                            .symbolRenderingMode(.hierarchical)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
            }
        } header: {
            Text("information")
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}
