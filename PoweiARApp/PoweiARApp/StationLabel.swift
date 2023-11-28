//
//  StationLabelView.swift
//  PoweiARApp
//
//  Created by Po on 11/19/23.
//

import SwiftUI

struct StationLabel: View {
    // Variables to allow for customization
    let id: String
    var isExpanded: Bool  // Binding to control expand/collapse
    @State var labelText: String = "Downtown"
    @State var circleColor: Color = Color(red: 20/255, green: 81/255, blue: 179/255)
    @State var labelColor: Color = .black
    @State var letterInsideCircle: String = "A"

    var body: some View {
        VStack{
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
            if isExpanded {
                VStack(alignment: .leading, spacing: 10) {
                    // Station Title
                    Text("Jay St-MetroTech Station")
                        .font(.title)
                        .foregroundColor(.white)
                    
                    // Entrance Information
                    Text("Uptown / Downtown Entrance")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                        // Spacer for some separation
                        Spacer()
                            .frame(height: 20)
                        
                        // "Upcoming" Title
                        Text("Upcoming")
                            .font(.title2)
                            .foregroundColor(.white)
                        
                        // Train Information List
                        TrainInfoView(line: "A", destination: "Ozone Park-Lefferts Blvd (Downtown)", eta: "Now")
                        TrainInfoView(line: "F", destination: "Jamaica-179 St (Uptown)", eta: "2 min")
                        TrainInfoView(line: "F", destination: "Jamaica-179 St (Uptown)", eta: "2 min")
                        TrainInfoView(line: "F", destination: "Jamaica-179 St (Uptown)", eta: "2 min")
                        TrainInfoView(line: "F", destination: "Jamaica-179 St (Uptown)", eta: "2 min")
                        TrainInfoView(line: "F", destination: "Jamaica-179 St (Uptown)", eta: "2 min")
                        TrainInfoView(line: "F", destination: "Jamaica-179 St (Uptown)", eta: "2 min")
                        TrainInfoView(line: "F", destination: "Jamaica-179 St (Uptown)", eta: "2 min")
                        // ... Add other train info views as needed
                }.debugPrint("InfoTile body recalculating. isExpanded: \(isExpanded)")
                .padding(20)
                .background(Color.black.opacity(0.8))
                .cornerRadius(20)
                .frame(maxWidth: .infinity)
                // Log when isExpanded changes
                .onChange(of: isExpanded) { newValue in
                    print("isExpanded changed to \(newValue)")
                }
            }
        }
    }
}

// Preview provider for SwiftUI canvas
struct StationLabel_Previews: PreviewProvider {
    static var previews: some View {
        StationLabel(id: "1", isExpanded: false)
            .background(Color.black) // Set the background of the StationLabel to black
            .previewLayout(.sizeThatFits) // This makes sure the preview is just big enough to fit the content
            .edgesIgnoringSafeArea(.all) // This will extend the black background to the edges of the preview
    }
}

