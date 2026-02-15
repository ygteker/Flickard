import SwiftUI
import SwiftData

struct StackListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Stack.createdAt) private var stacks: [Stack]
    @State private var showingCreateStack = false

    var body: some View {
        Group {
            if stacks.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "square.stack.3d.up.slash")
                        .font(.largeTitle)
                        .imageScale(.large)
                        .foregroundStyle(.secondary)

                    Text("No Stacks Yet")
                        .font(.title2)
                        .fontWeight(.semibold)

                    Text("Create a stack to organize your cards into focused study groups")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)

                    Button {
                        showingCreateStack = true
                    } label: {
                        Label("Create Stack", systemImage: "plus")
                            .font(.headline)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(Color.accentColor)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(.top, 8)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(stacks) { stack in
                        NavigationLink(destination: StackDetailView(stack: stack)) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(stack.name)
                                        .font(.headline)
                                    Text("\(stack.uniqueCardCount) cards")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }

                                Spacer()

                                if stack.isAIManaged {
                                    Image(systemName: "brain")
                                        .foregroundStyle(.purple)
                                        .font(.caption)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .onDelete(perform: deleteStacks)
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingCreateStack = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingCreateStack) {
            CreateStackView()
        }
    }

    private func deleteStacks(at offsets: IndexSet) {
        for index in offsets {
            let stack = stacks[index]
            modelContext.delete(stack)
        }
        try? modelContext.save()
    }
}

#Preview {
    NavigationStack {
        StackListView()
    }
    .modelContainer(for: [Card.self, Stack.self], inMemory: true)
}
