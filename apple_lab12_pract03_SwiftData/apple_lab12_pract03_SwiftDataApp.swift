import SwiftData
import SwiftUI

@main
struct apple_lab12_pract03_SwiftDataApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Docente.self)
    }
}

