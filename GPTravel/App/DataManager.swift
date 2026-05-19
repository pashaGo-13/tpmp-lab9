// created by GPTeam
import Foundation
import CoreData

class DataManager {
    static let shared = DataManager()
    private var coreData = CoreDataManager.shared
    
    private init() {
        loadInitialData()
    }
    
    func setTestContext(_ context: NSManagedObjectContext) {
            self.coreData = CoreDataManager(inMemory: true)
            self.coreData.setTestContext(context)
        }
    
    // MARK: - Hotel Management
    func fetchHotels() -> [HotelModel] {
        let request: NSFetchRequest<Hotel> = Hotel.fetchRequest()
        
        do {
            let hotels = try coreData.context.fetch(request)
            return hotels.map { hotel in
                HotelModel(
                    name: hotel.name ?? "",
                    location: hotel.location ?? "",
                    pricePerNight: hotel.pricePerNight,
                    rating: hotel.rating,
                    imageName: hotel.imageName ?? "",
                    availableRooms: Int(hotel.availableRooms)
                )
            }
        } catch {
            print("Failed to fetch hotels: \(error)")
            return []
        }
    }
    
    func getHotel(by id: UUID) -> HotelModel? {
        let request: NSFetchRequest<Hotel> = Hotel.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
            if let hotel = try coreData.context.fetch(request).first {
                return HotelModel(
                    name: hotel.name ?? "",
                    location: hotel.location ?? "",
                    pricePerNight: hotel.pricePerNight,
                    rating: hotel.rating,
                    imageName: hotel.imageName ?? "",
                    availableRooms: Int(hotel.availableRooms)
                )
            }
        } catch {
            print("Failed to fetch hotel: \(error)")
        }
        return nil
    }
    
    // MARK: - Booking Management
    func saveBooking(_ booking: BookingModel) -> Bool {
        let bookingEntity = Booking(context: coreData.context)
        bookingEntity.id = booking.id
        bookingEntity.hotelId = booking.hotelId
        bookingEntity.checkInDate = booking.checkInDate
        bookingEntity.checkOutDate = booking.checkOutDate
        bookingEntity.guestsCount = Int16(booking.guestsCount)
        bookingEntity.totalPrice = booking.totalPrice
        bookingEntity.isConfirmed = booking.isConfirmed
        
        coreData.saveContext()
        return true
    }
    
    func updateBooking(_ booking: BookingModel) -> Bool {
        let request: NSFetchRequest<Booking> = Booking.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", booking.id as CVarArg)
        
        do {
            if let bookingEntity = try coreData.context.fetch(request).first {
                bookingEntity.isConfirmed = booking.isConfirmed
                coreData.saveContext()
                return true
            }
        } catch {
            print("Failed to update booking: \(error)")
        }
        return false
    }
    
    func fetchBookings() -> [BookingModel] {
        let request: NSFetchRequest<Booking> = Booking.fetchRequest()
        
        do {
            let bookings = try coreData.context.fetch(request)
            return bookings.map { booking in
                BookingModel(
                    hotelId: booking.hotelId ?? UUID(),
                    checkInDate: booking.checkInDate ?? Date(),
                    checkOutDate: booking.checkOutDate ?? Date(),
                    guestsCount: Int(booking.guestsCount),
                    totalPrice: booking.totalPrice,
                    isConfirmed: booking.isConfirmed
                )
            }
        } catch {
            print("Failed to fetch bookings: \(error)")
            return []
        }
    }
    
    func deleteBooking(_ bookingId: UUID) -> Bool {
        let request: NSFetchRequest<Booking> = Booking.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", bookingId as CVarArg)
        
        do {
            if let booking = try coreData.context.fetch(request).first {
                coreData.context.delete(booking)
                coreData.saveContext()
                return true
            }
        } catch {
            print("Failed to delete booking: \(error)")
        }
        return false
    }
    
    // MARK: - Transport Routes
    func saveTransportRoute(_ route: TransportRouteModel, bookingId: UUID) -> Bool {
        let routeEntity = TransportRoute(context: coreData.context)
        routeEntity.id = route.id
        routeEntity.bookingId = bookingId
        routeEntity.transportType = route.transportType.rawValue
        routeEntity.companyName = route.companyName
        routeEntity.price = route.price
        routeEntity.departureTime = route.departureTime
        routeEntity.arrivalTime = route.arrivalTime
        routeEntity.fromLocation = route.fromLocation
        routeEntity.toLocation = route.toLocation
        
        coreData.saveContext()
        return true
    }
    
    func fetchTransportRoutes(for bookingId: UUID) -> [TransportRouteModel] {
        let request: NSFetchRequest<TransportRoute> = TransportRoute.fetchRequest()
        request.predicate = NSPredicate(format: "bookingId == %@", bookingId as CVarArg)
        
        do {
            let routes = try coreData.context.fetch(request)
            return routes.compactMap { route in
                guard let transportTypeString = route.transportType,
                      let transportType = TransportType(rawValue: transportTypeString) else {
                    return nil
                }
                
                return TransportRouteModel(
                    transportType: transportType,
                    companyName: route.companyName ?? "",
                    price: route.price,
                    departureTime: route.departureTime ?? Date(),
                    arrivalTime: route.arrivalTime ?? Date(),
                    fromLocation: route.fromLocation ?? "",
                    toLocation: route.toLocation ?? ""
                )
            }
        } catch {
            print("Failed to fetch routes: \(error)")
            return []
        }
    }
    
    func deleteTransportRoutes(for bookingId: UUID) -> Bool {
        let request: NSFetchRequest<TransportRoute> = TransportRoute.fetchRequest()
        request.predicate = NSPredicate(format: "bookingId == %@", bookingId as CVarArg)
        
        do {
            let routes = try coreData.context.fetch(request)
            for route in routes {
                coreData.context.delete(route)
            }
            coreData.saveContext()
            return true
        } catch {
            print("Failed to delete transport routes: \(error)")
            return false
        }
    }
    
    // MARK: - Initial Data Loading
    private func loadInitialData() {
        let request: NSFetchRequest<Hotel> = Hotel.fetchRequest()
        do {
            let count = try coreData.context.count(for: request)
            if count > 0 {
                return
            }
        } catch {
            print("Failed to check hotels count: \(error)")
        }
        
        guard let path = Bundle.main.path(forResource: "Hotels", ofType: "plist"),
              let hotelsData = NSArray(contentsOfFile: path) as? [[String: Any]] else {
            return
        }
        
        for hotelData in hotelsData {
            let hotel = Hotel(context: coreData.context)
            hotel.id = UUID()
            hotel.name = hotelData["name"] as? String ?? ""
            hotel.location = hotelData["location"] as? String ?? ""
            hotel.pricePerNight = hotelData["pricePerNight"] as? Double ?? 0.0
            hotel.rating = hotelData["rating"] as? Double ?? 0.0
            hotel.imageName = hotelData["imageName"] as? String ?? ""
            hotel.availableRooms = hotelData["availableRooms"] as? Int16 ?? 0
        }
        
        coreData.saveContext()
        print("Initial hotels loaded successfully")
    }
}
