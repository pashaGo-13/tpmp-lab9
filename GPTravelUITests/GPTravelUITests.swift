//
//  GPTravelUITests.swift
//  GPTravelUITests
//
//  Created by user on 18.05.26.
//
// MARK: - GPTravelUITests.swift
import XCTest

final class GPTravelUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app = nil
        super.tearDown()
    }
    
    // MARK: - Registration UI Tests
    
    func testRegistrationScreenElements() {
        let emailTextField = app.textFields["Email"]
        let phoneTextField = app.textFields["Номер телефона"]
        let passwordSecureField = app.secureTextFields["Пароль"]
        let registerButton = app.buttons["Зарегистрироваться"]
        let loginSwitchButton = app.buttons["Уже есть аккаунт? Войти"]
        
        XCTAssertTrue(emailTextField.exists)
        XCTAssertTrue(phoneTextField.exists)
        XCTAssertTrue(passwordSecureField.exists)
        XCTAssertTrue(registerButton.exists)
        XCTAssertTrue(loginSwitchButton.exists)
    }
    
    func testSuccessfulRegistration() {
        let emailTextField = app.textFields["Email"]
        let phoneTextField = app.textFields["Номер телефона"]
        let passwordSecureField = app.secureTextFields["Пароль"]
        let confirmPasswordField = app.secureTextFields["Подтвердите пароль"]
        let registerButton = app.buttons["Зарегистрироваться"]
        
        emailTextField.tap()
        emailTextField.typeText("test@example.com")
        
        phoneTextField.tap()
        phoneTextField.typeText("+375291234567")
        
        passwordSecureField.tap()
        passwordSecureField.typeText("password123")
        
        confirmPasswordField.tap()
        confirmPasswordField.typeText("password123")
        
        registerButton.tap()
        
        let mainScreen = app.tabBars.firstMatch
        XCTAssertTrue(mainScreen.waitForExistence(timeout: 5))
    }
    
    func testLoginSuccess() {
        registerUser(email: "logintest@example.com", phone: "+375299999999", password: "password123")
        
        logout()
        
        let emailTextField = app.textFields["Email"]
        let passwordSecureField = app.secureTextFields["Пароль"]
        let loginButton = app.buttons["Войти"]
        
        emailTextField.tap()
        emailTextField.typeText("logintest@example.com")
        
        passwordSecureField.tap()
        passwordSecureField.typeText("password123")
        
        loginButton.tap()
        
        let mainScreen = app.tabBars.firstMatch
        XCTAssertTrue(mainScreen.waitForExistence(timeout: 5))
    }
    
    func testLoginWithWrongPassword() {
        registerUser(email: "wrongpass@example.com", phone: "+375298888888", password: "correct123")
        
        logout()
        
        let emailTextField = app.textFields["Email"]
        let passwordSecureField = app.secureTextFields["Пароль"]
        let loginButton = app.buttons["Войти"]
        
        emailTextField.tap()
        emailTextField.typeText("wrongpass@example.com")
        
        passwordSecureField.tap()
        passwordSecureField.typeText("wrongpassword")
        
        loginButton.tap()
        
        let alert = app.alerts["Ошибка"]
        XCTAssertTrue(alert.waitForExistence(timeout: 3))
        
        alert.buttons["OK"].tap()
        
        let loginScreenExists = emailTextField.exists
        XCTAssertTrue(loginScreenExists)
    }
    
    // MARK: - Hotels UI Tests
    
    func testHotelsListExists() {
        loginAsTestUser()
        
        let hotelsTab = app.tabBars.buttons.element(boundBy: 0)
        hotelsTab.tap()
        
        let hotelCards = app.scrollViews.firstMatch
        XCTAssertTrue(hotelCards.waitForExistence(timeout: 5))
    }
    
    func testHotelBooking() {
        loginAsTestUser()
        
        let hotelsTab = app.tabBars.buttons.element(boundBy: 0)
        hotelsTab.tap()
        
        let bookButton = app.buttons["Забронировать"].firstMatch
        XCTAssertTrue(bookButton.waitForExistence(timeout: 5))
        bookButton.tap()
        
        let bookingScreen = app.navigationBars["Бронирование отеля"]
        XCTAssertTrue(bookingScreen.waitForExistence(timeout: 5))
        
        let checkInPicker = app.datePickers.firstMatch
        if checkInPicker.exists {
            checkInPicker.tap()
            // Select a date
            app.buttons["Confirm"].tap()
        }
        
        let confirmButton = app.buttons["Подтвердить"]
        if confirmButton.exists {
            confirmButton.tap()
        }
    }
    
    // MARK: - Transport UI Tests
    
    func testTransportSelection() {
        createBooking()
        
        let bookingsTab = app.tabBars.buttons.element(boundBy: 1)
        bookingsTab.tap()
        
        let firstBooking = app.cells.firstMatch
        if firstBooking.waitForExistence(timeout: 5) {
            firstBooking.tap()
        }
        
        let transportScreen = app.navigationBars["Выбор транспорта"]
        XCTAssertTrue(transportScreen.waitForExistence(timeout: 5))
        
        let planeSegment = app.buttons["✈️ Самолет"]
        let trainSegment = app.buttons["🚆 Поезд"]
        let busSegment = app.buttons["🚌 Автобус"]
        
        XCTAssertTrue(planeSegment.exists)
        XCTAssertTrue(trainSegment.exists)
        XCTAssertTrue(busSegment.exists)
    }
    
    func testRouteSelection() {
        createBooking()
        
        let bookingsTab = app.tabBars.buttons.element(boundBy: 1)
        bookingsTab.tap()
        
        let firstBooking = app.cells.firstMatch
        if firstBooking.waitForExistence(timeout: 5) {
            firstBooking.tap()
        }
        
        let transportScreen = app.navigationBars["Выбор транспорта"]
        XCTAssertTrue(transportScreen.waitForExistence(timeout: 5))
        
        let selectRouteButton = app.buttons["Выбрать рейс"].firstMatch
        if selectRouteButton.waitForExistence(timeout: 5) {
            selectRouteButton.tap()
            
            let alert = app.alerts["✅ Успешно!"]
            XCTAssertTrue(alert.waitForExistence(timeout: 3))
            
            alert.buttons["Отлично!"].tap()
        }
    }
    
    // MARK: - Profile UI Tests
    
    func testProfileScreen() {
        loginAsTestUser()
        
        let profileTab = app.tabBars.buttons.element(boundBy: 2)
        profileTab.tap()
        
        let profileScreen = app.navigationBars["Профиль"]
        XCTAssertTrue(profileScreen.waitForExistence(timeout: 5))
        
        let logoutButton = app.buttons["Выйти"]
        XCTAssertTrue(logoutButton.exists)
    }
    
    func testLogout() {
        loginAsTestUser()
        
        let profileTab = app.tabBars.buttons.element(boundBy: 2)
        profileTab.tap()
        
        let logoutButton = app.buttons["Выйти"]
        if logoutButton.exists {
            logoutButton.tap()
        }
        
        let loginScreen = app.buttons["Войти"]
        XCTAssertTrue(loginScreen.waitForExistence(timeout: 5))
    }
    
    // MARK: - Helper Methods
    
    private func registerUser(email: String, phone: String, password: String) {
        let emailTextField = app.textFields["Email"]
        let phoneTextField = app.textFields["Номер телефона"]
        let passwordSecureField = app.secureTextFields["Пароль"]
        let confirmPasswordField = app.secureTextFields["Подтвердите пароль"]
        let registerButton = app.buttons["Зарегистрироваться"]
        
        emailTextField.tap()
        emailTextField.typeText(email)
        
        phoneTextField.tap()
        phoneTextField.typeText(phone)
        
        passwordSecureField.tap()
        passwordSecureField.typeText(password)
        
        confirmPasswordField.tap()
        confirmPasswordField.typeText(password)
        
        registerButton.tap()
        
        _ = app.tabBars.firstMatch.waitForExistence(timeout: 5)
    }
    
    private func loginAsTestUser() {
        if app.tabBars.firstMatch.exists {
            return
        }
        
        let emailTextField = app.textFields["Email"]
        let passwordSecureField = app.secureTextFields["Пароль"]
        let loginButton = app.buttons["Войти"]
        
        if emailTextField.exists {
            emailTextField.tap()
            emailTextField.typeText("test@example.com")
            
            passwordSecureField.tap()
            passwordSecureField.typeText("password123")
            
            loginButton.tap()
            
            _ = app.tabBars.firstMatch.waitForExistence(timeout: 5)
        } else {
            // Register new test user
            registerUser(email: "test@example.com", phone: "+375291234573", password: "password123")
        }
    }
    
    private func logout() {
        let profileTab = app.tabBars.buttons.element(boundBy: 2)
        if profileTab.exists {
            profileTab.tap()
            
            let logoutButton = app.buttons["Выйти"]
            if logoutButton.exists {
                logoutButton.tap()
            }
        }
    }
    
    private func createBooking() {
        loginAsTestUser()
        
        let hotelsTab = app.tabBars.buttons.element(boundBy: 0)
        hotelsTab.tap()
        
        let bookButton = app.buttons["Забронировать"].firstMatch
        if bookButton.waitForExistence(timeout: 5) {
            bookButton.tap()
        }
        
        let confirmButton = app.buttons["Подтвердить"]
        if confirmButton.waitForExistence(timeout: 3) {
            confirmButton.tap()
        }
    }
}
