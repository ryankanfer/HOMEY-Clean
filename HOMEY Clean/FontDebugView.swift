//
//  FontDebugView.swift
//  HOMEY Clean
//
//  Font debugging view to test font loading
//

import SwiftUI

struct FontDebugView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("System Font (Default)")
                .font(.title)
            
            Text("HomeyTextStyles.title")
                .font(HomeyTextStyles.title)
                .foregroundColor(.red)
            
            Text("HomeyTextStyles.subtitle")
                .font(HomeyTextStyles.subtitle)
                .foregroundColor(.blue)
            
            Text("HomeyTextStyles.body")
                .font(HomeyTextStyles.body)
                .foregroundColor(.green)
            
            Text("HomeyTextStyles.caption")
                .font(HomeyTextStyles.caption)
                .foregroundColor(.orange)
            
            Text("Using titleText() modifier")
                .titleText(color: .purple)
            
            Text("Using subtitleText() modifier")
                .subtitleText(color: .pink)
            
            Text("Font Name Tests:")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("JosefinSans-Bold: \(UIFont(name: "JosefinSans-Bold", size: 16) != nil ? "✅" : "❌")")
                Text("JosefinSans-Regular: \(UIFont(name: "JosefinSans-Regular", size: 16) != nil ? "✅" : "❌")")
                Text("JosefinSans-SemiBold: \(UIFont(name: "JosefinSans-SemiBold", size: 16) != nil ? "✅" : "❌")")
                Text("PlayfairDisplay-Regular: \(UIFont(name: "PlayfairDisplay-Regular", size: 16) != nil ? "✅" : "❌")")
                Text("PlayfairDisplay-Italic: \(UIFont(name: "PlayfairDisplay-Italic", size: 16) != nil ? "✅" : "❌")")
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
            
            Text("Available Fonts (Josefin & Playfair):")
                .font(.headline)
            
            ScrollView {
                LazyVStack(alignment: .leading) {
                    ForEach(UIFont.familyNames.sorted().filter { $0.contains("Josefin") || $0.contains("Playfair") }, id: \.self) { family in
                        VStack(alignment: .leading) {
                            Text("Family: \(family)")
                                .font(.headline)
                                .foregroundColor(.blue)
                            ForEach(UIFont.fontNames(forFamilyName: family), id: \.self) { font in
                                Text("Font: \(font)")
                                    .font(.custom(font, size: 16))
                                    .padding(.leading)
                                    .foregroundColor(.green)
                            }
                        }
                        .padding(.bottom, 4)
                    }
                }
            }
        }
        .padding()
    }
}

#Preview {
    FontDebugView()
}