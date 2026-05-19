// created by GPTeam
import SwiftUI

struct HotelListView: View {
    @StateObject private var viewModel = HotelListViewModel()
    @EnvironmentObject var userManager: UserManager
    @State private var showingBookingSheet = false
    @State private var selectedHotel: HotelModel?
    
    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.isLoading {
                    ProgressView("loading.hotels".localized)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(viewModel.hotels) { hotel in
                                HotelCardView(hotel: hotel) {
                                    if userManager.isLoggedIn {
                                        selectedHotel = hotel
                                        showingBookingSheet = true
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("hotels.title".localized)
            .sheet(isPresented: $showingBookingSheet) {
                if let hotel = selectedHotel {
                    BookingView(hotel: hotel)
                        .environmentObject(userManager)
                }
            }
        }
    }
}

// MARK: - HotelCardView
struct HotelCardView: View {
    let hotel: HotelModel
    let onBook: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // MARK: - Hotel Image
            if let uiImage = UIImage(named: hotel.imageName) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 200)
                    .clipped()
                    .cornerRadius(12)
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 200)
                    .overlay(
                        VStack(spacing: 8) {
                            Image(systemName: "building.2")
                                .font(.largeTitle)
                                .foregroundColor(.gray)
                            Text("hotel.no.image".localized)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    )
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(hotel.name)
                    .font(.title2)
                    .fontWeight(.semibold)
                
                HStack {
                    Image(systemName: "location.fill")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(hotel.location)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                HStack {
                    StarRatingView(rating: hotel.rating)
                    Spacer()
                    Text("hotel.price".localized + String(format: " $%.0f", hotel.pricePerNight))
                        .font(.headline)
                        .foregroundColor(.blue)
                }
                
                Button(action: onBook) {
                    Text("hotel.book".localized)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 2)
    }
}

// MARK: - StarRatingView
struct StarRatingView: View {
    let rating: Double
    
    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<5) { index in
                Image(systemName: index < Int(rating) ? "star.fill" : "star")
                    .font(.caption)
                    .foregroundColor(.yellow)
            }
            Text(String(format: "%.1f", rating))
                .font(.caption)
                .foregroundColor(.gray)
        }
    }
}
