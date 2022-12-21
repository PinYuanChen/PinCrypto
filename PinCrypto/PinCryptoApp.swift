//
// Created on 2022/12/21.
//

import SwiftUI

@main
struct PinCryptoApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationView {
                HomeView()
                    .navigationBarHidden(true)
            }
        }
    }
}
