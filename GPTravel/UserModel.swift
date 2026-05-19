// created by GPTeam
import Foundation

struct UserModel: Codable {
    let id: UUID
    let phoneNumber: String
    let email: String
    let password: String
    let fullName: String?
    let registrationDate: Date
    
    init(id: UUID = UUID(), phoneNumber: String, email: String, password: String, fullName: String? = nil) {
        self.id = id
        self.phoneNumber = phoneNumber
        self.email = email
        self.password = password
        self.fullName = fullName
        self.registrationDate = Date()
    }
}

class UserManager: ObservableObject {
    @Published var currentUser: UserModel?
    @Published var isLoggedIn = false
    
    private let usersFilePath: URL
    private let currentUserFilePath: URL
    
    init() {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        usersFilePath = documentsDirectory.appendingPathComponent("users.plist")
        currentUserFilePath = documentsDirectory.appendingPathComponent("currentUser.plist")
        loadCurrentUser()
    }
    
    // MARK: - Регистрация
    func register(phoneNumber: String, email: String, password: String, fullName: String? = nil) -> Bool {
        // Проверка на существующего пользователя
        var users = loadAllUsers()
        
        if users.contains(where: { $0.email == email }) {
            print("Пользователь с таким email уже существует")
            return false
        }
        
        if users.contains(where: { $0.phoneNumber == phoneNumber }) {
            print("Пользователь с таким номером телефона уже существует")
            return false
        }
        
        // Создаем нового пользователя
        let newUser = UserModel(phoneNumber: phoneNumber, email: email, password: password, fullName: fullName)
        users.append(newUser)
        
        // Сохраняем в plist
        if saveAllUsers(users) {
            currentUser = newUser
            isLoggedIn = true
            saveCurrentUser()
            return true
        }
        
        return false
    }
    
    // MARK: - Вход
    func login(email: String, password: String) -> Bool {
        let users = loadAllUsers()
        
        if let user = users.first(where: { $0.email == email && $0.password == password }) {
            currentUser = user
            isLoggedIn = true
            saveCurrentUser()
            return true
        }
        
        return false
    }
    
    // MARK: - Выход
    func logout() {
        currentUser = nil
        isLoggedIn = false
        deleteCurrentUser()
    }
    
    // MARK: - Проверка авторизации
    func checkLoginStatus() -> Bool {
        return currentUser != nil && isLoggedIn
    }
    
    private func loadAllUsers() -> [UserModel] {
        do {
            let data = try Data(contentsOf: usersFilePath)
            let users = try PropertyListDecoder().decode([UserModel].self, from: data)
            return users
        } catch {
            print("Ошибка загрузки пользователей: \(error)")
            return []
        }
    }
    
    private func saveAllUsers(_ users: [UserModel]) -> Bool {
        do {
            let data = try PropertyListEncoder().encode(users)
            try data.write(to: usersFilePath)
            return true
        } catch {
            print("Ошибка сохранения пользователей: \(error)")
            return false
        }
    }
    
    private func saveCurrentUser() {
        if let user = currentUser {
            do {
                let data = try PropertyListEncoder().encode(user)
                try data.write(to: currentUserFilePath)
            } catch {
                print("Ошибка сохранения текущего пользователя: \(error)")
            }
        }
    }
    
    private func loadCurrentUser() {
        do {
            let data = try Data(contentsOf: currentUserFilePath)
            currentUser = try PropertyListDecoder().decode(UserModel.self, from: data)
            isLoggedIn = true
        } catch {
            print("Нет сохраненного пользователя")
            currentUser = nil
            isLoggedIn = false
        }
    }
    
    private func deleteCurrentUser() {
        try? FileManager.default.removeItem(at: currentUserFilePath)
    }
}
