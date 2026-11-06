import XCTest

final class DocentesUITests: XCTestCase {
    private let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launchArguments = ["-AppleLanguages", "(en)", "-AppleLocale", "en_US"]
        app.launch()
        XCTAssertTrue(app.navigationBars["Teachers"].waitForExistence(timeout: 15))
        // Las pruebas manuales usan estos registros de ejemplo en el simulador.
        for name in ["Bryan Pareja", "Renato Usnayo"] {
            if app.staticTexts[name].exists {
                app.cells.containing(.staticText, identifier: name).firstMatch.swipeLeft()
                app.buttons["Delete"].tap()
            }
        }
    }

    private func capture(_ name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    private func fill(_ identifier: String, _ text: String) {
        let field = app.textFields[identifier]
        XCTAssertTrue(field.waitForExistence(timeout: 5))
        field.tap()
        let current = field.value as? String ?? ""
        if current != field.placeholderValue {
            field.typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: current.count))
        }
        field.typeText(text)
    }

    private func dismissKeyboard() {
        app.swipeDown()
    }

    private func addTeacher(first: String, last: String, email: String, phone: String, specialty: String) {
        app.buttons["Add Teacher"].tap()
        XCTAssertTrue(app.navigationBars["Add Teacher"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["Save"].isEnabled)
        fill("firstName", first)
        fill("lastName", last)
        fill("email", email)
        fill("phone", phone)
        fill("specialty", specialty)
        dismissKeyboard()
    }

    func testLaboratorioCRUD() throws {
        capture("01-inicio")
        addTeacher(first: "Bryan", last: "Pareja", email: "bryan.pareja@example.com", phone: "987654321", specialty: "Desarrollo Web")
        XCTAssertTrue(app.buttons["Save"].isEnabled)
        capture("02-registro")
        app.buttons["Save"].tap()
        XCTAssertTrue(app.staticTexts["Bryan Pareja"].waitForExistence(timeout: 5))

        addTeacher(first: "Renato", last: "Usnayo", email: "renato.usnayo@example.com", phone: "912345678", specialty: "Desarrollo iOS")
        app.buttons["Save"].tap()
        XCTAssertTrue(app.staticTexts["Renato Usnayo"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Bryan Pareja"].exists)
        capture("03-listado")

        let search = app.textFields["Search teachers..."]
        search.tap()
        search.typeText("pArEjA")
        XCTAssertTrue(app.staticTexts["Bryan Pareja"].exists)
        XCTAssertFalse(app.staticTexts["Renato Usnayo"].exists)
        dismissKeyboard()
        capture("04-busqueda")
        app.buttons["Clear search"].tap()
        search.tap()
        search.typeText("nadie-en-la-lista")
        XCTAssertFalse(app.staticTexts["Bryan Pareja"].exists)
        XCTAssertFalse(app.staticTexts["Renato Usnayo"].exists)
        app.buttons["Clear search"].tap()
        dismissKeyboard()

        app.staticTexts["Bryan Pareja"].tap()
        XCTAssertTrue(app.navigationBars["Edit Teacher"].waitForExistence(timeout: 5))
        fill("firstName", "Cambio cancelado")
        app.buttons["Cancel"].tap()
        XCTAssertTrue(app.staticTexts["Bryan Pareja"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.staticTexts["Cambio cancelado Pareja"].exists)

        app.staticTexts["Bryan Pareja"].tap()
        fill("specialty", "Arquitectura iOS")
        dismissKeyboard()
        let activeSwitch = app.switches["Active"]
        activeSwitch.coordinate(withNormalizedOffset: CGVector(dx: 0.93, dy: 0.5)).tap()
        XCTAssertEqual(activeSwitch.value as? String, "0")
        capture("05-edicion")
        app.buttons["Save"].tap()
        XCTAssertTrue(app.staticTexts["Arquitectura iOS"].waitForExistence(timeout: 5))

        app.terminate()
        app.launch()
        XCTAssertTrue(app.staticTexts["Bryan Pareja"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.staticTexts["Arquitectura iOS"].exists)
        XCTAssertTrue(app.staticTexts["Renato Usnayo"].exists)
        capture("06-persistencia")
        app.staticTexts["Bryan Pareja"].tap()
        XCTAssertEqual(app.textFields["email"].value as? String, "bryan.pareja@example.com")
        XCTAssertEqual(app.textFields["phone"].value as? String, "987654321")
        XCTAssertEqual(app.switches["Active"].value as? String, "0")
        app.buttons["Delete Teacher"].tap()
        capture("07-confirmacion-borrado")
        let confirmDelete = try XCTUnwrap(
            app.buttons.matching(identifier: "Delete Teacher").allElementsBoundByIndex.first { $0.isHittable }
        )
        confirmDelete.tap()
        XCTAssertTrue(app.navigationBars["Teachers"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.staticTexts["Bryan Pareja"].exists)
        XCTAssertTrue(app.staticTexts["Renato Usnayo"].exists)

        app.cells.containing(.staticText, identifier: "Renato Usnayo").firstMatch.swipeLeft()
        capture("08-borrado-deslizando")
        app.buttons["Delete"].tap()
        XCTAssertFalse(app.staticTexts["Renato Usnayo"].exists)
        app.terminate()
        app.launch()
        XCTAssertTrue(app.navigationBars["Teachers"].waitForExistence(timeout: 10))
        XCTAssertFalse(app.staticTexts["Bryan Pareja"].exists)
        XCTAssertFalse(app.staticTexts["Renato Usnayo"].exists)
        capture("09-lista-vacia")
    }
}
