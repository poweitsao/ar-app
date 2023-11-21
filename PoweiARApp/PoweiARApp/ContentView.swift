//
//  ContentView.swift
//  PoweiARApp
//
//  Created by Powei on 11/2/23.
//

import SwiftUI

struct ContentView: View {
    @StateObject var expandState = ExpandState()

    var body: some View {
        VStack {
            ARViewContainer(expandState: expandState)
                .edgesIgnoringSafeArea(.all)
        }
    }
}


#Preview {
    ContentView()
}
