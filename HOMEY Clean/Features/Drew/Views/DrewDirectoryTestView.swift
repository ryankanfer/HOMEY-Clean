//
//  DrewDirectoryTestView.swift
//  HOMEY Clean
//
//  Test version of Drew's Directory
//

import SwiftUI

struct DrewDirectoryTestView: View {
    var body: some View {
        VStack {
            Text("Drew says Hi")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text("Professional Network")
                .font(.headline)
                .foregroundColor(.gray)
            
            Spacer()
            
            Text("Coming Soon")
                .font(.title2)
                .foregroundColor(.blue)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
        .preferredColorScheme(.dark)
    }
}

#Preview {
    DrewDirectoryTestView()
}