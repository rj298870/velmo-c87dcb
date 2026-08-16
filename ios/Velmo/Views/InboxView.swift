import SwiftUI

@available(iOS 17.0, *)
struct InboxView: View {
    @Environment(VelmoStore.self) private var store
    @State private var selectedRequest: FriendRequest?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppTokens.Spacing.xxl) {
                if !store.friendRequests.isEmpty {
                    requestSection
                }

                ForEach(activityKindsWithItems) { kind in
                    activitySection(kind: kind, activities: activities(for: kind))
                }
            }
            .padding(.horizontal, AppTokens.Spacing.screen)
            .padding(.vertical, AppTokens.Spacing.lg)
            .padding(.bottom, AppTokens.Spacing.huge)
        }
        .background(AppTokens.background)
        .navigationTitle("Inbox")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            store.markInboxRead()
        }
        .sheet(item: $selectedRequest) { request in
            FriendProfileSheet(request: request)
                .environment(store)
        }
    }

    private var activityKindsWithItems: [InboxActivityKind] {
        InboxActivityKind.allCases.filter { !activities(for: $0).isEmpty }
    }

    private func activities(for kind: InboxActivityKind) -> [InboxActivity] {
        store.inboxActivities.filter { $0.kind == kind }
    }

    private var requestSection: some View {
        VStack(alignment: .leading, spacing: AppTokens.Spacing.md) {
            sectionTitle("Friend Requests")
            ForEach(store.friendRequests) { request in
                FriendRequestCard(
                    request: request,
                    onAccept: { store.acceptFriendRequest(request) },
                    onDecline: { store.declineFriendRequest(request) },
                    onProfile: { selectedRequest = request },
                    onBlock: { store.blockFriendRequest(request) },
                    onReport: { store.reportFriendRequest(request) }
                )
            }
        }
    }

    private func activitySection(kind: InboxActivityKind, activities: [InboxActivity]) -> some View {
        VStack(alignment: .leading, spacing: AppTokens.Spacing.md) {
            sectionTitle(kind.rawValue)
            CardSurface {
                VStack(spacing: AppTokens.Spacing.sm) {
                    ForEach(activities) { activity in
                        InboxActivityRow(activity: activity)
                        if activity.id != activities.last?.id {
                            Divider().overlay(AppTokens.border)
                        }
                    }
                }
            }
        }
    }

    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(AppTokens.titleFont)
            .foregroundStyle(AppTokens.ink)
    }
}

@available(iOS 17.0, *)
private struct FriendRequestCard: View {
    let request: FriendRequest
    let onAccept: () -> Void
    let onDecline: () -> Void
    let onProfile: () -> Void
    let onBlock: () -> Void
    let onReport: () -> Void

    var body: some View {
        CardSurface {
            VStack(alignment: .leading, spacing: AppTokens.Spacing.md) {
                HStack(alignment: .top, spacing: AppTokens.Spacing.sm) {
                    AvatarView(initials: request.initials, color: request.color)
                    VStack(alignment: .leading, spacing: AppTokens.Spacing.xxs) {
                        Text(request.name)
                            .font(AppTokens.headlineFont)
                            .foregroundStyle(AppTokens.ink)
                        Text("@\(request.handle)")
                            .font(AppTokens.captionFont)
                            .foregroundStyle(AppTokens.secondaryInk)
                    }
                    Spacer()
                    Menu {
                        Button("Block", role: .destructive, action: onBlock)
                        Button("Report", role: .destructive, action: onReport)
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(AppTokens.symbolFont)
                            .foregroundStyle(AppTokens.secondaryInk)
                            .frame(width: AppTokens.Size.hitTarget, height: AppTokens.Size.hitTarget)
                    }
                    .accessibilityLabel("Safety options for \(request.name)")
                }

                VStack(alignment: .leading, spacing: AppTokens.Spacing.xs) {
                    if let mutualFriends = request.mutualFriends {
                        Label("\(mutualFriends) mutual friends", systemImage: "person.2.fill")
                            .font(AppTokens.captionFont)
                            .foregroundStyle(AppTokens.secondaryInk)
                    }
                    Text(request.bio)
                        .font(AppTokens.bodyFont)
                        .foregroundStyle(AppTokens.ink)
                    Text(request.timestamp)
                        .font(AppTokens.captionFont)
                        .foregroundStyle(AppTokens.mutedInk)
                }

                ViewThatFits(in: .horizontal) {
                    HStack(spacing: AppTokens.Spacing.sm) {
                        actionButtons
                    }
                    VStack(alignment: .leading, spacing: AppTokens.Spacing.sm) {
                        actionButtons
                    }
                }
            }
        }
    }

