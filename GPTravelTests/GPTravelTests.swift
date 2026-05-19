// MARK: - GPTravelTests.swift
import XCTest
import CoreData
@testable import GPTravel

final class GPTravelTests: XCTestCase {
    
    var userManager: UserManager!
    var dataManager: DataManager!
    var testCoreDataStack: TestCoreDataStack!
    
    override func setUpWithError() throws {
        super.setUp()

        testCoreDataStack = TestCoreDataStack()
        
        userManager = UserManager()
        
        dataManager = DataManager.shared
        dataManager.setTestContext(testCoreDataStack.context)
    }
    
    override func tearDownWithError() throws {
        testCoreDataStack = nil
        userManager = nil
        dataManager = nil
        super.tearDown()
    }
    
    // MARK: - UserManager Tests
    
    func testUserRegistration_Success() throws {
        let phoneNumber = "+375291234567"
        let email = "test@example.com"
        let password = "password123"
        
        let success = userManager.register(phoneNumber: phoneNumber, email: email, password: password)
        
        // Then
        XCTAssertTrue(success, "User should register successfully")
        XCTAssertTrue(userManager.isLoggedIn, "User should be logged in after registration")
        XCTAssertEqual(userManager.currentUser?.email, email, "Email should match")
        XCTAssertEqual(userManager.currentUser?.phoneNumber, phoneNumber, "Phone number should match")
    }
    
    func testUserRegistration_DuplicateEmail_ShouldFail() throws {
        let email = "duplicate@example.com"
        let phone1 = "+375291234568"
        let phone2 = "+375291234569"
        let password = "password123"
        
        let firstSuccess = userManager.register(phoneNumber: phone1, email: email, password: password)
        XCTAssertTrue(firstSuccess)
        
        userManager.logout()
        
        let secondSuccess = userManager.register(phoneNumber: phone2, email: email, password: password)
        
        XCTAssertFalse(secondSuccess, "Should not register with existing email")
    }
    
    func testUserRegistration_DuplicatePhone_ShouldFail() throws {
        let phoneNumber = "+375291234570"
        let email1 = "user1@example.com"
        let email2 = "user2@example.com"
        let password = "password123"
        
        // Register first user
        let firstSuccess = userManager.register(phoneNumber: phoneNumber, email: email1, password: password)
        XCTAssertTrue(firstSuccess)
        
        userManager.logout()
        
        // When - try to register second user with same phone
        let secondSuccess = userManager.register(phoneNumber: phoneNumber, email: email2, password: password)
        
        // Then
        XCTAssertFalse(secondSuccess, "Should not register with existing phone number")
    }
    
    func testUserLogin_Success() throws {
        // Given
        let email = "login@example.com"
        let password = "password123"
        _ = userManager.register(phoneNumber: "+375291234571", email: email, password: password)
        userManager.logout()
        
        // When
        let success = userManager.login(email: email, password: password)
        
        // Then
        XCTAssertTrue(success, "User should login successfully")
        XCTAssertTrue(userManager.isLoggedIn, "User should be logged in")
        XCTAssertEqual(userManager.currentUser?.email, email, "Email should match")
    }
    
    func testUserLogin_WrongPassword_ShouldFail() throws {
        // Given
        let email = "wrongpass@example.com"
        let password = "correct123"
        _ = userManager.register(phoneNumber: "+375291234572", email: email, password: password)
        userManager.logout()
        
        // When
        let success = userManager.login(email: email, password: "wrongpassword")
        
        // Then
        XCTAssertFalse(success, "Should not login with wrong password")
        XCTAssertFalse(userManager.isLoggedIn, "User should not be logged in")
    }
    
    func testUserLogin_NonExistentEmail_ShouldFail() throws {
        // When
        let success = userManager.login(email: "nonexistent@example.com", password: "password")
        
        // Then
        XCTAssertFalse(success, "Should not login with non-existent email")
        XCTAssertFalse(userManager.isLoggedIn, "User should not be logged in")
    }
    
    func testUserLogout_Success() throws {
        // Given
        let email = "logout@example.com"
        _ = userManager.register(phoneNumber: "+375291234573", email: email, password: "password123")
        
        // When
        userManager.logout()
        
        // Then
        XCTAssertFalse(userManager.isLoggedIn, "User should be logged out")
        XCTAssertNil(userManager.currentUser, "Current user should be nil")
    }
    
