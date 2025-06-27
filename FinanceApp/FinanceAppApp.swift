//
//  FinanceAppApp.swift
//  FinanceApp
//
//  Created by MACBOOK PRO M1 on 12.6.25.
//

import SwiftUI

@main
struct FinanceAppApp: App {
    var body: some Scene {
        
        WindowGroup {
            
            VStack {
                MainTabView()
            }
            
        }
    }

    
   
}


#Preview {
    
    VStack {
        MainTabView()
    }
 
   // TransactionListView(direction: .income)
    
}
