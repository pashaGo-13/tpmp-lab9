// created by GPTeam
import SwiftUI

struct BookingView: View {
    let hotel: HotelModel
    @StateObject private var viewModel = BookingViewModel()  // ← ДОБАВИТЬ ЭТУ СТРОКУ
    @Environment(\.dismiss) var dismiss
    @State private var checkInDate = Date()
    @State private var checkOutDate = Date().addingTimeInterval(86400)
    @State private var guestsCount = 1
    @State private var showingTransportSelection = false
    @State private var savedBookingId: UUID?
    @EnvironmentObject var userManager: UserManager
    
    private var nightsCount: Int {
        Calendar.current.dateComponents([.day], from: checkInDate, to: checkOutDate).day ?? 1
    }
    
    private var totalPrice: Double {
        return Double(nightsCount) * hotel.pricePerNight
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("booking.dates".localized)) {
                    DatePicker("booking.checkin".localized,
                              selection: $checkInDate,
                              in: Date()...,
                              displayedComponents: .date)
                    
                    DatePicker("booking.checkout".localized,
                              selection: $checkOutDate,
                              in: checkInDate...,
                              displayedComponents: .date)
                }
                
                Section(header: Text("booking.guests".localized)) {
                    Stepper("\(guestsCount) \("booking.guests.count".localized)",
                           value: $guestsCount,
                           in: 1...10)
                }
                
                Section(header: Text("booking.summary".localized)) {
                    HStack {
                        Text("booking.total".localized)
                            .fontWeight(.semibold)
                        Spacer()
                        Text(String(format: "$%.2f", totalPrice))
                            .foregroundColor(.blue)
                            .fontWeight(.bold)
                    }
                }
                
                Section {
                    Button(action: confirmBooking) {
                        Text("booking.confirm".localized)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.white)
                    }
                    .listRowBackground(Color.blue)
                }
            }
            .navigationTitle("booking.title".localized)
            .navigationBarItems(trailing: Button("booking.cancel".localized) {
                dismiss()
            })
            .fullScreenCover(isPresented: $showingTransportSelection) {
                if let bookingId = savedBookingId {
                    TransportSelectionView(bookingId: bookingId)
                }
            }
        }
    }
    
    private func confirmBooking() {
        print("=== CONFIRM BOOKING ===")
        
        let booking = BookingModel(
            hotelId: hotel.id,
            checkInDate: checkInDate,
            checkOutDate: checkOutDate,
            guestsCount: guestsCount,
            totalPrice: totalPrice,
            isConfirmed: false
        )
        
        print("Booking created: \(booking.id)")
        
        let saveSuccess = DataManager.shared.saveBooking(booking)
        print("Save success: \(saveSuccess)")
        
        if saveSuccess {
            viewModel.confirmBooking(booking)
            print("isBookingConfirmed: \(viewModel.isBookingConfirmed)")
            
            if viewModel.isBookingConfirmed {
                savedBookingId = booking.id
                showingTransportSelection = true
                print("Opening transport screen for booking: \(savedBookingId!)")
            }
        }
    }
}
