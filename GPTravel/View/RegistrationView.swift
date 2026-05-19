// created by GPTeam
import SwiftUI

struct RegistrationView: View {
    @EnvironmentObject var userManager: UserManager
    @State private var fullName = ""
    @State private var phoneNumber = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showSuccess = false
    @State private var isLoginMode = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 25) {
                    VStack(spacing: 10) {
                        Image(systemName: isLoginMode ? "person.circle.fill" : "person.badge.plus.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.blue)
                        Text(isLoginMode ? "Вход в аккаунт" : "Регистрация")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        Text(isLoginMode ? "Войдите в свой аккаунт" : "Создайте новый аккаунт")
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 30)
                    
                    // Form Fields
                    VStack(spacing: 16) {
                        if !isLoginMode {
                            HStack {
                                Image(systemName: "person.fill")
                                    .foregroundColor(.gray)
                                    .frame(width: 30)
                                TextField("ФИО", text: $fullName)
                                    .autocapitalization(.words)
                            }
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
                        }
                        
                        HStack {
                            Image(systemName: "phone.fill")
                                .foregroundColor(.gray)
                                .frame(width: 30)
                            TextField("Номер телефона", text: $phoneNumber)
                                .keyboardType(.phonePad)
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                        
                        HStack {
                            Image(systemName: "envelope.fill")
                                .foregroundColor(.gray)
                                .frame(width: 30)
                            TextField("Email", text: $email)
                                .autocapitalization(.none)
                                .keyboardType(.emailAddress)
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                        
                        HStack {
                            Image(systemName: "lock.fill")
                                .foregroundColor(.gray)
                                .frame(width: 30)
                            SecureField("Пароль", text: $password)
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                        
                        if !isLoginMode {
                            HStack {
                                Image(systemName: "lock.shield.fill")
                                    .foregroundColor(.gray)
                                    .frame(width: 30)
                                SecureField("Подтвердите пароль", text: $confirmPassword)
                            }
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Action Button
                    Button(action: isLoginMode ? login : register) {
                        Text(isLoginMode ? "Войти" : "Зарегистрироваться")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                    
                    // Toggle Mode
                    Button(action: {
                        withAnimation {
                            isLoginMode.toggle()
                            clearFields()
                        }
                    }) {
                        Text(isLoginMode ? "Нет аккаунта? Зарегистрироваться" : "Уже есть аккаунт? Войти")
                            .foregroundColor(.blue)
                    }
                    .padding(.top, 10)
                }
                .padding()
            }
            .navigationTitle("")
            .navigationBarHidden(true)
            .alert("Ошибка", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func register() {
        guard !phoneNumber.isEmpty else {
            errorMessage = "Введите номер телефона"
            showError = true
            return
        }
        guard !email.isEmpty else {
            errorMessage = "Введите email"
            showError = true
            return
        }
        guard email.contains("@") && email.contains(".") else {
            errorMessage = "Введите корректный email"
            showError = true
            return
        }
        guard password.count >= 6 else {
            errorMessage = "Пароль должен содержать минимум 6 символов"
            showError = true
            return
        }
        guard password == confirmPassword else {
            errorMessage = "Пароли не совпадают"
            showError = true
            return
        }
        
        let success = userManager.register(phoneNumber: phoneNumber, email: email, password: password, fullName: fullName.isEmpty ? nil : fullName)
        if !success {
            errorMessage = "Пользователь с таким email или телефоном уже существует"
            showError = true
        }
        // Если успех, userManager.isLoggedIn станет true, и GPTravelApp сам переключится на MainTabView
    }
    
    private func login() {
        guard !email.isEmpty else {
            errorMessage = "Введите email"
            showError = true
            return
        }
        guard !password.isEmpty else {
            errorMessage = "Введите пароль"
            showError = true
            return
        }
        
        let success = userManager.login(email: email, password: password)
        if !success {
            errorMessage = "Неверный email или пароль"
            showError = true
        }
        // При успехе userManager.isLoggedIn станет true, и произойдёт переход
    }
    
    private func clearFields() {
        fullName = ""
        phoneNumber = ""
        email = ""
        password = ""
        confirmPassword = ""
    }
}
