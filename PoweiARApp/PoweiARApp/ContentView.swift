//
//  ContentView.swift
//  PoweiARApp
//
//  Created by Powei on 11/2/23.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            ARViewContainer()
                .edgesIgnoringSafeArea(.all)
        }
    }
}


#Preview {
    ContentView()
}
