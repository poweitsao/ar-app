//
//  CircleView.swift
//  PoweiARApp2
//
//  Created by Po on 12/1/23.
//
import SwiftUI

struct CircleView: View {

    @State var labelText: String = "Downtown"
    @State var circleColor: Color = Color(red: 20/255, green: 81/255, blue: 179/255)
    @State var labelColor: Color = .black
    @State var letterInsideCircle: String = "A"

    var body: some View {
        ZStack {
            // Horizontal stack for the label and the circle with letter 'A'
            HStack {
                // Label "Downtown" aligned to the leading edge
                Text(labelText)
                    .foregroundColor(labelColor)
                    .padding(.leading, 20)
                    .frame(width: 130) // gotta manually toggle this to make it fit (no idea why)
                
                Spacer() // Spacer to push the label and circle to opposite sides
                
                // Blue circle with the letter 'A' centered
                Circle()
                    .fill(circleColor)
                    .frame(width: 50, height: 50)
                    .overlay(
                        Text(letterInsideCircle)
                            .foregroundColor(.white)
                            .bold()
                    )
                    .padding(.trailing, 20)
            }
            .frame(maxWidth: 200)
            .padding(10)
            .background(Color(red: 217/255, green: 217/255, blue: 217/255))
            .cornerRadius(40)
        }
    }
}

