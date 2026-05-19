// created by GPTeam
import Foundation

struct HotelModel: Identifiable {
    let id = UUID()
    let name: String
    let location: String
    let pricePerNight: Double
    let rating: Double
    let imageName: String
    let availableRooms: Int
    
    init(name: String, location: String, pricePerNight: Double, rating: Double, imageName: String, availableRooms: Int) {
        self.name = name
        self.location = location
        self.pricePerNight = pricePerNight
        self.rating = rating
        self.imageName = imageName
        self.availableRooms = availableRooms
    }
}

struct BookingModel: Identifiable {
    let id = UUID()
    let hotelId: UUID
    let checkInDate: Date
    let checkOutDate: Date
    let guestsCount: Int
    var totalPrice: Double
    var isConfirmed: Bool
    
    init(hotelId: UUID, checkInDate: Date, checkOutDate: Date, guestsCount: Int, totalPrice: Double, isConfirmed: Bool) {
        self.hotelId = hotelId
        self.checkInDate = checkInDate
        self.checkOutDate = checkOutDate
        self.guestsCount = guestsCount
        self.totalPrice = totalPrice
        self.isConfirmed = isConfirmed
    }
}

struct TransportRouteModel: Identifiable {
    let id = UUID()
    let transportType: TransportType
    let companyName: String
    let price: Double
    let departureTime: Date
    let arrivalTime: Date
    let fromLocation: String
    let toLocation: String
    
    init(transportType: TransportType, companyName: String, price: Double,
         departureTime: Date, arrivalTime: Date, fromLocation: String, toLocation: String) {
        self.transportType = transportType
        self.companyName = companyName
        self.price = price
        self.departureTime = departureTime
        self.arrivalTime = arrivalTime
        self.fromLocation = fromLocation
        self.toLocation = toLocation
    }
    
    var duration: TimeInterval {
        arrivalTime.timeIntervalSince(departureTime)
    }
}

enum TransportType: String, CaseIterable {
    case plane = "plane"
    case train = "train"
    case bus = "bus"
    
    var displayName: String {
        switch self {
        case .plane: return "✈️ Plane"
        case .train: return "🚆 Train"
        case .bus: return "🚌 Bus"
        }
    }
    
    var localizedKey: String {
        switch self {
        case .plane: return "transport.plane"
        case .train: return "transport.train"
        case .bus: return "transport.bus"
        }
    }
}
