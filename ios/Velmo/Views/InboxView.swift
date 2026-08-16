import SwiftUI

@available(iOS 17.0, *)
struct InboxView: View {
    @Environment(VelmoStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @State private var profileToView: FriendRequest?
    @State private var requestToBlock: FriendRequest?
    @State private var requestToReport: FriendRequest?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AppTokens.Spacing.xxl) {
                    if !store.pendingFriendRequests.isEmpty {
                        friendRequestsSection
                    }
                    ForEach(otherSections) { section in
                        let items = store.notifications(for: section)
                        if !items.isEmpty {
                            activitySection(section, items: items)
                        }
                    }
                    if store.pendingFriendRequests.isEmpty && otherSections.allSatisfy({ store.notifications(for: $0).isEmpty }) {
                        emptyState
                    }
                }
                .padding(.horizontal, AppTokens.Spacing.screen)
                .padding(.top, AppTokens.Spacing.md)
                .padding(.bottom, AppTokens.Spacing.huge)
            }
            .background(AppTokens.background)
            .navigationTitle("Inbox")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Done") { dismiss() }
                        .font(AppTokens.headlineFont)
                        .foregroundStyle(AppTokens.accent)
                }
            }
            .sheet(item: $profileToView) { request in
                FriendProfilePreview(request: request)
                    .environment(store)
            }
            .confirmationDialog(
                "Block @\(requestToBlock?.handle ?? "")?",
                isPresented: Binding(get: { requestToBlock != nil }, set: { if !$0 { requestToBlock = nil } }),
                titleVisibility: .visible
            ) {
                Button("Block", role: .destructive) {
                    if let handle = requestToBlock?.handle {
                        store.blockUser(handle: handle)
                    }
                    requestToBlock = nil
                }
                Button("Cancel", role: .cancel) { requestToBlock = nil }
            } message: {
                Text("They won't be able to send you friend requests or see your friends-only posts.")
            }
            .confirmationDialog(
                "Report @\(requestToReport?.handle ?? "")?",
                isPresented: Binding(get: { requestToReport != nil }, set: { if !$0 { requestToReport = nil } }),
                titleVisibility: .visible
            ) {
                Button("Report", role: .destructive) {
                    if let handle = requestToReport?.handle {
                        store.reportUser(handle: handle)
                    }
                    requestToReport = nil
                }
                Button("Cancel", role: .cancel) { requestToReport = nil }
            } message: {
                Text("Our team will review this request. This won't notify the sender.")
            }
        }
    }

    private var otherSections: [InboxSection] {
        InboxSection.allCases.filter { $0 != .friendRequests }
    }

    private var friendRequestsSection: some View {
        VStack(alignment: .leading, spacing: AppTokens.Spacing.md) {
            Text(InboxSection.friendRequests.rawValue)
                .font(AppTokens.titleFont)
                .foregroundStyle(AppTokens.ink)
            VStack(spacing: AppTokens.Spacing.sm) {
                ForEach(store.pendingFriendRequests) { request in
                    FriendRequestCard(
                        request: request,
                        onAccept: { store.acceptFriendRequest(request.id) },
                        onDecline: { store.declineFriendRequest(request.id) },
                        onViewProfile: { profileToView = request },
                        onBlock: { requestToBlock = request },
                        onReport: { requestToReport = request }
                    )
                }
            }
        }
    }

    private func activitySection(_ section: InboxSection, items: [InboxNotification]) -> some View {
        VStack(alignment: .leading, spacing: AppTokens.Spacing.md) {
            Text(section.rawValue)
                .font(AppTokens.titleFont)
                .foregroundStyle(AppTokens.ink)
            VStack(spacing: AppTokens.Spacing.sm) {
                ForEach(items) { item in
                    InboxNotificationRow(item: item)
                        .onTapGesture { store.markInboxNotificationRead(item.id) }
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: AppTokens.Spacing.sm) {
            Image(systemName: "tray")
                .font(AppTokens.displayFont)
                .foregroundStyle(AppTokens.mutedInk)
            Text("You're all caught up")
                .font(AppTokens.headlineFont)
                .foregroundStyle(AppTokens.ink)
            Text("Friend requests and activity will show up here.")
                .font(AppTokens.bodyFont)
                .foregroundStyle(AppTokens.secondaryInk)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, AppTokens.Spacing.huge)
    }
}

@available(iOS 17.0, *)
private struct FriendRequestCard: View {
    @Environment(VelmoStore.self) private var store
    let request: FriendRequest
    let onAccept: () -> Void
    let onDecline: () -> Void
    let onViewProfile: () -> Void
    let onBlock: () -> Void
    let onReport: () -> Void

    var body: some View {
        CardSurface {
            VStack(alignment: .leading, spacing: AppTokens.Spacing.sm) {
                HStack(alignment: .top, spacing: AppTokens.Spacing.sm) {
                    AvatarView(initials: request.initials, color: request.color)
                    VStack(alignment: .leading, spacing: AppTokens.Spacing.xxs) {
                        Text(request.name)
                            .font(AppTokens.headlineFont)
                            .foregroundStyle(AppTokens.ink)
                        Text("@\(request.handle)")
                            .font(AppTokens.captionFont)
                            .foregroundStyle(AppTokens.secondaryInk)
                        if request.mutualFriends > 0 {
                            Text("\(request.mutualFriends) mutual friend\(request.mutualFriends == 1 ? "" : "s")")
                                .font(AppTokens.captionFont)
                                .foregroundStyle(AppTokens.secondaryInk)
                        }
                    }
                    Spacer()
                    Menu {
                        Button(role: .destructive, action: onBlock) {
                            Label("Block", systemImage: "hand.raised.fill")
                        }
                        Button(role: .destructive, action: onReport) {
                            Label("Report", systemImage: "flag.fill")
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(AppTokens.symbolFont)
                            .foregroundStyle(AppTokens.secondaryInk)
                            .frame(width: AppTokens.Size.hitTarget, height: AppTokens.Size.hitTarget)
                            .contentShape(Rectangle())
                    }
                    .accessibilityLabel("Safety options for @\(request.handle)")
                }
                Text(request.bioOrSharedInterests)
                    .font(AppTokens.bodyFont)
                    .foregroundStyle(AppTokens.secondaryInk)
                    .lineLimit(2)
                Text(request.receivedAt.velmoRelativeTime)
                    .font(AppTokens.captionFont)
                    .foregroundStyle(AppTokens.mutedInk)
                HStack(spacing: AppTokens.Spacing.sm) {
                    Button("Accept", action: onAccept)
                        .buttonStyle(VelmoPrimaryButtonStyle())
                    Button("Decline", action: onDecline)
                        .font(AppTokens.headlineFont)
                        .foregroundStyle(AppTokens.ink)
                        .frame(maxWidth: .infinity)
                        .frame(height: AppTokens.Size.primaryButton)
                        .overlay(
                            Capsule().stroke(AppTokens.border, lineWidth: 1)
                        )
                }
                Button("View Profile", action: onViewProfile)
                    .font(AppTokens.captionFont)
                    .foregroundStyle(AppTokens.accent)
                    .frame(minHeight: AppTokens.Size.hitTarget)
            }
        }
    }
}

@available(iOS 17.0, *)
private struct InboxNotificationRow: View {
    let item: InboxNotification

    var body: some View {
        CardSurface {
            HStack(alignment: .top, spacing: AppTokens.Spacing.sm) {
                Image(systemName: item.kind.symbol)
                    .font(AppTokens.symbolFont)
                    .foregroundStyle(AppTokens.accent)
                    .frame(width: AppTokens.Size.smallAvatar, height: AppTokens.Size.smallAvatar)
                    .background(AppTokens.oatmeal, in: Circle())
                VStack(alignment: .leading, spacing: AppTokens.Spacing.xxs) {
                    Text(item.title)
                        .font(AppTokens.headlineFont)
                        .foregroundStyle(AppTokens.ink)
                        .lineLimit(2)
                    Text(item.subtitle)
                        .font(AppTokens.captionFont)
                        .foregroundStyle(AppTokens.secondaryInk)
                        .lineLimit(2)
                    Text(item.receivedAt.velmoRelativeTime)
                        .font(AppTokens.captionFont)
                        .foregroundStyle(AppTokens.mutedInk)
                }
                Spacer(minLength: 0)
                if !item.isRead {
                    Circle()
                        .fill(AppTokens.accent)
                        .frame(width: AppTokens.Spacing.xs, height: AppTokens.Spacing.xs)
                }
            }
        }
    }
}

@available(iOS 17.0, *)
private struct FriendProfilePreview: View {
    @Environment(VelmoStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    let request: FriendRequest

    var body: some View {
        NavigationStack {
            VStack(spacing: AppTokens.Spacing.md) {
                AvatarView(initials: request.initials, color: request.color, size: AppTokens.Size.primaryButton * 1.4)
                Text(request.name)
                    .font(AppTokens.titleFont)
                    .foregroundStyle(AppTokens.ink)
                Text("@\(request.handle)")
                    .font(AppTokens.bodyFont)
                    .foregroundStyle(AppTokens.secondaryInk)
                Text(request.bioOrSharedInterests)
                    .font(AppTokens.bodyFont)
                    .foregroundStyle(AppTokens.secondaryInk)
                    .multilineTextAlignment(.center)
                if request.mutualFriends > 0 {
                    Text("\(request.mutualFriends) mutual friend\(request.mutualFriends == 1 ? "" : "s")")
                        .font(AppTokens.captionFont)
                        .foregroundStyle(AppTokens.mutedInk)
                }
                Spacer()
            }
            .padding(AppTokens.Spacing.xl)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(AppTokens.background)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(AppTokens.accent)
                }
            }
        }
        .presentationDetents([.medium])
    }
}

private extension Date {
    var velmoRelativeTime: String {
        let interval = Date().timeIntervalSince(self)
        switch interval {
        case ..<60: return "Just now"
        case ..<3600: return "\(Int(interval / 60))m ago"
        case ..<86_400: return "\(Int(interval / 3600))h ago"
        default: return "\(Int(interval / 86_400))d ago"
        }
    }
}

#Preview {
    InboxView()
        .environment(VelmoStore())
}
