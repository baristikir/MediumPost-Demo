//
//  HomeView.swift
//  Medium_Demo
//
//  Created by Baris Tikir on 04.08.20.
//  Copyright © 2020 Baris Tikir. All rights reserved.
//

import SwiftUI

struct HomeView: View {
    
    @EnvironmentObject var manager: HttpAuth
    
    var body: some View {
        VStack{
            Text("Hello, World!")
            
            Button(action: signOut){
                Text("Sign Out")
            }
        }
    }
    
    func signOut(){
        self.manager.authenticated = false
    }
}
