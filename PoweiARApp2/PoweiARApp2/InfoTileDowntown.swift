//
//  InfoTileDowntown.swift
//  PoweiARApp2
//
//  Created by Po on 12/5/23.
//
import SwiftUI

struct InfoTileDowntown: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Downtown Entrance")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.bottom, 5)
            
            HStack {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 30, height: 30)
                    .overlay(
                        Text("A")
                            .foregroundColor(.white)
                            .bold()
                    )
                Text("Ozone Park-Lefferts Blvd (Downtown)")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
            }
            
            HStack(spacing: 16) {
                Text("1 Min")
                Text("5 Min")
                Text("16 Min")
            }
            .foregroundColor(.white)
            .padding(.leading, 40)
            
            Spacer()

            HStack {
                Circle()
                    .fill(Color.orange)
                    .frame(width: 30, height: 30)
                    .overlay(
                        Text("F")
                            .foregroundColor(.white)
                            .bold()
                    )
                Text("Jamaica-179 St (Downtown)")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
            }
            
            HStack(spacing: 16) {
                Text("2 min")
                Text("10 min")
                Text("17 min")
            }
            .foregroundColor(.white)
            .padding(.leading, 40)
            Spacer()
        }
        .padding([.top, .horizontal])
        .background(Color.black)
        .cornerRadius(10)
        .shadow(radius: 5)
        .frame(width: 450, height: 170)
    }
}

struct InfoTileDowntown_Previews: PreviewProvider {
    static var previews: some View {
        InfoTileDowntown()
            .previewLayout(.sizeThatFits)
            .padding()
            .background(Color.gray)
    }
}
