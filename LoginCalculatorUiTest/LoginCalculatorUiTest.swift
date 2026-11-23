//
//  LoginCalculatorUiTest.swift
//  LoginCalculatorUiTest
//
//  Created by Ariana Osuna  on 23/11/26.
//

import XCTest

final class LoginCalculatorUiTest: XCTestCase {

    // create app
    var app: XCUIApplication!

    override func setUpWithError() throws {

        // stop the test when something fails
        continueAfterFailure = false

        // every test opens the app again, so no test depends on another one
        app = XCUIApplication()
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }


    //MARK: - Test 1 - Login button disabled with short password
    func test01_loginButtonDisabledWithShortPassword() throws {

        // type a good username
        let usernameField = app.textFields["usernameField"]
        usernameField.tap()
        usernameField.typeText("admin")

        // type a password with only 2 characters
        let passwordField = app.secureTextFields["passwordField"]
        passwordField.tap()
        passwordField.typeText("12")

        // the button needs 3 or more characters in both fields
        XCTAssertFalse(app.buttons["loginButton"].isEnabled, "Login button should be disabled with a short password")
    }


    //MARK: - Test 2 - Wrong password does not show the calculator button
    func test02_wrongPasswordDoesNotShowCalculatorButton() throws {

        // correct username but wrong password
        app.textFields["usernameField"].tap()
        app.textFields["usernameField"].typeText("admin")

        app.secureTextFields["passwordField"].tap()
        app.secureTextFields["passwordField"].typeText("hello123")

        app.buttons["loginButton"].tap()

        // the error message appears
        let resultLabel = app.staticTexts["resultLabel"]
        XCTAssertTrue(resultLabel.waitForExistence(timeout: 3), "Result label should appear")
        XCTAssertEqual(resultLabel.label, "Invalid username or password.")

        // the user can not go to the calculator
        XCTAssertFalse(app.buttons["goToCalculatorButton"].exists, "Calculator button should not appear with a wrong password")
    }


    //MARK: - Test 3 - Go to the calculator and come back
    func test03_backButtonReturnsToLoginScreen() throws {

        // login and go to the calculator
        loginAndGoToCalculator()
        XCTAssertTrue(app.staticTexts["Simple Calculator"].exists, "Calculator screen should be visible")

        // press the back button of the navigation bar
        app.navigationBars.buttons.element(boundBy: 0).tap()

        // we are in the login screen again and the welcome message is still there
        XCTAssertTrue(app.buttons["loginButton"].waitForExistence(timeout: 3), "Login screen should appear again")
        XCTAssertTrue(app.staticTexts["resultLabel"].label.contains("Welcome"))
    }


    //MARK: - Test 4 - Division with decimals
    func test04_calculatorDividesWithDecimals() throws {

        loginAndGoToCalculator()

        // 7 / 2 = 3.5
        app.textFields["firstNumberField"].tap()
        app.textFields["firstNumberField"].typeText("7")

        app.textFields["secondNumberField"].tap()
        app.textFields["secondNumberField"].typeText("2")

        app.buttons["divideButton"].tap()

        // the result shows 2 decimals
        let resultLabel = app.staticTexts["calculatorResult"]
        XCTAssertTrue(resultLabel.waitForExistence(timeout: 3), "Result should appear")
        XCTAssertEqual(resultLabel.label, "Result: 3.50")
    }


    //MARK: - Test 5 - Empty field shows an error
    func test05_calculatorShowsErrorWhenFieldIsEmpty() throws {

        loginAndGoToCalculator()

        // only the first number, the second one stays empty
        app.textFields["firstNumberField"].tap()
        app.textFields["firstNumberField"].typeText("5")

        app.buttons["multiplyButton"].tap()

        // the app does not crash, it shows a message
        let resultLabel = app.staticTexts["calculatorResult"]
        XCTAssertTrue(resultLabel.waitForExistence(timeout: 3), "Error message should appear")
        XCTAssertEqual(resultLabel.label, "Result: Enter valid numbers")
    }


    //MARK: - Helper - login with the correct user and open the calculator
    private func loginAndGoToCalculator() {

        app.textFields["usernameField"].tap()
        app.textFields["usernameField"].typeText("admin")

        app.secureTextFields["passwordField"].tap()
        app.secureTextFields["passwordField"].typeText("secret123")

        app.buttons["loginButton"].tap()

        // wait for the button because it appears with an animation
        let calculatorButton = app.buttons["goToCalculatorButton"]
        XCTAssertTrue(calculatorButton.waitForExistence(timeout: 3), "Calculator button should appear after login")
        calculatorButton.tap()

        XCTAssertTrue(app.textFields["firstNumberField"].waitForExistence(timeout: 3), "Calculator screen should appear")
    }
}
