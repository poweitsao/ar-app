//
//  InfoTile.swift
//  PoweiARApp
//
//  Created by Chang Peter on 11/2/23.
//


//struct InfoTileUIKit: UIViewRepresentable {
//    func makeUIView(context: Context) -> UIView {
//        let hostingController = UIHostingController(rootView: InfoTile())
//        return hostingController.view
//    }
//
//    func updateUIView(_ uiView: UIView, context: Context) {}
//}


//    var body: some View {
//        Text(isExpanded ? "Expanded" : "Collapsed")
//            .foregroundColor(.white)
//            .background(Color.blue)
//            .padding()
//    }
import SwiftUI
struct InfoTile: View {
    var isExpanded: Bool  // Binding to control expand/collapse

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
            
            if isExpanded {
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
            
        }
        .debugPrint("InfoTile body recalculating. isExpanded: \(isExpanded)")
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

struct InfoTile_Previews: PreviewProvider {
    static var previews: some View {
        InfoTile(isExpanded: false)
            .previewLayout(.sizeThatFits)
            .background(Color.blue)
    }
}

extension View {
    func debugPrint(_ value: Any) -> some View {
        print(value)
        return self
    }
}
