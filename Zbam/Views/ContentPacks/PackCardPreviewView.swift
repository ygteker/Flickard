import SwiftUI

/// Preview a pack card before adding with flip animation, hints, and example
struct PackCardPreviewView: View {
    let card: PackCard
    let onAdd: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var isFlipped = false
    @State private var showHint = false
    @State private var hasAdded = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()

                // Flip card
                ZStack {
                    // Front
                    CardFaceView(
                        text: card.front,
                        isFront: true,
                        isFlipped: isFlipped
                    )
                    .opacity(isFlipped ? 0 : 1)

                    // Back
                    CardFaceView(
                        text: card.back,
                        isFront: false,
                        isFlipped: isFlipped
                    )
                    .opacity(isFlipped ? 1 : 0)
                    .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                }
                .rotation3DEffect(
                    .degrees(isFlipped ? 180 : 0),
                    axis: (x: 0, y: 1, z: 0)
                )
                .animation(.spring(response: 0.5, dampingFraction: 0.7), value: isFlipped)
                .onTapGesture {
                    isFlipped.toggle()
                }

                Text("Tap to flip")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                // Hint section
                if let hint = card.hint {
                    VStack(alignment: .leading, spacing: 8) {
                        Button {
                            withAnimation {
                                showHint.toggle()
                            }
                        } label: {
                            HStack {
                                Image(systemName: "lightbulb.fill")
                                    .foregroundStyle(.yellow)
                                Text("Hint")
                                    .fontWeight(.medium)
                                Spacer()
                                Image(systemName: showHint ? "chevron.up" : "chevron.down")
                                    .font(.caption)
                            }
                        }
                        .foregroundStyle(.primary)

                        if showHint {
                            Text(hint)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .transition(.opacity.combined(with: .move(edge: .top)))
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                // Example section
                if let example = card.example {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "text.quote")
                                .foregroundStyle(Color.accentColor)
                            Text("Example")
                                .fontWeight(.medium)
                        }

                        Text(example)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .italic()
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                // Tags
                if !card.tags.isEmpty {
                    HStack(spacing: 8) {
                        ForEach(card.tags, id: \.self) { tag in
                            Text(tag)
                                .font(.caption)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(Color.accentColor.opacity(0.1))
                                .foregroundStyle(Color.accentColor)
                                .clipShape(Capsule())
                        }
                    }
                }

                Spacer()

                // Add button
                Button {
                    onAdd()
                    hasAdded = true
                    dismiss()
                } label: {
                    HStack {
                        Image(systemName: hasAdded ? "checkmark.circle.fill" : "plus.circle.fill")
                        Text(hasAdded ? "Added" : "Add to My Cards")
                    }
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(hasAdded ? Color.green : Color.accentColor)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .disabled(hasAdded)
            }
            .padding()
            .navigationTitle("Preview Card")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Card Face View

private struct CardFaceView: View {
    let text: String
    let isFront: Bool
    let isFlipped: Bool

    var body: some View {
        VStack {
            Spacer()
            Text(text)
                .font(.title2)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
            Spacer()
            Text(isFront ? "Front" : "Back")
                .font(.caption2)
                .foregroundStyle(.tertiary)
                .padding(.bottom, 8)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 200)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isFront ? Color.accentColor.opacity(0.3) : Color.green.opacity(0.3), lineWidth: 2)
        )
    }
}

#Preview {
    PackCardPreviewView(
        card: PackCard(
            id: "001",
            packId: "test",
            front: "the table",
            back: "der Tisch",
            tags: ["furniture", "home"],
            hint: "Masculine noun (der)",
            example: "Der Tisch ist groß."
        )
    ) {
        print("Card added")
    }
}
