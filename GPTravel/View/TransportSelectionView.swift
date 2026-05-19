// created by GPTeam
import SwiftUI
import MapKit

// MARK: - Модель города
struct City: Identifiable {
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
    let country: String
}

// MARK: - Модель маршрута для карты
struct MapRoute: Identifiable {
    let id = UUID()
    let fromCity: City
    let toCity: City
    var coordinates: [CLLocationCoordinate2D] = []
}

class TransportSelectionViewModel: ObservableObject {
    @Published var routes: [TransportRouteModel] = []
    @Published var filteredRoutes: [TransportRouteModel] = []
    @Published var selectedMapRoute: MapRoute?
    @Published var selectedCityFrom: City?
    @Published var selectedCityTo: City?
    @Published var showingCitySelection = false
    @Published var selectionMode: SelectionMode = .from
    @Published var showSuccessAlert = false
    @Published var selectedRoute: TransportRouteModel?
    
    enum SelectionMode {
        case from, to
    }
    
    // Города и маршруты
    let cities: [City] = [
        City(name: "Минск", coordinate: CLLocationCoordinate2D(latitude: 53.9045, longitude: 27.5615), country: "Беларусь"),
        City(name: "Москва", coordinate: CLLocationCoordinate2D(latitude: 55.7558, longitude: 37.6173), country: "Россия"),
        City(name: "Санкт-Петербург", coordinate: CLLocationCoordinate2D(latitude: 59.9343, longitude: 30.3351), country: "Россия"),
        City(name: "Варшава", coordinate: CLLocationCoordinate2D(latitude: 52.2297, longitude: 21.0122), country: "Польша"),
        City(name: "Киев", coordinate: CLLocationCoordinate2D(latitude: 50.4501, longitude: 30.5234), country: "Украина"),
        City(name: "Вильнюс", coordinate: CLLocationCoordinate2D(latitude: 54.6872, longitude: 25.2797), country: "Литва"),
        City(name: "Берлин", coordinate: CLLocationCoordinate2D(latitude: 52.5200, longitude: 13.4050), country: "Германия"),
        City(name: "Париж", coordinate: CLLocationCoordinate2D(latitude: 48.8566, longitude: 2.3522), country: "Франция")
    ]
    
    let allTransportRoutes: [TransportRouteModel] = [
        // Минск - Москва
        TransportRouteModel(transportType: .plane, companyName: "Belavia", price: 250, departureTime: Date().addingTimeInterval(86400), arrivalTime: Date().addingTimeInterval(93600), fromLocation: "Минск", toLocation: "Москва"),
        TransportRouteModel(transportType: .plane, companyName: "Aeroflot", price: 280, departureTime: Date().addingTimeInterval(172800), arrivalTime: Date().addingTimeInterval(180000), fromLocation: "Минск", toLocation: "Москва"),
        TransportRouteModel(transportType: .train, companyName: "БелЖД", price: 85, departureTime: Date().addingTimeInterval(259200), arrivalTime: Date().addingTimeInterval(273600), fromLocation: "Минск", toLocation: "Москва"),
        TransportRouteModel(transportType: .bus, companyName: "Ecolines", price: 45, departureTime: Date().addingTimeInterval(345600), arrivalTime: Date().addingTimeInterval(367200), fromLocation: "Минск", toLocation: "Москва"),
        
        // Минск - Варшава
        TransportRouteModel(transportType: .plane, companyName: "LOT", price: 180, departureTime: Date().addingTimeInterval(86400), arrivalTime: Date().addingTimeInterval(90000), fromLocation: "Минск", toLocation: "Варшава"),
        TransportRouteModel(transportType: .train, companyName: "PKP", price: 65, departureTime: Date().addingTimeInterval(172800), arrivalTime: Date().addingTimeInterval(187200), fromLocation: "Минск", toLocation: "Варшава"),
        TransportRouteModel(transportType: .bus, companyName: "FlixBus", price: 35, departureTime: Date().addingTimeInterval(259200), arrivalTime: Date().addingTimeInterval(280800), fromLocation: "Минск", toLocation: "Варшава"),
        
        // Минск - Киев
        TransportRouteModel(transportType: .plane, companyName: "Ukraine Airlines", price: 200, departureTime: Date().addingTimeInterval(86400), arrivalTime: Date().addingTimeInterval(90000), fromLocation: "Минск", toLocation: "Киев"),
        TransportRouteModel(transportType: .train, companyName: "UZ", price: 55, departureTime: Date().addingTimeInterval(172800), arrivalTime: Date().addingTimeInterval(187200), fromLocation: "Минск", toLocation: "Киев"),
        
        // Минск - Вильнюс
        TransportRouteModel(transportType: .bus, companyName: "Ecolines", price: 25, departureTime: Date().addingTimeInterval(86400), arrivalTime: Date().addingTimeInterval(90000), fromLocation: "Минск", toLocation: "Вильнюс"),
        TransportRouteModel(transportType: .train, companyName: "LTG", price: 40, departureTime: Date().addingTimeInterval(172800), arrivalTime: Date().addingTimeInterval(187200), fromLocation: "Минск", toLocation: "Вильнюс"),
        
        // Минск - Берлин
        TransportRouteModel(transportType: .plane, companyName: "Lufthansa", price: 350, departureTime: Date().addingTimeInterval(86400), arrivalTime: Date().addingTimeInterval(93600), fromLocation: "Минск", toLocation: "Берлин"),
        TransportRouteModel(transportType: .bus, companyName: "FlixBus", price: 75, departureTime: Date().addingTimeInterval(259200), arrivalTime: Date().addingTimeInterval(288000), fromLocation: "Минск", toLocation: "Берлин"),
        
        // Минск - Санкт-Петербург
        TransportRouteModel(transportType: .plane, companyName: "Belavia", price: 220, departureTime: Date().addingTimeInterval(86400), arrivalTime: Date().addingTimeInterval(90000), fromLocation: "Минск", toLocation: "Санкт-Петербург"),
        TransportRouteModel(transportType: .train, companyName: "РЖД", price: 70, departureTime: Date().addingTimeInterval(172800), arrivalTime: Date().addingTimeInterval(194400), fromLocation: "Минск", toLocation: "Санкт-Петербург"),
        
        // Минск - Париж
        TransportRouteModel(transportType: .plane, companyName: "AirFrance", price: 450, departureTime: Date().addingTimeInterval(86400), arrivalTime: Date().addingTimeInterval(97200), fromLocation: "Минск", toLocation: "Париж")
    ]
    
