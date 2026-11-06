import XCTest

final class DocentesUITests: XCTestCase {
    private let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launchArguments = ["-AppleLanguages", "(en)", "-AppleLocale", "en_US"]
        app.launch()
        XCTAssertTrue(app.navigationBars["Teachers"].waitForExistence(timeout: 15))
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

    private func addTeacher(first: String, last: String, email: String, specialty: String) {
        app.buttons["Add Teacher"].tap()
        XCTAssertTrue(app.navigationBars["Add Teacher"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["Save"].isEnabled)
        fill("firstName", first)
        fill("lastName", last)
        fill("email", email)
        fill("phone", "999123456")
        fill("specialty", specialty)
        dismissKeyboard()
    }

    func testLaboratorioCRUD() {
        capture("01-inicio")
        addTeacher(first: "Jaime", last: "Gomez", email: "jaime@example.com", specialty: "Java Senior")
        XCTAssertTrue(app.buttons["Save"].isEnabled)
        capture("02-registro")
        app.buttons["Save"].tap()
        XCTAssertTrue(app.staticTexts["Jaime Gomez"].waitForExistence(timeout: 5))

        addTeacher(first: "Juan", last: "Leon", email: "juan@example.com", specialty: "IOS Developer")
        app.buttons["Save"].tap()
        XCTAssertTrue(app.staticTexts["Juan Leon"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Jaime Gomez"].exists)
        capture("03-listado")

        let search = app.textFields["Search teachers..."]
        search.tap()
        search.typeText("gOmEz")
        XCTAssertTrue(app.staticTexts["Jaime Gomez"].exists)
        XCTAssertFalse(app.staticTexts["Juan Leon"].exists)
        dismissKeyboard()
        capture("04-busqueda")
        app.buttons["Clear search"].tap()
        search.tap()
        search.typeText("nadie-en-la-lista")
        XCTAssertFalse(app.staticTexts["Jaime Gomez"].exists)
        XCTAssertFalse(app.staticTexts["Juan Leon"].exists)
        app.buttons["Clear search"].tap()
        dismissKeyboard()

        app.staticTexts["Jaime Gomez"].tap()
        XCTAssertTrue(app.navigationBars["Edit Teacher"].waitForExistence(timeout: 5))
        fill("firstName", "Cambio cancelado")
        app.buttons["Cancel"].tap()
        XCTAssertTrue(app.staticTexts["Jaime Gomez"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.staticTexts["Cambio cancelado Gomez"].exists)

        app.staticTexts["Jaime Gomez"].tap()
        fill("specialty", "SwiftUI Senior")
        dismissKeyboard()
        app.switches["Active"].tap()
        capture("05-edicion")
        app.buttons["Save"].tap()
        XCTAssertTrue(app.staticTexts["SwiftUI Senior"].waitForExistence(timeout: 5))

        app.terminate()
        app.launch()
        XCTAssertTrue(app.staticTexts["Jaime Gomez"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.staticTexts["SwiftUI Senior"].exists)
        XCTAssertTrue(app.staticTexts["Juan Leon"].exists)
        capture("06-persistencia")
        app.staticTexts["Jaime Gomez"].tap()
        XCTAssertEqual(app.textFields["email"].value as? String, "jaime@example.com")
        XCTAssertEqual(app.textFields["phone"].value as? String, "999123456")
        XCTAssertEqual(app.switches["Active"].value as? String, "0")
        app.buttons["Delete Teacher"].tap()
        capture("07-confirmacion-borrado")
        let deleteButtons = app.buttons.matching(identifier: "Delete Teacher")
        deleteButtons.element(boundBy: deleteButtons.count - 1).tap()
        XCTAssertTrue(app.navigationBars["Teachers"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.staticTexts["Jaime Gomez"].exists)
        XCTAssertTrue(app.staticTexts["Juan Leon"].exists)

        app.cells.containing(.staticText, identifier: "Juan Leon").firstMatch.swipeLeft()
        capture("08-borrado-deslizando")
        app.buttons["Delete"].tap()
        XCTAssertFalse(app.staticTexts["Juan Leon"].exists)
        app.terminate()
        app.launch()
        XCTAssertTrue(app.navigationBars["Teachers"].waitForExistence(timeout: 10))
        XCTAssertFalse(app.staticTexts["Jaime Gomez"].exists)
        XCTAssertFalse(app.staticTexts["Juan Leon"].exists)
        capture("09-lista-vacia")
    }
}
