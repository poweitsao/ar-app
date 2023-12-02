//
//  InfoTileView.swift
//  PoweiARApp2
//
//  Created by Po on 12/1/23.
//
import SwiftUI

struct InfoTileView: View {
    var body: some View {
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
        }
        .padding(20)
        .background(Color.black.opacity(1))
        .cornerRadius(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    struct TrainInfoView: View {
        var line: String
        var destination: String
        var eta: String
        
        var body: some View {
            HStack {
                // Train Line Circle
                Circle()
                    .frame(width: 30, height: 30)
                    .foregroundColor(.blue) // Adjust color based on the line
                    .overlay(Text(line).foregroundColor(.white))
                
                // Destination
                Text(destination)
                    .foregroundColor(.white)
                    .font(.body)
                
                Spacer()
                
                // ETA
                Text(eta)
                    .foregroundColor(.gray)
            }
        }
    }
    
    // Preview provider
    struct InfoTileView_Previews: PreviewProvider {
        static var previews: some View {
            InfoTileView()
                .previewLayout(.sizeThatFits)
                .padding()
        }
    }
}