    init() {
        routes = allTransportRoutes
        filteredRoutes = routes
    }
    
    func filterRoutesByCities(from: City?, to: City?) {
        if let fromCity = from, let toCity = to {
            filteredRoutes = routes.filter {
                $0.fromLocation == fromCity.name && $0.toLocation == toCity.name
            }
            selectedMapRoute = MapRoute(fromCity: fromCity, toCity: toCity)
        } else {
            filteredRoutes = routes
            selectedMapRoute = nil
        }
    }
    
    func selectRoute(_ route: TransportRouteModel) {
        selectedRoute = route
        showSuccessAlert = true
    }
}

struct TransportSelectionView: View {
    let bookingId: UUID
    @StateObject private var viewModel = TransportSelectionViewModel()
    @State private var selectedTransportType: TransportType = .plane
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 53.9045, longitude: 27.5615),
        span: MKCoordinateSpan(latitudeDelta: 15.0, longitudeDelta: 15.0)
    )
    @State private var selectedAnnotation: City?
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // MARK: - Map View с городами
                Map(coordinateRegion: $region, showsUserLocation: true, annotationItems: viewModel.cities) { city in
                    MapAnnotation(coordinate: city.coordinate) {
                        Button(action: {
                            selectedAnnotation = city
                            if viewModel.selectionMode == .from {
                                viewModel.selectedCityFrom = city
                                viewModel.filterRoutesByCities(from: city, to: viewModel.selectedCityTo)
                            } else {
                                viewModel.selectedCityTo = city
                                viewModel.filterRoutesByCities(from: viewModel.selectedCityFrom, to: city)
                            }
                        }) {
                            VStack(spacing: 4) {
                                Image(systemName: "mappin.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(annotationColor(for: city))
                                    .background(Color.white)
                                    .clipShape(Circle())
                                
                                Text(city.name)
                                    .font(.caption2)
                                    .padding(4)
                                    .background(Color.white.opacity(0.8))
                                    .cornerRadius(4)
                            }
                        }
                    }
                }
                .frame(height: 350)
                .overlay(
                    VStack {
                        HStack {
                            Spacer()
                            VStack(spacing: 8) {
                                Button(action: { viewModel.selectionMode = .from }) {
                                    Text(viewModel.selectedCityFrom?.name ?? "Откуда")
                                        .padding(8)
                                        .frame(width: 120)
                                        .background(viewModel.selectionMode == .from ? Color.blue : Color.gray.opacity(0.3))
                                        .foregroundColor(.white)
                                        .cornerRadius(8)
                                }
                                
                                Image(systemName: "arrow.down")
                                    .font(.caption)
                                
                                Button(action: { viewModel.selectionMode = .to }) {
                                    Text(viewModel.selectedCityTo?.name ?? "Куда")
                                        .padding(8)
                                        .frame(width: 120)
                                        .background(viewModel.selectionMode == .to ? Color.green : Color.gray.opacity(0.3))
                                        .foregroundColor(.white)
                                        .cornerRadius(8)
                                }
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(radius: 4)
                            .padding(.trailing, 10)
                            .padding(.top, 10)
                        }
                        Spacer()
                    }
                )
                
                // MARK: - Информация о выбранном маршруте
                if let from = viewModel.selectedCityFrom, let to = viewModel.selectedCityTo {
                    HStack {
                        Text("\(from.name) → \(to.name)")
                            .font(.headline)
                        Spacer()
                        Button("Очистить") {
                            viewModel.selectedCityFrom = nil
                            viewModel.selectedCityTo = nil
                            viewModel.filterRoutesByCities(from: nil, to: nil)
                        }
                        .font(.caption)
                        .foregroundColor(.red)
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                }
                
                // MARK: - Transport Type Picker
                Picker("Тип транспорта", selection: $selectedTransportType) {
                    Text("✈️ Самолет").tag(TransportType.plane)
                    Text("🚆 Поезд").tag(TransportType.train)
                    Text("🚌 Автобус").tag(TransportType.bus)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                // MARK: - Routes List
                let filteredByType = viewModel.filteredRoutes.filter { $0.transportType == selectedTransportType }
                
                if filteredByType.isEmpty {
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: "tram.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("Нет рейсов")
                            .font(.headline)
                        if viewModel.selectedCityFrom != nil && viewModel.selectedCityTo != nil {
                            Text("Нет рейсов по маршруту \(viewModel.selectedCityFrom?.name ?? "") → \(viewModel.selectedCityTo?.name ?? "")")
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                        } else {
                            Text("Выберите маршрут на карте")
                                .foregroundColor(.gray)
                        }
                    }
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(filteredByType) { route in
                                TransportRouteCardView(route: route) {
                                    viewModel.selectRoute(route)
                                }
                                .padding(.horizontal)
                            }
                        }
                        .padding(.vertical)
                    }
                }
            }
            .navigationTitle("Выбор транспорта")
            .navigationBarItems(trailing: Button("Готово") {
                dismiss()
            })
            .alert(isPresented: $viewModel.showSuccessAlert) {
                Alert(
                    title: Text("✅ Успешно!"),
                    message: Text("""
                        Рейс выбран успешно!
                        
                        📍 \(viewModel.selectedRoute?.fromLocation ?? "") → \(viewModel.selectedRoute?.toLocation ?? "")
                        ✈️ \(viewModel.selectedRoute?.companyName ?? "")
                        💰 Стоимость: $\(viewModel.selectedRoute?.price ?? 0, specifier: "%.0f")
                        
                        Билет добавлен в ваши бронирования.
                        """),
                    dismissButton: .default(Text("Отлично!")) {
                        dismiss()
                    }
                )
            }
        }
    }
    
    private func annotationColor(for city: City) -> Color {
        if city.name == viewModel.selectedCityFrom?.name {
            return .blue
        } else if city.name == viewModel.selectedCityTo?.name {
            return .green
        }
        return .red
    }
}

struct TransportRouteCardView: View {
    let route: TransportRouteModel
    let onSelect: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: route.transportType == .plane ? "airplane" :
                                      route.transportType == .train ? "tram.fill" : "bus")
                    .font(.title2)
                    .foregroundColor(.blue)
                    .frame(width: 40, height: 40)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(20)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(route.companyName)
                        .font(.headline)
                    Text(route.transportType.displayName)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("$\(route.price, specifier: "%.0f")")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                    Text("за билет")
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
            }
            
            Divider()
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(route.fromLocation)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Text(formatTime(route.departureTime))
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Image(systemName: "arrow.right")
                    .foregroundColor(.blue)
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(route.toLocation)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Text(formatTime(route.arrivalTime))
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            Divider()
            
            HStack {
                Text("💰 \(route.price, specifier: "%.0f") ₽")
                    .font(.subheadline)
                    .foregroundColor(.green)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button(action: onSelect) {
                    HStack {
                        Text("Выбрать рейс")
                            .fontWeight(.semibold)
                        Image(systemName: "chevron.right")
                            .font(.caption)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.gray.opacity(0.15), radius: 8, x: 0, y: 2)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}
