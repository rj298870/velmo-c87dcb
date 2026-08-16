import SwiftUI

@available(iOS 17.0, *)
struct SaveToBoardSheet: View {
    @Environment(VelmoStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    let post: CreativePost
    @State private var showCreateBoard = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AppTokens.Spacing.xl) {
                    VStack(alignment: .leading, spacing: AppTokens.Spacing.xxs) {
                        Text("Save to a board")
                            .font(AppTokens.titleFont)
                            .foregroundStyle(AppTokens.ink)
                        Text("Keep \(post.title) close for your next idea.")
                            .font(AppTokens.bodyFont)
                            .foregroundStyle(AppTokens.secondaryInk)
                    }
                    ForEach(store.boards) { board in
                        Button {
                            store.save(postID: post.id, to: board.id)
                            dismiss()
                        } label: {
                            HStack(spacing: AppTokens.Spacing.md) {
                                BoardCoverView(board: board)
                                    .frame(width: AppTokens.Size.compactMedia)
                                VStack(alignment: .leading, spacing: AppTokens.Spacing.xxs) {
                                    Text(board.title)
                                        .font(AppTokens.headlineFont)
                                        .foregroundStyle(AppTokens.ink)
                                        .lineLimit(2)
                                    Text("\(board.itemCount) ideas · \(board.privacy)")
                                        .font(AppTokens.captionFont)
                                        .foregroundStyle(AppTokens.secondaryInk)
                                }
                                Spacer()
                                Image(systemName: "plus.circle.fill")
                                    .font(AppTokens.titleFont)
                                    .foregroundStyle(AppTokens.accent)
                            }
                            .frame(minHeight: AppTokens.Size.primaryButton)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(AppTokens.Spacing.screen)
                .padding(.bottom, AppTokens.Spacing.huge)
            }
            .background(AppTokens.background)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("New board") { showCreateBoard = true }
                        .font(AppTokens.headlineFont)
                        .foregroundStyle(AppTokens.accent)
                }
            }
            .sheet(isPresented: $showCreateBoard) {
                CreateBoardSheet()
                    .environment(store)
            }
        }
        .presentationDetents([.medium, .large])
    }
}

@available(iOS 17.0, *)
struct CreateBoardSheet: View {
    @Environment(VelmoStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var privacy = "Private"

    var body: some View {
        NavigationStack {
            Form {
                Section("Board details") {
                    TextField("Board name", text: $title)
                        .font(AppTokens.bodyFont)
                    Picker("Privacy", selection: $privacy) {
                        Text("Private").tag("Private")
                        Text("Friends").tag("Friends")
                        Text("Public").tag("Public")
                    }
                }
                Section {
                    Text("Boards are a calm place for the ideas you want to return to.")
                        .font(AppTokens.bodyFont)
                        .foregroundStyle(AppTokens.secondaryInk)
                }
            }
            .scrollContentBackground(.hidden)
            .background(AppTokens.background)
            .navigationTitle("New board")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Create") {
                        store.createBoard(title: title, privacy: privacy)
                        dismiss()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .foregroundStyle(AppTokens.accent)
                }
            }
        }
    }
}

#Preview {
    SaveToBoardSheet(post: SeedData.posts[0])
        .environment(VelmoStore())
}
