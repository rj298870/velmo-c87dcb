import SwiftUI

@available(iOS 17.0, *)
struct BoardDetailView: View {
    @Environment(VelmoStore.self) private var store
    let board: InspirationBoard
    @State private var sort = "Recently Saved"
    @State private var showInviteConfirmation = false
    @State private var showStudio = false
    private let sorts = ["Recently Saved", "Oldest", "Most Inspired"]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AppTokens.Spacing.xl) {
                    BoardCoverView(board: board)
                        .frame(height: AppTokens.Size.media)
                    VStack(alignment: .leading, spacing: AppTokens.Spacing.xs) {
                        Text(board.title)
                            .font(AppTokens.displayFont)
                            .foregroundStyle(AppTokens.ink)
                            .lineLimit(2)
                        Text(board.description)
                            .font(AppTokens.bodyFont)
                            .foregroundStyle(AppTokens.secondaryInk)
                        Label("\(board.privacy) board · \(board.itemCount) ideas", systemImage: board.privacy == "Public" ? "globe" : "lock.fill")
                            .font(AppTokens.captionFont)
                            .foregroundStyle(AppTokens.secondaryInk)
                    }
                    HStack(spacing: AppTokens.Spacing.sm) {
                        Button("Invite") { showInviteConfirmation = true }
                            .font(AppTokens.headlineFont)
                            .foregroundStyle(AppTokens.accent)
                            .frame(maxWidth: .infinity)
                            .frame(height: AppTokens.Size.primaryButton)
                            .background(AppTokens.oatmeal, in: Capsule())
                        Button("Create from this") { showStudio = true }
                            .buttonStyle(VelmoPrimaryButtonStyle())
                    }
                    Picker("Sort", selection: $sort) {
                        ForEach(sorts, id: \.self) { Text($0).tag($0) }
                    }
                    .pickerStyle(.menu)
                    .font(AppTokens.captionFont)
                    LazyVGrid(columns: contentColumns, spacing: AppTokens.Spacing.md) {
                        ForEach(store.posts) { post in
                            VStack(alignment: .leading, spacing: AppTokens.Spacing.xs) {
                                MediaArtworkView(palette: post.palette, symbol: post.symbol, title: post.title, artworkImageData: post.artworkImageData, compact: true)
                                Text(post.title)
                                    .font(AppTokens.captionFont)
                                    .foregroundStyle(AppTokens.ink)
                                    .lineLimit(2)
                            }
                        }
                    }
                }
                .padding(AppTokens.Spacing.screen)
                .padding(.bottom, AppTokens.Spacing.huge)
            }
            .background(AppTokens.background)
            .navigationTitle("Board")
            .navigationBarTitleDisplayMode(.inline)
            .alert("Invite ready", isPresented: $showInviteConfirmation) {
                Button("Done", role: .cancel) { }
            } message: {
                Text("Choose collaborators from your Velmo connections when sharing is available.")
            }
            .sheet(isPresented: $showStudio) {
                CreateStudioView()
                    .environment(store)
            }
        }
    }

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    private var contentColumns: [GridItem] {
        let count = dynamicTypeSize.isAccessibilitySize ? 1 : 2
        return Array(repeating: GridItem(.flexible(), spacing: AppTokens.Spacing.md), count: count)
    }
}