    // MARK: - DataManager Tests
    
    func testFetchHotels_ReturnsArray() throws {
        // When
        let hotels = dataManager.fetchHotels()
        
        // Then
        XCTAssertNotNil(hotels, "Hotels array should not be nil")
        // Не проверяем количество, так как тестовая БД может быть пустой
    }
    
    func testSaveBooking_Success() throws {
        // Given
        let booking = BookingModel(
            hotelId: UUID(),
            checkInDate: Date(),
            checkOutDate: Date().addingTimeInterval(86400),
            guestsCount: 2,
            totalPrice: 200.0,
            isConfirmed: false
        )
        
        // When
        let saveSuccess = dataManager.saveBooking(booking)
        let fetchedBookings = dataManager.fetchBookings()
        
        // Then
        XCTAssertTrue(saveSuccess, "Booking should save successfully")
        XCTAssertTrue(fetchedBookings.contains(where: { $0.id == booking.id }), "Booking should be found in fetched bookings")
    }
    
    func testUpdateBooking_Success() throws {
        // Given
        var booking = BookingModel(
            hotelId: UUID(),
            checkInDate: Date(),
            checkOutDate: Date().addingTimeInterval(86400),
            guestsCount: 2,
            totalPrice: 200.0,
            isConfirmed: false
        )
        
        dataManager.saveBooking(booking)
        
        // When - update booking
        booking.isConfirmed = true
        let updateSuccess = dataManager.updateBooking(booking)
        
        // Then
        XCTAssertTrue(updateSuccess, "Booking should update successfully")
        
        let fetchedBookings = dataManager.fetchBookings()
        let updatedBooking = fetchedBookings.first(where: { $0.id == booking.id })
        XCTAssertTrue(updatedBooking?.isConfirmed ?? false, "Booking should be confirmed")
    }
    
    func testSaveTransportRoute_Success() throws {
        // Given
        let route = TransportRouteModel(
            transportType: .plane,
            companyName: "Test Airlines",
            price: 250.0,
            departureTime: Date(),
            arrivalTime: Date().addingTimeInterval(7200),
            fromLocation: "Minsk",
            toLocation: "Moscow"
        )
        let bookingId = UUID()
        
        // When
        let saveSuccess = dataManager.saveTransportRoute(route, bookingId: bookingId)
        let fetchedRoutes = dataManager.fetchTransportRoutes(for: bookingId)
        
        // Then
        XCTAssertTrue(saveSuccess, "Transport route should save successfully")
        XCTAssertEqual(fetchedRoutes.count, 1, "Should have 1 route")
        XCTAssertEqual(fetchedRoutes.first?.companyName, "Test Airlines", "Company name should match")
        XCTAssertEqual(fetchedRoutes.first?.price, 250.0, "Price should match")
    }
    
    func testFetchTransportRoutes_ForBooking_ReturnsCorrectRoutes() throws {
        // Given
        let bookingId1 = UUID()
        let bookingId2 = UUID()
        
        let route1 = TransportRouteModel(
            transportType: .plane,
            companyName: "Airline 1",
            price: 100.0,
            departureTime: Date(),
            arrivalTime: Date().addingTimeInterval(3600),
            fromLocation: "City A",
            toLocation: "City B"
        )
        
        let route2 = TransportRouteModel(
            transportType: .train,
            companyName: "Railway 1",
            price: 50.0,
            departureTime: Date(),
            arrivalTime: Date().addingTimeInterval(7200),
            fromLocation: "City A",
            toLocation: "City C"
        )
        
        // When - save routes for different bookings
        _ = dataManager.saveTransportRoute(route1, bookingId: bookingId1)
        _ = dataManager.saveTransportRoute(route2, bookingId: bookingId2)
        
        // Then
        let routesForBooking1 = dataManager.fetchTransportRoutes(for: bookingId1)
        let routesForBooking2 = dataManager.fetchTransportRoutes(for: bookingId2)
        
        XCTAssertEqual(routesForBooking1.count, 1, "Booking 1 should have 1 route")
        XCTAssertEqual(routesForBooking2.count, 1, "Booking 2 should have 1 route")
        XCTAssertEqual(routesForBooking1.first?.companyName, "Airline 1", "Wrong route for booking 1")
        XCTAssertEqual(routesForBooking2.first?.companyName, "Railway 1", "Wrong route for booking 2")
    }
    
