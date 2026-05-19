// created by GPTeam
import SwiftUI

@main
struct GPTravelApp: App {
    let persistenceController = CoreDataManager.shared
    @StateObject private var userManager = UserManager()
    
    var body: some Scene {
        WindowGroup {
            if userManager.isLoggedIn {
                MainTabView()
                    .environment(\.managedObjectContext, persistenceController.context)
                    .environmentObject(userManager)
            } else {
                RegistrationView()
                    .environmentObject(userManager)
            }
        }
    }
}

// MARK: - MainTabView
struct MainTabView: View {
    @State private var selectedTab = 0
    @EnvironmentObject var userManager: UserManager
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HotelListView()
                .tabItem {
                    Label("tab.hotels".localized, systemImage: "building.2")
                }
                .tag(0)
            
            MyBookingsView()
                .tabItem {
                    Label("tab.bookings".localized, systemImage: "bookmark")
                }
                .tag(1)
            
            ProfileView()
                .tabItem {
                    Label("Профиль", systemImage: "person.circle")
                }
                .tag(2)
        }
    }
}

// MARK: - ProfileView
struct ProfileView: View {
    @EnvironmentObject var userManager: UserManager
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if let user = userManager.currentUser {
                    // Аватар
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 100))
                        .foregroundColor(.blue)
                        .padding(.top, 30)
                    
                    // Информация о пользователе
                    VStack(spacing: 15) {
                        if let fullName = user.fullName {
                            HStack {
                                Text("ФИО:")
                                    .fontWeight(.semibold)
                                Text(fullName)
                                Spacer()
                            }
                        }
                        
                        HStack {
                            Text("Телефон:")
                                .fontWeight(.semibold)
                            Text(user.phoneNumber)
                            Spacer()
                        }
                        
                        HStack {
                            Text("Email:")
                                .fontWeight(.semibold)
                            Text(user.email)
                            Spacer()
                        }
                        
                        HStack {
                            Text("Зарегистрирован:")
                                .fontWeight(.semibold)
                            Text(user.registrationDate, style: .date)
                            Spacer()
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    // Кнопка выхода
                    Button(action: {
                        userManager.logout()
                    }) {
                        Text("Выйти")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 30)
                }
            }
            .navigationTitle("Профиль")
        }
    }
}
