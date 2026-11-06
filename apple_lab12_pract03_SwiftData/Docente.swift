import Foundation
import SwiftData

// @Model integra la observación de cambios y la persistencia de SwiftData.
@Model
final class Docente {
    var firstName: String
    var lastName: String
    var email: String
    var phone: String
    var birthDate: Date
    var specialty: String
    var hireDate: Date
    var isActive: Bool

    var fullName: String { "\(firstName) \(lastName)" }

    init(
        firstName: String, lastName: String, email: String, phone: String,
        birthDate: Date, specialty: String, hireDate: Date, isActive: Bool
    ) {
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.phone = phone
        self.birthDate = birthDate
        self.specialty = specialty
        self.hireDate = hireDate
        self.isActive = isActive
    }
}

