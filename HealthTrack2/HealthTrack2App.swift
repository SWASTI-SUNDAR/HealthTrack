//
//  HealthTrack2App.swift
//  HealthTrack2
//
//  Created by Swasti Sundar Pradhan on 24/05/25.
//

//import SwiftUI
//
//@main
//struct HealthTrack2App: App {
//    var body: some Scene {
//        WindowGroup {
//            ContentView()
//        }
//    }
//}
import SwiftUI

@main
struct HealthTrack2App: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(HealthDataStore())
        }
    }
}
//import SwiftUI
//
//@main
//struct HealthTrack2App: App {
//    var body: some Scene {
//        WindowGroup {
//            ContentView()
//        }
//    }
//}