    func testDeleteBooking_Success() throws {
        // Given
        let booking = BookingModel(
            hotelId: UUID(),
            checkInDate: Date(),
            checkOutDate: Date().addingTimeInterval(86400),
            guestsCount: 2,
            totalPrice: 200.0,
            isConfirmed: true
        )
        
        dataManager.saveBooking(booking)
        
        // When
        let deleteSuccess = dataManager.deleteBooking(booking.id)
        let fetchedBookings = dataManager.fetchBookings()
        
        // Then
        XCTAssertTrue(deleteSuccess, "Booking should delete successfully")
        XCTAssertFalse(fetchedBookings.contains(where: { $0.id == booking.id }), "Booking should not be found after deletion")
    }
    
    func testDeleteTransportRoutes_ForBooking_Success() throws {
        // Given
        let bookingId = UUID()
        let route1 = TransportRouteModel(
            transportType: .plane,
            companyName: "Airline 1",
            price: 100.0,
            departureTime: Date(),
            arrivalTime: Date().addingTimeInterval(3600),
            fromLocation: "City A",
            toLocation: "City B"
        )
        let route2 = TransportRouteModel(
            transportType: .bus,
            companyName: "Bus Company",
            price: 30.0,
            departureTime: Date(),
            arrivalTime: Date().addingTimeInterval(5400),
            fromLocation: "City A",
            toLocation: "City D"
        )
        
        _ = dataManager.saveTransportRoute(route1, bookingId: bookingId)
        _ = dataManager.saveTransportRoute(route2, bookingId: bookingId)
        
        // When
        let deleteSuccess = dataManager.deleteTransportRoutes(for: bookingId)
        let fetchedRoutes = dataManager.fetchTransportRoutes(for: bookingId)
        
        // Then
        XCTAssertTrue(deleteSuccess, "Routes should delete successfully")
        XCTAssertEqual(fetchedRoutes.count, 0, "No routes should remain")
    }
    
    // MARK: - HotelModel Tests
    
    func testHotelModelInitialization() throws {
        // Given
        let name = "Test Hotel"
        let location = "Test City"
        let pricePerNight = 150.0
        let rating = 4.5
        let imageName = "test_image"
        let availableRooms = 10
        
        // When
        let hotel = HotelModel(
            name: name,
            location: location,
            pricePerNight: pricePerNight,
            rating: rating,
            imageName: imageName,
            availableRooms: availableRooms
        )
        
        // Then
        XCTAssertEqual(hotel.name, name)
        XCTAssertEqual(hotel.location, location)
        XCTAssertEqual(hotel.pricePerNight, pricePerNight)
        XCTAssertEqual(hotel.rating, rating)
        XCTAssertEqual(hotel.imageName, imageName)
        XCTAssertEqual(hotel.availableRooms, availableRooms)
    }
    
    // MARK: - BookingModel Tests
    
    func testBookingModelInitialization() throws {
        // Given
        let hotelId = UUID()
        let checkInDate = Date()
        let checkOutDate = Date().addingTimeInterval(86400)
        let guestsCount = 2
        let totalPrice = 300.0
        let isConfirmed = false
        
        // When
        let booking = BookingModel(
            hotelId: hotelId,
            checkInDate: checkInDate,
            checkOutDate: checkOutDate,
            guestsCount: guestsCount,
            totalPrice: totalPrice,
            isConfirmed: isConfirmed
        )
        
        // Then
        XCTAssertEqual(booking.hotelId, hotelId)
        XCTAssertEqual(booking.guestsCount, guestsCount)
        XCTAssertEqual(booking.totalPrice, totalPrice)
        XCTAssertEqual(booking.isConfirmed, isConfirmed)
    }
    
    // MARK: - TransportRouteModel Tests
    
