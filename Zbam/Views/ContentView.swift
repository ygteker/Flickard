//
//  ContentView.swift
//  Zbam
//
//  Created by Yagiz Gunes Teker on 20.01.26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            let cards = [
                CardView.Model(front: "Card 1front", back: "Card1 back"),
                CardView.Model(front: "Card 2", back: "Card 2 back"),
                CardView.Model(front: "Card 3", back: "Card 3 back"),
                CardView.Model(front: "Card 4", back: "Card 4 back")
            ]
            
            let model = SwipeableCardsView.Model(cards: cards)
            SwipeableCardsView(model: model) { model in
                print(model.swipedCards)
                model.reset()
            }
        }
        .padding()
    }
}
