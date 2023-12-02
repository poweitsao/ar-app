//
//  CircleView.swift
//  PoweiARApp2
//
//  Created by Po on 12/1/23.
//
import SwiftUI

struct CircleView: View {
    var onTap: () -> Void // Closure for tap action

    var body: some View {
        Circle()
            .frame(width: 100, height: 100)
            .foregroundColor(.blue)
            .onTapGesture {
                onTap() // Call the closure when tapped
            }
    }
}

