import SwiftData
import SwiftUI

@main
struct apple_lab12_pract03_SwiftDataApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        // Comparte el almacenamiento persistente con las vistas de la aplicación.
        .modelContainer(for: Docente.self)
    }
}

