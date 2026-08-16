import SwiftUI

@available(iOS 17.0, *)
struct ExploreView: View {
    @Environment(VelmoStore.self) private var store
    @State private var query = ""
    @State private var activeFilter = "Top"
    private let filters = ["Top", "People", "Posts", "Drawings", "Boards", "Spaces"]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AppTokens.Spacing.xxl) {
                    searchField
                    filterRail
                    interestGrid
                    creators
                    spaces
                }
                .padding(.horizontal, AppTokens.Spacing.screen)
                .padding(.top, AppTokens.Spacing.md)
                .padding(.bottom, AppTokens.Spacing.huge)
            }
            .background(AppTokens.background)
            .navigationTitle("Explore")
        }
    }

    private var searchField: some View {
        HStack(spacing: AppTokens.Spacing.sm) {
            Image(systemName: "magnifyingglass")
                .font(AppTokens.symbolFont)
                .foregroundStyle(AppTokens.secondaryInk)
            TextField("Search people, ideas, boards, and topics", text: $query)
                .font(AppTokens.bodyFont)
            Image(systemName: "mic.fill")
                .font(AppTokens.symbolFont)
                .foregroundStyle(AppTokens.mutedInk)
        }
        .padding(.horizontal, AppTokens.Spacing.md)
        .frame(minHeight: AppTokens.Size.primaryButton)
        .background(AppTokens.surface, in: Capsule())
        .overlay(Capsule().stroke(AppTokens.border, lineWidth: AppTokens.Spacing.xxs / AppTokens.Spacing.xxs))
    }

    private var filterRail: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppTokens.Spacing.xs) {
                ForEach(filters, id: \.self) { filter in
                    TopicChip(title: filter, isSelected: activeFilter == filter) {
                        activeFilter = filter
                    }
                }
            }
        }
        .scrollClipDisabled()
    }

    private var interestGrid: some View {
        VStack(alignment: .leading, spacing: AppTokens.Spacing.md) {
            Text("Explore interests")
                .font(AppTokens.titleFont)
                .foregroundStyle(AppTokens.ink)
            LazyVGrid(columns: gridColumns, spacing: AppTokens.Spacing.sm) {
                InterestPane(title: "Collage club", subtitle: "Fresh ideas", symbol: "square.on.square", color: AppTokens.lavender)
                InterestPane(title: "Photo walks", subtitle: "Around you", symbol: "camera.fill", color: AppTokens.blue)
                InterestPane(title: "Dream rooms", subtitle: "Soft spaces", symbol: "lamp.table.fill", color: AppTokens.sage)
                InterestPane(title: "Tiny rituals", subtitle: "Make it yours", symbol: "sparkles", color: AppTokens.honey)
            }
        }
    }

    private var creators: some View {
        VStack(alignment: .leading, spacing: AppTokens.Spacing.md) {
            Text("People to follow")
                .font(AppTokens.titleFont)
                .foregroundStyle(AppTokens.ink)
            ForEach(store.creators) { creator in
                CardSurface {
                    HStack(spacing: AppTokens.Spacing.sm) {
                        AvatarView(initials: creator.initials, color: creator.color)
                        VStack(alignment: .leading, spacing: AppTokens.Spacing.xxs) {
                            Text(creator.name)
                                .font(AppTokens.headlineFont)
                                .foregroundStyle(AppTokens.ink)
                            Text("@\(creator.handle) · \(creator.focus)")
                                .font(AppTokens.captionFont)
                                .foregroundStyle(AppTokens.secondaryInk)
                        }
                        Spacer()
                        Button(creator.isFollowing ? "Following" : "Follow") {
                            store.toggleFollow(creator.id)
                        }
                        .font(AppTokens.captionFont)
                        .foregroundStyle(creator.isFollowing ? AppTokens.secondaryInk : AppTokens.onAccent)
                        .padding(.horizontal, AppTokens.Spacing.sm)
                        .frame(minHeight: AppTokens.Size.hitTarget)
                        .background(creator.isFollowing ? AppTokens.oatmeal : AppTokens.accent, in: Capsule())
                    }
                }
            }
        }
    }

    private var spaces: some View {
        VStack(alignment: .leading, spacing: AppTokens.Spacing.md) {
            Text("Featured Spaces")
                .font(AppTokens.titleFont)
                .foregroundStyle(AppTokens.ink)
            ForEach(store.spaces) { space in
                CardSurface {
                    HStack(spacing: AppTokens.Spacing.md) {
                        Image(systemName: space.symbol)
                            .font(AppTokens.titleFont)
                            .foregroundStyle(AppTokens.ink)
                            .frame(width: AppTokens.Size.primaryButton, height: AppTokens.Size.primaryButton)
                            .background(space.color.opacity(0.72), in: RoundedRectangle(cornerRadius: AppTokens.controlRadius, style: .continuous))
                        VStack(alignment: .leading, spacing: AppTokens.Spacing.xxs) {
                            Text(space.name)
                                .font(AppTokens.headlineFont)
                                .foregroundStyle(AppTokens.ink)
                            Text("\(space.members.formatted()) members · \(space.description)")
                                .font(AppTokens.captionFont)
                                .foregroundStyle(AppTokens.secondaryInk)
                                .lineLimit(2)
                        }
                        Spacer()
                        Button(space.isJoined ? "Joined" : "Join") {
                            store.toggleSpace(space.id)
                        }
                        .font(AppTokens.captionFont)
                        .foregroundStyle(space.isJoined ? AppTokens.secondaryInk : AppTokens.onAccent)
                        .padding(.horizontal, AppTokens.Spacing.sm)
                        .frame(minHeight: AppTokens.Size.hitTarget)
                        .background(space.isJoined ? AppTokens.oatmeal : AppTokens.accent, in: Capsule())
                    }
                }
            }
        }
    }

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    private var gridColumns: [GridItem] {
        let count = dynamicTypeSize.isAccessibilitySize ? 1 : 2
        return Array(repeating: GridItem(.flexible(), spacing: AppTokens.Spacing.sm), count: count)
    }
}

@available(iOS 17.0, *)
private struct InterestPane: View {
    let title: String
    let subtitle: String
    let symbol: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: AppTokens.Spacing.xs) {
            Image(systemName: symbol)
                .font(AppTokens.titleFont)
                .foregroundStyle(AppTokens.surface)
                .frame(width: AppTokens.Size.primaryButton, height: AppTokens.Size.primaryButton)
                .background(AppTokens.surface.opacity(0.2), in: Circle())
            Spacer()
            Text(title)
                .font(AppTokens.headlineFont)
                .foregroundStyle(AppTokens.surface)
                .lineLimit(2)
            Text(subtitle)
                .font(AppTokens.captionFont)
                .foregroundStyle(AppTokens.surface.opacity(0.88))
        }
        .padding(AppTokens.Spacing.md)
        .frame(minHeight: AppTokens.Size.promptMedia)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(color, in: RoundedRectangle(cornerRadius: AppTokens.cardRadius, style: .continuous))
    }
}

#Preview {
    ExploreView()
        .environment(VelmoStore())
}
