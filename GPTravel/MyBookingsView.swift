// created by GPTeam
import SwiftUI

struct MyBookingsView: View {
    @State private var bookings: [BookingModel] = []
    @State private var selectedBookingId: UUID?
    @State private var showingTransportSelection = false
    private let dataManager = DataManager.shared
    
    var body: some View {
        NavigationView {
            Group {
                if bookings.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "bookmark.slash")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("bookings.empty".localized)
                            .font(.headline)
                            .foregroundColor(.gray)
                    }
                } else {
                    List(bookings) { booking in
                        BookingRowView(booking: booking)
                            .onTapGesture {
                                if booking.isConfirmed {
                                    selectedBookingId = booking.id
                                    showingTransportSelection = true
                                }
                            }
                    }
                }
            }
            .navigationTitle("bookings.title".localized)
        }
        .onAppear {
            loadBookings()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("BookingConfirmed"))) { _ in
            loadBookings()
        }
        .sheet(isPresented: $showingTransportSelection) {
            if let bookingId = selectedBookingId {
                TransportSelectionView(bookingId: bookingId)
            }
        }
    }
    
    private func loadBookings() {
        bookings = dataManager.fetchBookings().filter { $0.isConfirmed }
    }
}

// MARK: - BookingRowView
struct BookingRowView: View {
    let booking: BookingModel
    private let dataManager = DataManager.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let hotel = dataManager.getHotel(by: booking.hotelId) {
                Text(hotel.name)
                    .font(.headline)
                Text(hotel.location)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            HStack {
                Image(systemName: "calendar")
                    .font(.caption)
                Text(formatDate(booking.checkInDate))
                    .font(.caption)
                Text("→")
                    .font(.caption)
                Text(formatDate(booking.checkOutDate))
                    .font(.caption)
            }
            .foregroundColor(.blue)
            
            HStack {
                Text("booking.total".localized)
                    .font(.subheadline)
                Spacer()
                Text(String(format: "$%.2f", booking.totalPrice))
                    .font(.headline)
                    .foregroundColor(.green)
            }
            
            HStack {
                Image(systemName: "person.2")
                    .font(.caption)
                Text("\(booking.guestsCount) \("booking.guests.count".localized)")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            if booking.isConfirmed {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("booking.confirmed".localized)
                        .font(.caption)
                        .foregroundColor(.green)
                }
            }
        }
        .padding(.vertical, 4)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}
