import SwiftUI

public struct SettingsView: View {
    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    @Environment(\.colorScheme) private var colorScheme
    
    public init() {}
    
    public var body: some View {
        List {
            appInfoSection
            contactSection
            aboutSection
        }
        .navigationTitle("설정")
        .listStyle(.insetGrouped)
        .tint(.pink)
    }
    
    private var appInfoSection: some View {
        Section {
            VStack(spacing: 16) {
                Image(systemName: "heart.square.fill")
                    .font(.system(size: 60))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(.pink)
                    .symbolEffect(.bounce)
                
                VStack(spacing: 4) {
                    Text("How About Now")
                        .font(.title2.weight(.semibold))
                    
                    Text("ver \(appVersion)")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .listRowBackground(Color.clear)
        }
    }
    
    private var contactSection: some View {
        Section {
            Link(destination: URL(string: "mailto:krwd1117@icloud.com")!) {
                HStack {
                    Label {
                        Text("문의하기")
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
            Text("문의")
        }
    }
    
    private var aboutSection: some View {
        Section {
            NavigationLink {
                List {
                    Section {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("How About Now는 당신의 일상을 기록하고 감정을 이해하는데 도움을 주는 AI 일기 앱입니다.")
                            
                            Text("매일매일의 감정과 생각을 기록하면, AI가 당신의 감정 상태를 분석하고 이해하는데 도움을 줍니다.")
                            
                            Text("당신의 하루하루가 더 행복하고 의미있기를 바랍니다. 💖")
                        }
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .padding(.vertical, 8)
                    }
                    
                    Section {
                        VStack(alignment: .leading, spacing: 12) {
                            Label("개발", systemImage: "hammer.fill")
                                .font(.headline)
                            
                            Text("김정완 (Jeongwan Kim)")
                                .font(.body)
                        }
                        .padding(.vertical, 4)
                    }
                }
                .navigationTitle("앱 소개")
                .listStyle(.insetGrouped)
            } label: {
                Label {
                    Text("앱 소개")
                } icon: {
                    Image(systemName: "info.circle.fill")
                        .symbolRenderingMode(.hierarchical)
                }
            }
            
            Link(destination: URL(string: "https://www.apple.com/legal/privacy/")!) {
                HStack {
                    Label {
                        Text("개인정보 처리방침")
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
            Text("정보")
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}
