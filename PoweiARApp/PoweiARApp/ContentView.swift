//
//  ContentView.swift
//  PoweiARApp
//
//  Created by Powei on 11/2/23.
//

import SwiftUI

struct ContentView: View {
    @State private var isExpanded = true

    var body: some View {
        VStack {
            ARViewContainer(isExpanded: $isExpanded)
                .edgesIgnoringSafeArea(.all)
        }
    }
}


#Preview {
    ContentView()
}
