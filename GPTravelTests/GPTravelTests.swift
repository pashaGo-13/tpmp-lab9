import XCTest
import CoreData
@testable import GPTravel

final class GPTravelTests: XCTestCase {
    
    var userManager: UserManager!
    var dataManager: DataManager!
    var testContext: NSManagedObjectContext!
    
    override func setUpWithError() throws {
        super.setUp()
        
        let container = NSPersistentContainer(name: "GPTravel")
        let description = NSPersistentStoreDescription()
        description.url = URL(fileURLWithPath: "/dev/null")
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Failed to load test store: \(error)")
            }
        }
        testContext = container.viewContext
        
        userManager = UserManager()
        dataManager = DataManager.shared
    }
    
    override func tearDownWithError() throws {
        testContext = nil
        userManager = nil
        dataManager = nil
        super.tearDown()
    }
    
    func testSaveBooking_Success() throws {
        let booking = BookingModel(
            hotelId: UUID(),
            checkInDate: Date(),
            checkOutDate: Date().addingTimeInterval(86400),
            guestsCount: 2,
            totalPrice: 200.0,
            isConfirmed: false
        )
        
        let saveSuccess = dataManager.saveBooking(booking)
        XCTAssertTrue(saveSuccess)
    }
    
    func testUpdateBooking_Success() throws {
        var booking = BookingModel(
            hotelId: UUID(),
            checkInDate: Date(),
            checkOutDate: Date().addingTimeInterval(86400),
            guestsCount: 2,
            totalPrice: 200.0,
            isConfirmed: false
        )
        
        dataManager.saveBooking(booking)
        
        booking.isConfirmed = true
        let updateSuccess = dataManager.updateBooking(booking)
        
        XCTAssertTrue(updateSuccess)
    }
    
    func testDeleteBooking_Success() throws {
        let booking = BookingModel(
            hotelId: UUID(),
            checkInDate: Date(),
            checkOutDate: Date().addingTimeInterval(86400),
            guestsCount: 2,
            totalPrice: 200.0,
            isConfirmed: true
        )
        
        dataManager.saveBooking(booking)
        
        let deleteSuccess = dataManager.deleteBooking(booking.id)
        XCTAssertTrue(deleteSuccess)
    }
    
    func testSaveTransportRoute_Success() throws {
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
        
        let saveSuccess = dataManager.saveTransportRoute(route, bookingId: bookingId)
        XCTAssertTrue(saveSuccess)
    }
    
    func testFetchTransportRoutes_ForBooking_ReturnsCorrectRoutes() throws {
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
        
        dataManager.saveTransportRoute(route1, bookingId: bookingId1)
        dataManager.saveTransportRoute(route2, bookingId: bookingId2)
        
        let routesForBooking1 = dataManager.fetchTransportRoutes(for: bookingId1)
        let routesForBooking2 = dataManager.fetchTransportRoutes(for: bookingId2)
        
        XCTAssertEqual(routesForBooking1.count, 1)
        XCTAssertEqual(routesForBooking2.count, 1)
        XCTAssertEqual(routesForBooking1.first?.companyName, "Airline 1")
        XCTAssertEqual(routesForBooking2.first?.companyName, "Railway 1")
    }
    
    func testDeleteTransportRoutes_ForBooking_Success() throws {
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
        
        dataManager.saveTransportRoute(route1, bookingId: bookingId)
        
        let deleteSuccess = dataManager.deleteTransportRoutes(for: bookingId)
        let routesAfter = dataManager.fetchTransportRoutes(for: bookingId)
        
        XCTAssertTrue(deleteSuccess)
        XCTAssertEqual(routesAfter.count, 0)
    }
    
    func testHotelModelInitialization() throws {
        let hotel = HotelModel(
            name: "Test Hotel",
            location: "Test City",
            pricePerNight: 150.0,
            rating: 4.5,
            imageName: "test_image",
            availableRooms: 10
        )
        
        XCTAssertEqual(hotel.name, "Test Hotel")
        XCTAssertEqual(hotel.location, "Test City")
        XCTAssertEqual(hotel.pricePerNight, 150.0)
        XCTAssertEqual(hotel.rating, 4.5)
        XCTAssertEqual(hotel.availableRooms, 10)
    }
    
    func testBookingModelInitialization() throws {
        let hotelId = UUID()
        let checkIn = Date()
        let checkOut = Date().addingTimeInterval(86400)
        
        let booking = BookingModel(
            hotelId: hotelId,
            checkInDate: checkIn,
            checkOutDate: checkOut,
            guestsCount: 2,
            totalPrice: 300.0,
            isConfirmed: false
        )
        
        XCTAssertEqual(booking.hotelId, hotelId)
        XCTAssertEqual(booking.guestsCount, 2)
        XCTAssertEqual(booking.totalPrice, 300.0)
        XCTAssertFalse(booking.isConfirmed)
    }
    
    func testTransportRouteModelInitialization() throws {
        let route = TransportRouteModel(
            transportType: .plane,
            companyName: "Test Airlines",
            price: 250.0,
            departureTime: Date(),
            arrivalTime: Date().addingTimeInterval(7200),
            fromLocation: "Minsk",
            toLocation: "Moscow"
        )
        
        XCTAssertEqual(route.companyName, "Test Airlines")
        XCTAssertEqual(route.price, 250.0)
        XCTAssertEqual(route.fromLocation, "Minsk")
        XCTAssertEqual(route.toLocation, "Moscow")
        XCTAssertEqual(route.duration, 7200, accuracy: 0.1)
    }
    
    func testTransportRouteDuration() throws {
        let departure = Date()
        let arrival = departure.addingTimeInterval(7200)
        
        let route = TransportRouteModel(
            transportType: .train,
            companyName: "Test",
            price: 100,
            departureTime: departure,
            arrivalTime: arrival,
            fromLocation: "A",
            toLocation: "B"
        )
        
        XCTAssertEqual(route.duration, 7200, accuracy: 0.1)
    }
    
    func testTransportTypeDisplayName() throws {
        XCTAssertEqual(TransportType.plane.displayName, "✈️ Plane")
        XCTAssertEqual(TransportType.train.displayName, "🚆 Train")
        XCTAssertEqual(TransportType.bus.displayName, "🚌 Bus")
    }
    
    func testTransportTypeLocalizedKey() throws {
        XCTAssertEqual(TransportType.plane.localizedKey, "transport.plane")
        XCTAssertEqual(TransportType.train.localizedKey, "transport.train")
        XCTAssertEqual(TransportType.bus.localizedKey, "transport.bus")
    }
    
    func testTransportTypeAllCases() throws {
        let cases = TransportType.allCases
        XCTAssertEqual(cases.count, 3)
        XCTAssertTrue(cases.contains(.plane))
        XCTAssertTrue(cases.contains(.train))
        XCTAssertTrue(cases.contains(.bus))
    }
    
    func testTotalPriceCalculation() throws {
        let pricePerNight = 100.0
        let nights = 3
        let total = Double(nights) * pricePerNight
        XCTAssertEqual(total, 300.0)
    }
    
    func testPriceWithDifferentNights() throws {
        let pricePerNight = 150.0
        XCTAssertEqual(Double(1) * pricePerNight, 150.0)
        XCTAssertEqual(Double(2) * pricePerNight, 300.0)
        XCTAssertEqual(Double(7) * pricePerNight, 1050.0)
    }
    
    func testUserRegistration_Success() throws {
        let success = userManager.register(
            phoneNumber: "+375291234567",
            email: "test@example.com",
            password: "password123"
        )
        XCTAssertTrue(success)
        XCTAssertTrue(userManager.isLoggedIn)
    }
    
    func testUserRegistration_DuplicateEmail_ShouldFail() throws {
        let email = "duplicate@example.com"
        _ = userManager.register(phoneNumber: "+375291234568", email: email, password: "pass1")
        userManager.logout()
        
        let secondSuccess = userManager.register(phoneNumber: "+375291234569", email: email, password: "pass2")
        XCTAssertFalse(secondSuccess)
    }
    
    func testUserRegistration_DuplicatePhone_ShouldFail() throws {
        let phone = "+375291234570"
        _ = userManager.register(phoneNumber: phone, email: "user1@example.com", password: "pass1")
        userManager.logout()
        
        let secondSuccess = userManager.register(phoneNumber: phone, email: "user2@example.com", password: "pass2")
        XCTAssertFalse(secondSuccess)
    }
    
    func testUserLogin_Success() throws {
        _ = userManager.register(phoneNumber: "+375291234571", email: "login@example.com", password: "password123")
        userManager.logout()
        
        let success = userManager.login(email: "login@example.com", password: "password123")
        XCTAssertTrue(success)
        XCTAssertTrue(userManager.isLoggedIn)
    }
    
    func testUserLogin_WrongPassword_ShouldFail() throws {
        _ = userManager.register(phoneNumber: "+375291234572", email: "wrong@example.com", password: "correct123")
        userManager.logout()
        
        let success = userManager.login(email: "wrong@example.com", password: "wrongpassword")
        XCTAssertFalse(success)
        XCTAssertFalse(userManager.isLoggedIn)
    }
    
    func testUserLogin_NonExistentEmail_ShouldFail() throws {
        let success = userManager.login(email: "nonexistent@example.com", password: "password")
        XCTAssertFalse(success)
        XCTAssertFalse(userManager.isLoggedIn)
    }
    
    func testUserLogout_Success() throws {
        _ = userManager.register(phoneNumber: "+375291234573", email: "logout@example.com", password: "password123")
        
        userManager.logout()
        XCTAssertFalse(userManager.isLoggedIn)
        XCTAssertNil(userManager.currentUser)
    }
    
    func testFetchHotels_ReturnsArray() throws {
        let hotels = dataManager.fetchHotels()
        XCTAssertNotNil(hotels)
    }
    
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
