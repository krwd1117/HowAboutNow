import SwiftUI
import Presentation
import Domain
import Data
import Infrastructure

struct ContentView: View {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some View {
        SplashView()
            .preferredColorScheme(.light)
            .tint(.purple)
    }
}