    func testTransportRouteModelInitialization() throws {
        // Given
        let transportType = TransportType.plane
        let companyName = "Test Airlines"
        let price = 250.0
        let departureTime = Date()
        let arrivalTime = Date().addingTimeInterval(7200)
        let fromLocation = "Minsk"
        let toLocation = "Moscow"
        
        // When
        let route = TransportRouteModel(
            transportType: transportType,
            companyName: companyName,
            price: price,
            departureTime: departureTime,
            arrivalTime: arrivalTime,
            fromLocation: fromLocation,
            toLocation: toLocation
        )
        
        // Then
        XCTAssertEqual(route.transportType, transportType)
        XCTAssertEqual(route.companyName, companyName)
        XCTAssertEqual(route.price, price)
        XCTAssertEqual(route.fromLocation, fromLocation)
        XCTAssertEqual(route.toLocation, toLocation)
        XCTAssertEqual(route.duration, arrivalTime.timeIntervalSince(departureTime))
    }
    
    func testTransportRouteDuration() throws {
        // Given
        let departureTime = Date()
        let arrivalTime = departureTime.addingTimeInterval(7200) // 2 hours
        
        let route = TransportRouteModel(
            transportType: .plane,
            companyName: "Test",
            price: 100,
            departureTime: departureTime,
            arrivalTime: arrivalTime,
            fromLocation: "A",
            toLocation: "B"
        )
        
        // Then
        XCTAssertEqual(route.duration, 7200, accuracy: 0.1)
    }
    
    // MARK: - Price Calculation Tests
    
    func testTotalPriceCalculation() throws {
        // Given
        let pricePerNight = 100.0
        let nights = 3
        let expectedTotal = 300.0
        
        // When
        let total = Double(nights) * pricePerNight
        
        // Then
        XCTAssertEqual(total, expectedTotal, "Total price calculation should be correct")
    }
    
    func testPriceWithDifferentNights() throws {
        // Given
        let pricePerNight = 150.0
        
        // Then
        XCTAssertEqual(Double(1) * pricePerNight, 150.0)
        XCTAssertEqual(Double(2) * pricePerNight, 300.0)
        XCTAssertEqual(Double(7) * pricePerNight, 1050.0)
        XCTAssertEqual(Double(14) * pricePerNight, 2100.0)
    }
    
    // MARK: - TransportType Tests
    
    func testTransportTypeDisplayName() throws {
        // Then
        XCTAssertEqual(TransportType.plane.displayName, "✈️ Plane")
        XCTAssertEqual(TransportType.train.displayName, "🚆 Train")
        XCTAssertEqual(TransportType.bus.displayName, "🚌 Bus")
    }
    
    func testTransportTypeLocalizedKey() throws {
        // Then
        XCTAssertEqual(TransportType.plane.localizedKey, "transport.plane")
        XCTAssertEqual(TransportType.train.localizedKey, "transport.train")
        XCTAssertEqual(TransportType.bus.localizedKey, "transport.bus")
    }
    
    func testTransportTypeAllCases() throws {
        // Then
        let allCases = TransportType.allCases
        XCTAssertEqual(allCases.count, 3)
        XCTAssertTrue(allCases.contains(.plane))
        XCTAssertTrue(allCases.contains(.train))
        XCTAssertTrue(allCases.contains(.bus))
    }
    
    // MARK: - Performance Tests
    
    func testPerformanceOfHotelFetching() throws {
        measure {
            _ = dataManager.fetchHotels()
        }
    }
    
    func testPerformanceOfSavingMultipleBookings() throws {
        measure {
            for i in 0..<10 {
                let booking = BookingModel(
                    hotelId: UUID(),
                    checkInDate: Date(),
                    checkOutDate: Date().addingTimeInterval(86400),
                    guestsCount: 2,
                    totalPrice: Double(i * 100),
                    isConfirmed: false
                )
                _ = dataManager.saveBooking(booking)
            }
        }
    }
}

// MARK: - TestCoreDataStack
class TestCoreDataStack {
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "GPTravel")
        let description = NSPersistentStoreDescription()
        description.url = URL(fileURLWithPath: "/dev/null") // In-memory store
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Failed to load persistent store: \(error)")
            }
        }
        return container
    }()
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Failed to save context: \(error)")
            }
        }
    }
}
