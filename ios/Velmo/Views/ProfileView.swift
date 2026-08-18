import SwiftUI

@available(iOS 17.0, *)
struct ProfileView: View {
    @Environment(VelmoStore.self) private var store
    @State private var selectedSegment = "Posts"
    @State private var showSettings = false
    @State private var showEditProfile = false
    @State private var selectedInterest: String?
    private let segments = ["Posts", "Creations", "Boards", "Saved", "Spaces"]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AppTokens.Spacing.xl) {
                    profileHero
                    stats
                    interestTags
                    Picker("Profile content", selection: $selectedSegment) {
                        ForEach(segments, id: \.self) { Text($0).tag($0) }
                    }
                    .pickerStyle(.segmented)
                    profileContent
                }
                .padding(.horizontal, AppTokens.Spacing.screen)
                .padding(.top, AppTokens.Spacing.md)
                .padding(.bottom, AppTokens.Spacing.huge)
            }
            .background(AppTokens.background)
            .navigationTitle("Profile")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showSettings = true } label: {
                        Image(systemName: "gearshape")
                            .font(AppTokens.symbolFont)
                            .frame(width: AppTokens.Size.hitTarget, height: AppTokens.Size.hitTarget)
                    }
                    .accessibilityLabel("Settings")
                }
            }
            .sheet(isPresented: $showEditProfile) {
                EditProfileSheet()
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
                    .environment(store)
            }
        }
    }

    private var profileHero: some View {
        VStack(alignment: .leading, spacing: AppTokens.Spacing.md) {
            ZStack(alignment: .bottomLeading) {
                LinearGradient(colors: [AppTokens.oatmeal, AppTokens.lavender], startPoint: .topLeading, endPoint: .bottomTrailing)
                    .frame(height: AppTokens.Size.promptMedia)
                    .clipShape(RoundedRectangle(cornerRadius: AppTokens.cardRadius, style: .continuous))
                AvatarView(initials: profileInitials, color: AppTokens.honey, size: AppTokens.Size.primaryButton + AppTokens.Spacing.md)
                    .padding(AppTokens.Spacing.md)
            }
            VStack(alignment: .leading, spacing: AppTokens.Spacing.xxs) {
                Text(store.profileDisplayName)
                    .font(AppTokens.displayFont)
                    .foregroundStyle(AppTokens.ink)
                Text("@\(store.profileUsername)")
                    .font(AppTokens.bodyFont)
                    .foregroundStyle(AppTokens.secondaryInk)
                Text("Born \(store.profileBirthday.formatted(date: .abbreviated, time: .omitted))")
                    .font(AppTokens.bodyFont)
                    .foregroundStyle(AppTokens.secondaryInk)
            }
            Button("Edit profile") { showEditProfile = true }
                .font(AppTokens.headlineFont)
                .foregroundStyle(AppTokens.accent)
                .frame(maxWidth: .infinity)
                .frame(height: AppTokens.Size.primaryButton)
                .background(AppTokens.oatmeal, in: Capsule())
        }
    }

    private var profileInitials: String {
        let initials = store.profileDisplayName
            .split(whereSeparator: \.isWhitespace)
            .prefix(2)
            .compactMap(\.first)
            .map(String.init)
            .joined()
        return initials.isEmpty ? "V" : initials.uppercased()
    }

    private var stats: some View {
        HStack(spacing: AppTokens.Spacing.sm) {
            ProfileStat(value: "428", label: "Followers")
            ProfileStat(value: "301", label: "Following")
            ProfileStat(value: "1.2k", label: "Inspired")
        }
    }

    private var interestTags: some View {
        VStack(alignment: .leading, spacing: AppTokens.Spacing.sm) {
            Label("Board Builder", systemImage: "sparkles")
                .font(AppTokens.captionFont)
                .foregroundStyle(AppTokens.accent)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppTokens.Spacing.xs) {
                    TopicChip(title: "Collage", isSelected: selectedInterest == "Collage") { selectedInterest = "Collage" }
                    TopicChip(title: "Art", isSelected: selectedInterest == "Art") { selectedInterest = "Art" }
                    TopicChip(title: "Dream rooms", isSelected: selectedInterest == "Dream rooms") { selectedInterest = "Dream rooms" }
                }
            }
        }
    }

    @ViewBuilder
    private var profileContent: some View {
        if selectedSegment == "Boards" {
            LazyVGrid(columns: profileColumns, spacing: AppTokens.Spacing.md) {
                ForEach(store.boards.prefix(4)) { board in
                    BoardCardProxy(board: board)
                }
            }
        } else {
            LazyVGrid(columns: profileColumns, spacing: AppTokens.Spacing.md) {
                ForEach(store.posts.prefix(4)) { post in
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
    }

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    private var profileColumns: [GridItem] {
        let count = dynamicTypeSize.isAccessibilitySize ? 1 : 2
        return Array(repeating: GridItem(.flexible(), spacing: AppTokens.Spacing.md), count: count)
    }
}

@available(iOS 17.0, *)
private struct EditProfileSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var bio = "Making small worlds from scraps, sketches, and sunny corners."

    var body: some View {
        NavigationStack {
            Form {
                Section("About") {
                    TextField("Bio", text: $bio, axis: .vertical)
                        .font(AppTokens.bodyFont)
                        .lineLimit(3...5)
                }
            }
            .navigationTitle("Edit profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") { dismiss() }
                        .foregroundStyle(AppTokens.accent)
                }
            }
        }
    }
}

@available(iOS 17.0, *)
private struct ProfileStat: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: AppTokens.Spacing.xxs) {
            Text(value)
                .font(AppTokens.headlineFont)
                .foregroundStyle(AppTokens.ink)
            Text(label)
                .font(AppTokens.captionFont)
                .foregroundStyle(AppTokens.secondaryInk)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppTokens.Spacing.sm)
        .background(AppTokens.surface, in: RoundedRectangle(cornerRadius: AppTokens.controlRadius, style: .continuous))
    }
}

@available(iOS 17.0, *)
private struct BoardCardProxy: View {
    let board: InspirationBoard

    var body: some View {
        VStack(alignment: .leading, spacing: AppTokens.Spacing.xs) {
            BoardCoverView(board: board)
            Text(board.title)
                .font(AppTokens.captionFont)
                .foregroundStyle(AppTokens.ink)
                .lineLimit(2)
        }
    }
}

#Preview {
    ProfileView()
        .environment(VelmoStore())
}
