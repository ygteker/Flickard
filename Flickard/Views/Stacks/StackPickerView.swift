import SwiftUI
import SwiftData

struct StackPickerView: View {
    let stacks: [Stack]
    @Binding var selectedStackID: UUID?

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(stacks) { stack in
                    let isSelected = selectedStackID == stack.id

                    Button {
                        if selectedStackID == stack.id {
                            selectedStackID = nil
                        } else {
                            selectedStackID = stack.id
                        }
                    } label: {
                        HStack(spacing: 6) {
                            if stack.isAIManaged {
                                Image(systemName: "brain")
                                    .font(.caption2)
                            }
                            Text(stack.name)
                                .font(.subheadline)
                                .fontWeight(isSelected ? .semibold : .regular)
                            Text("\(stack.uniqueCardCount)")
                                .font(.caption2)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(
                                    Capsule()
                                        .fill(isSelected ? Color.white.opacity(0.3) : Color.secondary.opacity(0.2))
                                )
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(isSelected ? Color.accentColor : Color(.systemGray5))
                        )
                        .foregroundStyle(isSelected ? .white : .primary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
    }
}

#Preview {
    StackPickerView(
        stacks: [],
        selectedStackID: .constant(nil)
    )
}