@available(iOS 17.0, *)
struct PostDetailView: View {
    @Environment(VelmoStore.self) private var store
    let post: CreativePost
    @State private var comment = ""
    @State private var recentComment: String?
    @State private var showSave = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AppTokens.Spacing.xl) {
                    HStack(spacing: AppTokens.Spacing.sm) {
                        AvatarView(initials: post.avatar, color: post.palette.first ?? AppTokens.oatmeal)
                        VStack(alignment: .leading, spacing: AppTokens.Spacing.xxs) {
                            Text(post.name)
                                .font(AppTokens.headlineFont)
                                .foregroundStyle(AppTokens.ink)
                            Text("@\(post.handle) · \(post.kind.rawValue)")
                                .font(AppTokens.captionFont)
                                .foregroundStyle(AppTokens.secondaryInk)
                        }
                    }
                    MediaArtworkView(palette: post.palette, symbol: post.symbol, title: post.title, artworkImageData: post.artworkImageData)
                    VStack(alignment: .leading, spacing: AppTokens.Spacing.sm) {
                        Text(post.title)
                            .font(AppTokens.displayFont)
                            .foregroundStyle(AppTokens.ink)
                        Text(post.caption)
                            .font(AppTokens.bodyFont)
                            .foregroundStyle(AppTokens.secondaryInk)
                    }
                    HStack(spacing: AppTokens.Spacing.lg) {
                        PostActionButton(title: "\(post.inspiredCount)", symbol: post.isInspired ? "heart.fill" : "heart", isActive: post.isInspired) {
                            store.toggleInspired(for: post.id)
                        }
                        PostActionButton(title: "Save", symbol: "bookmark", isActive: post.isSaved) { showSave = true }
                    }
                    VStack(alignment: .leading, spacing: AppTokens.Spacing.md) {
                        Text("Comments")
                            .font(AppTokens.titleFont)
                            .foregroundStyle(AppTokens.ink)
                        CommentRow(name: "Ari Kim", text: "This color palette is beautiful.", initials: "AK", color: AppTokens.lavender)
                        CommentRow(name: "Moss Lane", text: "Saving this for my next mood board!", initials: "ML", color: AppTokens.sage)
                        if let recentComment {
                            CommentRow(name: "Mia Vega", text: recentComment, initials: "MV", color: AppTokens.honey)
                        }
                    }
                }
                .padding(AppTokens.Spacing.screen)
                .padding(.bottom, AppTokens.Spacing.huge)
            }
            .background(AppTokens.background)
            .navigationTitle("Post")
            .navigationBarTitleDisplayMode(.inline)
            .safeAreaInset(edge: .bottom, spacing: 0) {
                HStack(spacing: AppTokens.Spacing.sm) {
                    TextField("Add a kind comment", text: $comment)
                        .font(AppTokens.bodyFont)
                        .padding(.horizontal, AppTokens.Spacing.md)
                        .frame(minHeight: AppTokens.Size.primaryButton)
                        .background(AppTokens.surface, in: Capsule())
                    Button {
                        let trimmedComment = comment.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !trimmedComment.isEmpty else { return }
                        recentComment = trimmedComment
                        comment = ""
                    } label: {
                        Image(systemName: "arrow.up")
                            .font(AppTokens.symbolFont)
                            .foregroundStyle(AppTokens.onAccent)
                            .frame(width: AppTokens.Size.primaryButton, height: AppTokens.Size.primaryButton)
                            .background(AppTokens.accent, in: Circle())
                    }
                    .accessibilityLabel("Post comment")
                    .disabled(comment.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .padding(.horizontal, AppTokens.Spacing.screen)
                .padding(.vertical, AppTokens.Spacing.sm)
                .background(AppTokens.background)
            }
            .sheet(isPresented: $showSave) {
                SaveToBoardSheet(post: post)
                    .environment(store)
            }
        }
    }
}

@available(iOS 17.0, *)
private struct CommentRow: View {
    let name: String
    let text: String
    let initials: String
    let color: Color

    var body: some View {
        HStack(alignment: .top, spacing: AppTokens.Spacing.sm) {
            AvatarView(initials: initials, color: color, size: AppTokens.Size.smallAvatar)
            VStack(alignment: .leading, spacing: AppTokens.Spacing.xxs) {
                Text(name)
                    .font(AppTokens.headlineFont)
                    .foregroundStyle(AppTokens.ink)
                Text(text)
                    .font(AppTokens.bodyFont)
                    .foregroundStyle(AppTokens.secondaryInk)
            }
        }
    }
}

#Preview {
    BoardDetailView(board: SeedData.boards[0])
        .environment(VelmoStore())
}
