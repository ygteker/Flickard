//
//  CardView.swift
//  Zbam
//
//  Created by Yagiz Gunes Teker on 17.01.26.
//

import SwiftUI
import SwiftData

struct CardView: View {
    enum SwipeDirection {
        case left, right, none
    }
    
    struct Model: Identifiable, Equatable {
        let id = UUID()
        let front: String
        let back: String
        var swipeDirection: SwipeDirection = .none
    }
    
    @State private var flipped: Bool = false
    
    var model: Model
    var size: CGSize
    var dragOffset: CGSize
    var isTopCard: Bool
    var isSecondCard: Bool
    
    var body: some View {
        let flipDegrees = flipped ? 180.0 : 0
        ZStack {
            Text(model.front)
                .frame(width: size.width * 0.8, height: size.height * 0.8)
                .background(Color.white)
                .cornerRadius(12.0)
                .shadow(color: isTopCard ? getShadowColor() : (isSecondCard && dragOffset.width != 0 ? Color.gray.opacity(0.2) : Color.clear), radius: 10, x: 0, y: 3)
                .foregroundColor(.black)
                .font(.largeTitle)
                .padding()
                .flipRotate(flipDegrees)
                .opacity(isTopCard ? flipped ? 0.0 : 1.0 : 0.0)
            Text(model.back)
                .frame(width: size.width * 0.8, height: size.height * 0.8)
                .background(Color.white)
                .cornerRadius(12.0)
                .shadow(color: isTopCard ? getShadowColor() : (isSecondCard && dragOffset.width != 0 ? Color.gray.opacity(0.2) : Color.clear), radius: 10, x: 0, y: 3)
                .foregroundColor(.black)
                .font(.largeTitle)
                .padding()
                .flipRotate(-180 + flipDegrees)
                .opacity(flipped ? 1.0 : 0.0)
        }
        .animation(.easeInOut(duration: 0.8), value: flipped)
        .onTapGesture {
            flipped.toggle()
        }
    }
    
    private func getShadowColor() -> Color {
        if dragOffset.width > 0 {
            return Color.green.opacity(0.5)
        } else if dragOffset.width < 0 {
            return Color.red.opacity(0.5)
        } else {
            return Color.gray.opacity(0.2)
        }
    }
}

extension View {
    func flipRotate(_ degrees: Double) -> some View {
        return rotation3DEffect(Angle(degrees: degrees), axis: (x: 0.0, y: 1.0, z: 0.0))
    }
}
