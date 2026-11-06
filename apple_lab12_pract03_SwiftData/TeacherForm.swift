import SwiftData
import SwiftUI

struct TeacherForm: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    private let teacher: Docente?
    // El borrador local permite cancelar sin modificar el docente persistente.
    @State private var firstName: String
    @State private var lastName: String
    @State private var email: String
    @State private var phone: String
    @State private var birthDate: Date
    @State private var specialty: String
    @State private var hireDate: Date
    @State private var isActive: Bool
    @State private var confirmingDelete = false
    @State private var showingError = false

    init(teacher: Docente? = nil) {
        self.teacher = teacher
        _firstName = State(initialValue: teacher?.firstName ?? "")
        _lastName = State(initialValue: teacher?.lastName ?? "")
        _email = State(initialValue: teacher?.email ?? "")
        _phone = State(initialValue: teacher?.phone ?? "")
        _birthDate = State(initialValue: teacher?.birthDate ?? .now)
        _specialty = State(initialValue: teacher?.specialty ?? "")
        _hireDate = State(initialValue: teacher?.hireDate ?? .now)
        _isActive = State(initialValue: teacher?.isActive ?? true)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Personal Information") {
                    TextField("First Name", text: $firstName)
                        .accessibilityIdentifier("firstName")
                        .textContentType(.givenName)
                    TextField("Last Name", text: $lastName)
                        .accessibilityIdentifier("lastName")
                        .textContentType(.familyName)
                    TextField("Email", text: $email)
                        .accessibilityIdentifier("email")
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                    TextField("Phone", text: $phone)
                        .accessibilityIdentifier("phone")
                        .textContentType(.telephoneNumber)
                        .keyboardType(.phonePad)
                    DatePicker("Date of Birth", selection: $birthDate, in: ...Date.now, displayedComponents: .date)
                }

                Section("Professional Information") {
                    TextField("Specialty", text: $specialty)
                        .accessibilityIdentifier("specialty")
                    DatePicker("Hire Date", selection: $hireDate, displayedComponents: .date)
                    Toggle("Active", isOn: $isActive)
                }

                if teacher != nil {
                    Section {
                        Button("Delete Teacher", role: .destructive) {
                            confirmingDelete = true
                        }
                    }
                }
            }
            .scrollDismissesKeyboard(.immediately)
            .navigationTitle(teacher == nil ? "Add Teacher" : "Edit Teacher")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", action: save)
                        .disabled([firstName, lastName, email, phone, specialty].contains {
                            $0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                        })
                }
            }
            .confirmationDialog("Delete this teacher?", isPresented: $confirmingDelete, titleVisibility: .visible) {
                Button("Delete Teacher", role: .destructive, action: delete)
                Button("Cancel", role: .cancel) {}
            }
            .alert("Could not save changes", isPresented: $showingError) {
                Button("OK", role: .cancel) {}
            }
        }
    }

    private func save() {
        let cleanedFirstName = firstName.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanedLastName = lastName.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanedPhone = phone.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanedSpecialty = specialty.trimmingCharacters(in: .whitespacesAndNewlines)

        if let teacher {
            teacher.firstName = cleanedFirstName
            teacher.lastName = cleanedLastName
            teacher.email = cleanedEmail
            teacher.phone = cleanedPhone
            teacher.birthDate = birthDate
            teacher.specialty = cleanedSpecialty
            teacher.hireDate = hireDate
            teacher.isActive = isActive
        } else {
            context.insert(Docente(
                firstName: cleanedFirstName, lastName: cleanedLastName,
                email: cleanedEmail, phone: cleanedPhone, birthDate: birthDate,
                specialty: cleanedSpecialty, hireDate: hireDate, isActive: isActive
            ))
        }
        saveAndDismiss()
    }

    private func delete() {
        guard let teacher else { return }
        context.delete(teacher)
        saveAndDismiss()
    }

    // Se cierra el formulario solo después de guardar correctamente.
    private func saveAndDismiss() {
        do {
            try context.save()
            dismiss()
        } catch {
            context.rollback()
            showingError = true
        }
    }
}

