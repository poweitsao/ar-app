//
//  InfoTileView.swift
//  PoweiARApp2
//
//  Created by Po on 12/1/23.
//
import SwiftUI

struct InfoTileView: View {
    var body: some View {
        Text("Information") // Replace with your content
            .padding()
            .foregroundColor(Color.black)
            .background(Color.white)
            .cornerRadius(10)
            .shadow(radius: 5)
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