    private var actionButtons: some View {
        Group {
            Button("Accept", action: onAccept)
                .buttonStyle(VelmoPrimaryButtonStyle())
                .frame(maxWidth: .infinity)
            Button("Decline", action: onDecline)
                .font(AppTokens.headlineFont)
                .foregroundStyle(AppTokens.ink)
                .frame(maxWidth: .infinity, minHeight: AppTokens.Size.primaryButton)
                .overlay(Capsule().stroke(AppTokens.border, lineWidth: 1))
            Button("View Profile", action: onProfile)
                .font(AppTokens.headlineFont)
                .foregroundStyle(AppTokens.accent)
                .frame(minHeight: AppTokens.Size.hitTarget)
        }
    }
}

@available(iOS 17.0, *)
private struct InboxActivityRow: View {
    let activity: InboxActivity

    var body: some View {
        HStack(alignment: .top, spacing: AppTokens.Spacing.sm) {
            Image(systemName: activity.symbol)
                .font(AppTokens.symbolFont)
                .foregroundStyle(AppTokens.ink)
                .frame(width: AppTokens.Size.hitTarget, height: AppTokens.Size.hitTarget)
                .background(activity.color.opacity(0.36), in: Circle())
            VStack(alignment: .leading, spacing: AppTokens.Spacing.xxs) {
                Text(activity.title)
                    .font(AppTokens.headlineFont)
                    .foregroundStyle(AppTokens.ink)
                    .lineLimit(2)
                Text(activity.detail)
                    .font(AppTokens.bodyFont)
                    .foregroundStyle(AppTokens.secondaryInk)
                    .lineLimit(2)
                Text(activity.timestamp)
                    .font(AppTokens.captionFont)
                    .foregroundStyle(AppTokens.mutedInk)
            }
            Spacer(minLength: AppTokens.Spacing.xs)
            if activity.isUnread {
                Circle()
                    .fill(AppTokens.accent)
                    .frame(width: AppTokens.Spacing.xs, height: AppTokens.Spacing.xs)
                    .accessibilityLabel("Unread")
            }
        }
    }
}

@available(iOS 17.0, *)
private struct FriendProfileSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(VelmoStore.self) private var store
    let request: FriendRequest

    var body: some View {
        NavigationStack {
            VStack(spacing: AppTokens.Spacing.xl) {
                AvatarView(initials: request.initials, color: request.color)
                    .scaleEffect(1.6)
                    .padding(.top, AppTokens.Spacing.xl)
                VStack(spacing: AppTokens.Spacing.xs) {
                    Text(request.name)
                        .font(AppTokens.titleFont)
                        .foregroundStyle(AppTokens.ink)
                    Text("@\(request.handle)")
                        .font(AppTokens.bodyFont)
                        .foregroundStyle(AppTokens.secondaryInk)
                    Text(request.bio)
                        .font(AppTokens.bodyFont)
                        .foregroundStyle(AppTokens.ink)
                        .multilineTextAlignment(.center)
                }
                if store.friends.contains(request.handle) {
                    Label("Friends", systemImage: "person.2.fill")
                        .font(AppTokens.headlineFont)
                        .foregroundStyle(AppTokens.accent)
                } else {
                    Button("Accept friend request") {
                        store.acceptFriendRequest(request)
                        dismiss()
                    }
                    .buttonStyle(VelmoPrimaryButtonStyle())
                }
                Spacer()
            }
            .padding(.horizontal, AppTokens.Spacing.screen)
            .background(AppTokens.background)
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done", action: dismiss.callAsFunction)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        InboxView()
            .environment(VelmoStore())
    }
}
