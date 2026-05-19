// created by GPTeam
import Foundation
import SwiftUI

class BookingViewModel: ObservableObject {
    @Published var currentBooking: BookingModel?
    @Published var isBookingConfirmed = false
    @Published var transportRoutes: [TransportRouteModel] = []
    
    private let dataManager = DataManager.shared
    
    func confirmBooking(_ booking: BookingModel) {
        print("confirmBooking called with booking: \(booking.id)")
        
        var confirmedBooking = booking
        confirmedBooking.isConfirmed = true
        
        self.currentBooking = confirmedBooking
        
        if dataManager.updateBooking(confirmedBooking) {
            self.currentBooking = confirmedBooking
            self.isBookingConfirmed = true
            print("Booking confirmed, currentBooking set: \(self.currentBooking?.id ?? UUID())")
            loadTransportRoutes()
        } else {
            print("Failed to update booking")
        }
    }
    
    func loadTransportRoutes() {
        guard let booking = currentBooking else {
            print("ERROR: currentBooking is nil in loadTransportRoutes")
            return
        }
        
        print("Loading routes for booking: \(booking.id)")
        
        let loadedRoutes = dataManager.fetchTransportRoutes(for: booking.id)
        print("Loaded routes count: \(loadedRoutes.count)")
        
        if loadedRoutes.isEmpty {
            print("No routes found, generating demo routes...")
            transportRoutes = generateDemoRoutes(for: booking)
            for route in transportRoutes {
                _ = dataManager.saveTransportRoute(route, bookingId: booking.id)
            }
            print("Generated \(transportRoutes.count) routes")
        } else {
            print("Using existing \(loadedRoutes.count) routes")
            transportRoutes = loadedRoutes
        }
    }
    
    func getFilteredRoutes(for type: TransportType) -> [TransportRouteModel] {
        let filtered = transportRoutes.filter { $0.transportType == type }
        print("Filtered routes for \(type): \(filtered.count)")
        return filtered
    }
    
    private func generateDemoRoutes(for booking: BookingModel) -> [TransportRouteModel] {
        let hotel = dataManager.getHotel(by: booking.hotelId)
        let location = hotel?.location ?? "Destination"
        print("Generating routes to: \(location)")
        
        return [
            TransportRouteModel(
                transportType: .plane,
                companyName: "Belavia",
                price: 250.0,
                departureTime: Date().addingTimeInterval(86400),
                arrivalTime: Date().addingTimeInterval(93600),
                fromLocation: "Minsk (MSQ)",
                toLocation: location
            ),
            TransportRouteModel(
                transportType: .plane,
                companyName: "LOT Polish Airlines",
                price: 280.0,
                departureTime: Date().addingTimeInterval(172800),
                arrivalTime: Date().addingTimeInterval(180000),
                fromLocation: "Minsk (MSQ)",
                toLocation: location
            ),
            TransportRouteModel(
                transportType: .train,
                companyName: "Belarusian Railway",
                price: 85.0,
                departureTime: Date().addingTimeInterval(129600),
                arrivalTime: Date().addingTimeInterval(140400),
                fromLocation: "Minsk Central",
                toLocation: location
            ),
            TransportRouteModel(
                transportType: .train,
                companyName: "Russian Railways",
                price: 95.0,
                departureTime: Date().addingTimeInterval(216000),
                arrivalTime: Date().addingTimeInterval(226800),
                fromLocation: "Minsk Central",
                toLocation: location
            ),
            TransportRouteModel(
                transportType: .bus,
                companyName: "Ecolines",
                price: 45.0,
                departureTime: Date().addingTimeInterval(259200),
                arrivalTime: Date().addingTimeInterval(266400),
                fromLocation: "Minsk Bus Station",
                toLocation: location
            ),
            TransportRouteModel(
                transportType: .bus,
                companyName: "FlixBus",
                price: 55.0,
                departureTime: Date().addingTimeInterval(302400),
                arrivalTime: Date().addingTimeInterval(309600),
                fromLocation: "Minsk Bus Station",
                toLocation: location
            )
        ]
    }
}
