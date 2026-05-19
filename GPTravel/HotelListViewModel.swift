// created by GPTeam
import Foundation
import SwiftUI

class HotelListViewModel: ObservableObject {
    @Published var hotels: [HotelModel] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let dataManager = DataManager.shared
    
    init() {
        loadHotels()
    }
    
    // MARK: - Public Methods
    func loadHotels() {
        isLoading = true
        
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            
            let loadedHotels = self.dataManager.fetchHotels()
            
            DispatchQueue.main.async {
                self.hotels = loadedHotels
                self.isLoading = false
            }
        }
    }
    
    func bookHotel(hotel: HotelModel, checkIn: Date, checkOut: Date, guests: Int) -> Bool {
        let booking = BookingModel(
            hotelId: hotel.id,
            checkInDate: checkIn,
            checkOutDate: checkOut,
            guestsCount: guests,
            totalPrice: calculateTotalPrice(hotel: hotel, checkIn: checkIn, checkOut: checkOut),
            isConfirmed: false
        )
        
        return dataManager.saveBooking(booking)
    }
    
    // MARK: - Private Methods
    private func calculateTotalPrice(hotel: HotelModel, checkIn: Date, checkOut: Date) -> Double {
        let nights = Calendar.current.dateComponents([.day], from: checkIn, to: checkOut).day ?? 1
        return Double(nights) * hotel.pricePerNight
    }
}
