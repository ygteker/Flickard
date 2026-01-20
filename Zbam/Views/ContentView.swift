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
                CardView.Model(text: "Card 1"),
                CardView.Model(text: "Card 2"),
                CardView.Model(text: "Card 3"),
                CardView.Model(text: "Card 4")
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
