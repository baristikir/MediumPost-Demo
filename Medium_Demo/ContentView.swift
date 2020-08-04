//
//  ContentView.swift
//  Medium_Demo
//
//  Created by Baris Tikir on 04.08.20.
//  Copyright © 2020 Baris Tikir. All rights reserved.
//

import SwiftUI
import Combine

struct ContentView: View {
    
    @EnvironmentObject var manager: HttpAuth
    
    var body: some View{
        if !self.manager.authenticated {
            return AnyView(SignInView())
        } else {
            return AnyView(HomeView())
        }
    }
}

struct SignInView: View{
    //Authentication private members - Login Model
    @State private var email: String = ""
    @State private var password: String = ""
    
    //Environment Object of HttpAuth for Global Http-Transactions
    @EnvironmentObject var manager: HttpAuth
    
    //Button Action method when user try's to sign in
    func signIn(){
        //Calling the signInHelper method from the custom Http class and passing input data
        self.manager.signInHelper(username: self.email, password: self.password)
    }
    
    var body: some View{
        NavigationView{
            ZStack{
                VStack(alignment: .center){
                    
                    //Heading
                    Text("Welcome")
                        .font(.system(size: 32, weight: .heavy))
                    
                    //Heading2
                    Text("Sign in to continue")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color(UIColor.gray))
                    
                    //Vertical Stack for TextField's
                    VStack(spacing: 15)
                    {
                        //Textfield for the username
                        TextField("Enter your Email adress..", text: $email)
                            .font(.system(size:14))
                            .padding(12)
                            .background(RoundedRectangle(cornerRadius: 5).strokeBorder(Color("bg1"), lineWidth: 1))
                        //.textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        //Textfield for the password
                        SecureField("Enter your Password..", text: $password)
                            .font(.system(size:14))
                            .padding(12)
                            .background(RoundedRectangle(cornerRadius: 5).strokeBorder(Color("bg1"), lineWidth: 1))
                        //.textFieldStyle(RoundedBorderTextFieldStyle())
                        
                    }
                    .padding(.vertical, 64)
                    
                    //Login Button
                    Button(action: signIn) {
                        //Displayed Button text with styling
                        Text("Sign In")
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .frame(height: 50)
                            .foregroundColor(Color(UIColor.white))
                            .font(.system(size:14, weight: .bold))
                            .background(LinearGradient(gradient: Gradient(colors: [
                                .blue , .blue ]), startPoint: .leading, endPoint: .trailing))
                            .cornerRadius(5)
                    }
                    
                    //Layout Sizing
                    Spacer()
                    
                    //Navigation Footer to SignUpView - **for new users**
                    NavigationLink(destination: SignUpView()) {
                        HStack{
                            //Footer SignUp Text
                            Text("I'm a new user.")
                                .font(.system(size:14, weight: .light))
                                .foregroundColor(.primary)
                            
                            //Footer SignUp Text
                            Text("Create an account")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Color(UIColor.systemBlue))
                        }
                    }
                }
                    //Horizontal styling - elements margin to edges
                    .padding(.horizontal, 32)
            }
        }
    }
}

//View for the Sign Up - for new users
struct SignUpView: View{
    
    //Authentication private members - RegisterModel
    @State var email: String = ""
    @State var password: String = ""
    @State var confirmPassword: String = ""
    
    //Environment Object of HttpAuth for Global Http Transactions
    @EnvironmentObject var manager: HttpAuth
    
    //Calling the signUpHelper method from the custom Http class and passing input data
    func signUp() {
        self.manager.signUpHelper(username: self.email, password: self.password, confirmPassword: self.confirmPassword)
    }
     
    //Main View of SignUpView
    var body: some View{
        VStack{
            //Title
            Text("Create Account")
                .font(.system(size: 32, weight: .heavy))
            
            //Subtitle
            Text("Sign up to get started")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Color(UIColor.gray))
            
            //Vertical Stack for TextField's - for username and password
            VStack(spacing: 16) {
                
                //Input Field for email adress of the client
                TextField("Enter your Email adress..", text: $email)
                    .font(.system(size: 14))
                    .padding(12)
                    .background(RoundedRectangle(cornerRadius: 5)
                        .strokeBorder(Color("bg1"), lineWidth: 1))
                
                //Input Field for password of the client
                SecureField("Enter your Password..", text: $password)
                    .font(.system(size: 14))
                    .padding(12)
                    .background(RoundedRectangle(cornerRadius: 5)
                        .strokeBorder(Color("bg1"), lineWidth: 1))
                
                //Input Field for password of the client
                SecureField("Confirm your Password..", text: $confirmPassword)
                    .font(.system(size: 14))
                    .padding(12)
                    .background(RoundedRectangle(cornerRadius: 5)
                        .strokeBorder(Color("bg1"), lineWidth: 1))
            }
            .padding(.vertical, 64)
            
            //Button for SignUp
            Button(action: signUp)
            {
                //Displayed Button text with styling
                Text("Create Account")
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .frame(height: 50)
                    .foregroundColor(Color(UIColor.white))
                    .font(.system(size:14, weight: .bold))
                    .background(LinearGradient(gradient: Gradient(colors: [
                        .blue , .blue ]), startPoint: .leading, endPoint: .trailing))
                    .cornerRadius(5)
            }
            
            //Layout Sizing
            Spacer()
        }
        //Horizontal styling - elements margin to edges
        .padding(.horizontal, 32)
    }
}


class HttpAuth: ObservableObject{
    
    @Published var authenticated = false
    
    //Method for SignIn with transactions to the RESTful Server - API
    func signInHelper(username: String, password: String){
        //Server domain
        guard let url = URL(string: "http://localhost:5000/api/login") else { return }
        
        let body: [String: String] = ["email": username, "password": password]
        let finalBody = try! JSONSerialization.data(withJSONObject: body)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = finalBody
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else { return }
            do{
                let decoder = JSONDecoder()
                let returnedData = try decoder.decode(LoginUserInfo.self, from: data)
                
                if returnedData.successful == true{
                    DispatchQueue.main.async {
                        self.authenticated = true
                    }
                }
            }
            catch let err {
                print(err.localizedDescription)
            }
        }.resume()
    }
    
    //Method for SignUp with transactions to the RESTful Server - API
    func signUpHelper(username: String, password: String, confirmPassword: String){
        guard let signUpUrl = URL(string: "http://localhost:5000/api/accounts") else { return }
        
        let body: [String: String] = ["Email": username, "Password": password, "ConfirmPassword": confirmPassword]
        let finalbody = try! JSONSerialization.data(withJSONObject: body)
        
        var request = URLRequest(url: signUpUrl)
        request.httpMethod = "POST"
        request.httpBody = finalbody
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { (data, response, error ) in
            guard let data = data else { return }
            do{
                let decoder = JSONDecoder()
                let returnedData = try decoder.decode(RegisterUserInfo.self, from: data)
                
                if returnedData.successful == true{
                    DispatchQueue.main.async {
                        self.authenticated = true
                    }
                }
            }
            catch let err {
                print(err)
            }
        }.resume()
    }
}


//Register Result - Object for storing response data from Server
struct RegisterUserInfo: Decodable{
    var id: String?
    var successful: Bool
    var errors: [String]?
}

//Login Result - Object for storing response data from Server
struct LoginUserInfo: Decodable{
    var successful: Bool
    var error: String?
    var token: String?
}
