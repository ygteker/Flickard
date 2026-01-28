import SwiftUI
import SwiftData

struct CardView: View {
    enum SwipeDirection {
        case left, right, none
    }

    struct Model: Identifiable, Equatable {
        let id: UUID
        let front: String
        let back: String
        var swipeDirection: SwipeDirection = .none
    }

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isFlipped: Bool = false

    var model: Model
    var size: CGSize
    var dragOffset: CGSize
    var isTopCard: Bool
    var isSecondCard: Bool

    private var borderColor: Color {
        if dragOffset.width > 0 {
            return Color.green.opacity(0.6)
        } else if dragOffset.width < 0 {
            return Color.red.opacity(0.6)
        } else {
            return isFlipped ? Color.green.opacity(0.5) : Color.accentColor.opacity(0.5)
        }
    }

    private var shadowColor: Color {
        if dragOffset.width > 0 {
            return Color.green.opacity(0.4)
        } else if dragOffset.width < 0 {
            return Color.red.opacity(0.4)
        } else {
            return Color.black.opacity(0.1)
        }
    }

    var body: some View {
        ZStack {
            // Front
            SwipeCardFace(
                text: model.front,
                isFront: true,
                size: size,
                borderColor: borderColor,
                shadowColor: isTopCard ? shadowColor : (isSecondCard && dragOffset.width != 0 ? Color.gray.opacity(0.2) : Color.clear)
            )
            .opacity(isFlipped ? 0 : 1)

            // Back
            SwipeCardFace(
                text: model.back,
                isFront: false,
                size: size,
                borderColor: borderColor,
                shadowColor: isTopCard ? shadowColor : (isSecondCard && dragOffset.width != 0 ? Color.gray.opacity(0.2) : Color.clear)
            )
            .opacity(isFlipped ? 1 : 0)
            .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
        }
        .rotation3DEffect(
            .degrees(isFlipped ? 180 : 0),
            axis: (x: 0, y: 1, z: 0)
        )
        .animation(reduceMotion ? .none : .spring(response: 0.5, dampingFraction: 0.7), value: isFlipped)
        .accessibilityLabel(isFlipped ? "Card back: \(model.back)" : "Card front: \(model.front)")
        .accessibilityHint("Tap to flip card")
        .onTapGesture {
            isFlipped.toggle()
        }
    }
}

// MARK: - Swipe Card Face

private struct SwipeCardFace: View {
    let text: String
    let isFront: Bool
    let size: CGSize
    let borderColor: Color
    let shadowColor: Color

    var body: some View {
        VStack {
            Spacer()

            Text(text)
                .font(.title2)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
                .foregroundStyle(.primary)
                .padding(.horizontal)

            Spacer()

            Text(isFront ? "Front" : "Back")
                .font(.caption2)
                .foregroundStyle(.tertiary)
                .padding(.bottom, 12)
        }
        .frame(width: size.width * 0.8, height: size.height * 0.55)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: shadowColor, radius: 12, x: 0, y: 6)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(borderColor, lineWidth: 2)
        )
    }
}

#Preview("Top Card - No Drag") {
    CardView(
        model: CardView.Model(
            id: UUID(),
            front: "What is SwiftUI?",
            back: "A declarative framework for building user interfaces"
        ),
        size: CGSize(width: 400, height: 600),
        dragOffset: .zero,
        isTopCard: true,
        isSecondCard: false
    )
}

#Preview("Top Card - Dragging Right") {
    CardView(
        model: CardView.Model(
            id: UUID(),
            front: "What is SwiftUI?",
            back: "A declarative framework for building user interfaces"
        ),
        size: CGSize(width: 400, height: 600),
        dragOffset: CGSize(width: 80, height: 0),
        isTopCard: true,
        isSecondCard: false
    )
}

#Preview("Top Card - Dragging Left") {
    CardView(
        model: CardView.Model(
            id: UUID(),
            front: "What is SwiftUI?",
            back: "A declarative framework for building user interfaces"
        ),
        size: CGSize(width: 400, height: 600),
        dragOffset: CGSize(width: -80, height: 0),
        isTopCard: true,
        isSecondCard: false
    )
}
