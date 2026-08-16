import SwiftUI

@available(iOS 17.0, *)
struct HomeView: View {
    @Environment(VelmoStore.self) private var store
    @State private var selectedPost: CreativePost?
    @State private var postToSave: CreativePost?
    @State private var showPromptStudio = false
    private let topics = ["All", "Art", "Vision Boards", "DIY", "Home", "Food", "Gaming", "Travel", "Plants", "Photography"]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AppTokens.Spacing.xxl) {
                    feedSwitcher
                    topicRail
                    creativePrompt
                    feed
                }
                .padding(.horizontal, AppTokens.Spacing.screen)
                .padding(.top, AppTokens.Spacing.md)
                .padding(.bottom, AppTokens.Spacing.huge)
            }
            .background(AppTokens.background)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text("velmo")
                        .font(AppTokens.titleFont)
                        .foregroundStyle(AppTokens.ink)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showPromptStudio = true } label: {
                        Image(systemName: "plus")
                            .font(AppTokens.symbolFont)
                            .foregroundStyle(AppTokens.onAccent)
                            .frame(width: AppTokens.Size.hitTarget, height: AppTokens.Size.hitTarget)
                            .background(AppTokens.accent, in: Circle())
                    }
                    .accessibilityLabel("Create something")
                }
            }
            .sheet(item: $selectedPost) { post in
                PostDetailView(post: post)
                    .environment(store)
            }
            .sheet(item: $postToSave) { post in
                SaveToBoardSheet(post: post)
                    .environment(store)
            }
            .sheet(isPresented: $showPromptStudio) {
                CreateStudioView()
                    .environment(store)
            }
        }
    }

    private var feedSwitcher: some View {
        Picker("Feed", selection: Bindable(store).feedMode) {
            Text("For You").tag("For You")
            Text("Following").tag("Following")
        }
        .pickerStyle(.segmented)
        .accessibilityLabel("Feed selection")
    }

    private var topicRail: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppTokens.Spacing.xs) {
                ForEach(topics, id: \.self) { topic in
                    TopicChip(title: topic, isSelected: store.selectedTopic == topic) {
                        store.selectedTopic = topic
                    }
                }
            }
        }
        .scrollClipDisabled()
    }

    private var creativePrompt: some View {
        CardSurface {
            HStack(spacing: AppTokens.Spacing.md) {
                VStack(alignment: .leading, spacing: AppTokens.Spacing.xs) {
                    Text("Today’s prompt")
                        .font(AppTokens.captionFont)
                        .foregroundStyle(AppTokens.secondaryInk)
                    Text("Create your perfect Sunday.")
                        .font(AppTokens.titleFont)
                        .foregroundStyle(AppTokens.ink)
                        .lineLimit(2)
                    Button("Start creating") { showPromptStudio = true }
                        .font(AppTokens.headlineFont)
                        .foregroundStyle(AppTokens.accent)
                        .frame(minHeight: AppTokens.Size.hitTarget)
                }
                Spacer(minLength: AppTokens.Spacing.md)
                MediaArtworkView(palette: [AppTokens.honey, AppTokens.accent], symbol: "sun.max.fill", title: "Sunday prompt", compact: true)
                    .frame(width: AppTokens.Size.compactMedia)
            }
        }
    }

    private var feed: some View {
        LazyVStack(spacing: AppTokens.Spacing.xl) {
            ForEach(filteredPosts) { post in
                PostCard(post: post, onOpen: { selectedPost = post }, onSave: { postToSave = post })
                    .environment(store)
            }
        }
    }

    private var filteredPosts: [CreativePost] {
        store.selectedTopic == "All" ? store.posts : store.posts.filter { $0.topic == store.selectedTopic }
    }
}

@available(iOS 17.0, *)
private struct PostCard: View {
    @Environment(VelmoStore.self) private var store
    let post: CreativePost
    let onOpen: () -> Void
    let onSave: () -> Void

    var body: some View {
        CardSurface {
            VStack(alignment: .leading, spacing: AppTokens.Spacing.md) {
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
                    Spacer()
                    Text(post.topic)
                        .font(AppTokens.captionFont)
                        .foregroundStyle(AppTokens.secondaryInk)
                        .padding(.horizontal, AppTokens.Spacing.xs)
                        .frame(minHeight: AppTokens.Size.hitTarget)
                        .background(AppTokens.oatmeal, in: Capsule())
                }
                Button(action: onOpen) {
                    MediaArtworkView(palette: post.palette, symbol: post.symbol, title: post.title)
                }
                .buttonStyle(.plain)
                VStack(alignment: .leading, spacing: AppTokens.Spacing.xs) {
                    Text(post.title)
                        .font(AppTokens.titleFont)
                        .foregroundStyle(AppTokens.ink)
                        .lineLimit(2)
                    Text(post.caption)
                        .font(AppTokens.bodyFont)
                        .foregroundStyle(AppTokens.secondaryInk)
                        .lineLimit(3)
                    if let boardName = post.boardName {
                        Label(boardName, systemImage: "bookmark.fill")
                            .font(AppTokens.captionFont)
                            .foregroundStyle(AppTokens.secondaryInk)
                    }
                }
                HStack(spacing: AppTokens.Spacing.md) {
                    PostActionButton(title: "\(post.inspiredCount)", symbol: post.isInspired ? "heart.fill" : "heart", isActive: post.isInspired) {
                        store.toggleInspired(for: post.id)
                    }
                    PostActionButton(title: "\(post.commentCount)", symbol: "bubble", isActive: false, action: onOpen)
                    PostActionButton(title: post.isSaved ? "Saved" : "Save", symbol: post.isSaved ? "bookmark.fill" : "bookmark", isActive: post.isSaved, action: onSave)
                    PostActionButton(title: "Share", symbol: "square.and.arrow.up", isActive: false, action: onOpen)
                }
            }
        }
    }
}

#Preview {
    HomeView()
        .environment(VelmoStore())
}
