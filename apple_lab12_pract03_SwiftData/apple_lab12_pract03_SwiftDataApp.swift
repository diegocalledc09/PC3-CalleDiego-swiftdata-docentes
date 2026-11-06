import SwiftData
import SwiftUI

@main
@MainActor
struct apple_lab12_pract03_SwiftDataApp: App {
    private let container: ModelContainer

    init() {
        do {
            let container = try ModelContainer(for: Docente.self)
            try DatosIniciales.cargar(en: container.mainContext)
            self.container = container
        } catch {
            fatalError("No se pudo preparar el almacenamiento: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(container)
    }
}
