//
//  CardView.swift
//  Zbam
//
//  Created by Yagiz Gunes Teker on 17.01.26.
//

import SwiftUI
import SwiftData

struct CardView: View {
    let card: Card
    @State private var isPresentingEditView: Bool = false
    @State private var flipped: Bool = false
    
    init(card: Card) {
        self.card = card
    }
    
    var body: some View {
        let flipDegrees = flipped ? 180.0 : 0
        VStack {
            NavigationStack {
                VStack {
                    Spacer()
                    ZStack() {
                        Text(card.front)
                            .placedOnCard(Color.yellow)
                            .flipRotate(flipDegrees)
                            .opacity(flipped ? 0.0 : 1.0)
                        Text(card.back)
                            .placedOnCard(Color.blue)
                            .flipRotate(-180 + flipDegrees)
                            .opacity(flipped ? 1.0 : 0.0)
                    }
                    .animation(.easeInOut(duration: 0.8), value: flipped)
                    .onTapGesture {
                        flipped.toggle()
                    }
                    Spacer()
                }
                .toolbar {
                    Button("Edit") {
                        isPresentingEditView = true
                    }
                }
                .sheet(isPresented: $isPresentingEditView) {
                    NavigationStack {
                        CardEditView(card: card)
                            .navigationTitle("Card")
                    }
                }
            }
        }
    }
}

extension View {
    func flipRotate(_ degrees : Double) -> some View {
        return rotation3DEffect(Angle(degrees: degrees), axis: (x: 0.0, y: 1.0, z: 0.0))
    }
    
    func placedOnCard(_ color: Color) -> some View {
        return padding(5)
            .fontDesign(.serif)
            .font(.system(size: 54))
            .scaledToFit()
            .lineLimit(2)
            .minimumScaleFactor(0.01)
            .containerRelativeFrame([.vertical, .horizontal])
            .background(color)
            .cornerRadius(12.0)
            .shadow(radius: 12)
            .border(.black)
            
    }
}

#Preview(Card.sampleData.first?.front ?? "Card Preview", traits: .cardSampleData) {
    // Use the first sample card
//    if let first = Card.sampleData.first {
//        CardView(card: first)
//    } else {
        // Fallback if sample data is empty
        CardView(card: Card(front: "Frontjasdasdsadsdasdsad", back: "Back"))
//    }
}
