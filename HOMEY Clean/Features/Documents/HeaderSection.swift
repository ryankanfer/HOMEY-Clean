//
//  HeaderSection.swift
//  HOMEY Clean
//
//  Created by Ryan Kanfer on 1/2/25.
//

import SwiftUI

struct HeaderSection: View {
    let overallProgress: Double
    let getSmartSuggestion: () -> String?
    let getHealthColor: () -> Color
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text("Document Vault")
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)
                
                Text("Secure • Organized • Accessible")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                // Smart suggestion based on journey stage
                if let suggestion = getSmartSuggestion() {
                    HStack {
                        Image(systemName: "lightbulb.fill")
                            .foregroundColor(.yellow)
                            .font(.caption)
                        Text(suggestion)
                            .font(.caption)
                            .foregroundColor(.yellow)
                            .italic()
                    }
                    .padding(.top, 4)
                }
            }
            
            Spacer()
            
            // Enhanced circular progress indicator with visual health
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 3)
                    .frame(width: 60, height: 60)
                
                Circle()
                    .trim(from: 0, to: overallProgress)
                    .stroke(getHealthColor(), style: StrokeStyle(lineWidth: 3, lineCap: .round))
                    .frame(width: 60, height: 60)
                    .rotationEffect(.degrees(-90))
                
                Image(systemName: "doc.text")
                    .font(.title2)
                    .foregroundColor(getHealthColor())
                
                // Health indicator overlay
                if overallProgress < 0.3 {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.caption2)
                        .foregroundColor(.orange)
                        .offset(x: 20, y: -20)
                } else if overallProgress > 0.8 {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.caption2)
                        .foregroundColor(.green)
                        .offset(x: 20, y: -20)
                        .scaleEffect(1.2)
                        .animation(.easeInOut(duration: 0.5).repeatCount(3, autoreverses: true), value: overallProgress > 0.8)
                }
            }
        }
        .padding(.top, 20)
    }
}