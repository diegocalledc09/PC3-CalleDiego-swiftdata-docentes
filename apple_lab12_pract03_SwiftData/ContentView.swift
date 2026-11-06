import SwiftData
import SwiftUI

struct ContentView: View {
    @Environment(\.modelContext) private var context
    // La consulta mantiene la lista sincronizada con los docentes guardados.
    @Query(sort: [SortDescriptor(\Docente.firstName), SortDescriptor(\Docente.lastName)])
    private var teachers: [Docente]

    @State private var search = ""
    @State private var showingAdd = false
    @State private var editingTeacher: Docente?
    @State private var showingError = false

    private var filteredTeachers: [Docente] {
        let query = search.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return teachers }
        return teachers.filter { teacher in
            [teacher.fullName, teacher.email, teacher.specialty].contains {
                $0.localizedStandardContains(query)
            }
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                searchBar
                List(filteredTeachers) { teacher in
                    Button {
                        editingTeacher = teacher
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(teacher.fullName)
                                .font(.headline)
                            Text(teacher.specialty)
                                .font(.subheadline)
                                .foregroundStyle(.blue)
                            Text(teacher.email)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .swipeActions {
                        Button("Delete", role: .destructive) {
                            context.delete(teacher)
                            do {
                                try context.save()
                            } catch {
                                context.rollback()
                                showingError = true
                            }
                        }
                    }
                }
                .listStyle(.plain)
                .scrollDismissesKeyboard(.interactively)
            }
            .navigationTitle("Teachers")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAdd = true
                    } label: {
                        Label("Add Teacher", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAdd) {
                TeacherForm()
            }
            .sheet(item: $editingTeacher) { teacher in
                TeacherForm(teacher: teacher)
            }
            .alert("Could not delete teacher", isPresented: $showingError) {
                Button("OK", role: .cancel) {}
            }
        }
    }

    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
                .accessibilityHidden(true)
            TextField("Search teachers...", text: $search)
                .textFieldStyle(.roundedBorder)
                .autocorrectionDisabled()
            if !search.isEmpty {
                Button {
                    search = ""
                } label: {
                    Label("Clear search", systemImage: "xmark.circle.fill")
                        .labelStyle(.iconOnly)
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Docente.self, inMemory: true)
}

