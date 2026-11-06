import Foundation
import SwiftData

@MainActor
enum DatosIniciales {
    static func cargar(en contexto: ModelContext) throws {
        let clave = "docentesInicialesV1"
        guard !UserDefaults.standard.bool(forKey: clave) else { return }

        // Se respeta una base que ya tenga registros.
        if try contexto.fetchCount(FetchDescriptor<Docente>()) == 0 {
            let calendario = Calendar(identifier: .gregorian)
            contexto.insert(Docente(
                firstName: "Bryan",
                lastName: "Pareja",
                email: "bryan.pareja@example.com",
                phone: "987654321",
                birthDate: calendario.date(from: DateComponents(year: 1990, month: 4, day: 12))!,
                specialty: "Desarrollo Web",
                hireDate: calendario.date(from: DateComponents(year: 2022, month: 3, day: 1))!,
                isActive: true
            ))
            contexto.insert(Docente(
                firstName: "Renato",
                lastName: "Usnayo",
                email: "renato.usnayo@example.com",
                phone: "912345678",
                birthDate: calendario.date(from: DateComponents(year: 1993, month: 9, day: 8))!,
                specialty: "Desarrollo iOS",
                hireDate: calendario.date(from: DateComponents(year: 2023, month: 8, day: 15))!,
                isActive: true
            ))
            try contexto.save()
        }

        // Una vez inicializada, eliminar todos los docentes deja la lista vacía.
        UserDefaults.standard.set(true, forKey: clave)
    }
}
