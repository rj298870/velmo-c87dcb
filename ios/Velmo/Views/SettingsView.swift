import SwiftUI

@available(iOS 17.0, *)
struct SettingsView: View {
    @Environment(VelmoStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @State private var comments = "People you follow"
    @State private var showLogoutConfirmation = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Account") {
                    Label(store.profileDisplayName, systemImage: "person.crop.circle")
                        .font(AppTokens.bodyFont)
                }

                Section("Privacy") {
                    Toggle(
                        "Private profile",
                        isOn: Binding(
                            get: { store.profileIsPrivate },
                            set: { store.updateProfilePrivacy($0) }
                        )
                    )
                    Picker("Who can comment", selection: $comments) {
                        Text("Everyone").tag("Everyone")
                        Text("People you follow").tag("People you follow")
                        Text("No one").tag("No one")
                    }
                    NavigationLink {
                        BoardVisibilityView()
                            .environment(store)
                    } label: {
                        Label("Board visibility", systemImage: "lock")
                    }
                    Label("Create from my posts", systemImage: "paintbrush")
                }

                Section("Notifications") {
                    Label("Creative activity", systemImage: "bell")
                    Label("Board invites", systemImage: "person.2")
                }

                Section("Accessibility") {
                    Toggle(
                        "Image descriptions",
                        isOn: Binding(
                            get: { store.imageDescriptionsEnabled },
                            set: { store.updateImageDescriptions($0) }
                        )
                    )
                    Toggle(
                        "Reduce motion",
                        isOn: Binding(
                            get: { store.reduceMotionEnabled },
                            set: { store.updateReduceMotion($0) }
                        )
                    )
                }

                Section("Safety") {
                    NavigationLink {
                        BlockedUsersView()
                            .environment(store)
                    } label: {
                        Label("Blocked users", systemImage: "hand.raised")
                    }
                    NavigationLink {
                        CommunityRulesView()
                    } label: {
                        Label("Community rules", systemImage: "checklist")
                    }
                    NavigationLink {
                        ProblemReportView()
                            .environment(store)
                    } label: {
                        Label("Report a problem", systemImage: "exclamationmark.bubble")
                    }
                }

                Section {
                    Button("Log out", role: .destructive) {
                        showLogoutConfirmation = true
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(AppTokens.background)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(AppTokens.accent)
                }
            }
            .alert("Log out?", isPresented: $showLogoutConfirmation) {
                Button("Log out", role: .destructive) {
                    store.logOut()
                    dismiss()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Your local profile setup will be cleared, and Velmo will open onboarding next.")
            }
        }
    }
}

@available(iOS 17.0, *)
private struct BoardVisibilityView: View {
    @Environment(VelmoStore.self) private var store

    var body: some View {
        Form {
            Picker(
                "Default visibility",
                selection: Binding(
                    get: { store.boardVisibility },
                    set: { store.updateBoardVisibility($0) }
                )
            ) {
                Text("Public").tag("Public")
                Text("Followers").tag("Followers")
                Text("Private").tag("Private")
            }
            .pickerStyle(.inline)
        }
        .scrollContentBackground(.hidden)
        .background(AppTokens.background)
        .navigationTitle("Board visibility")
        .navigationBarTitleDisplayMode(.inline)
    }
}

@available(iOS 17.0, *)
private struct BlockedUsersView: View {
    @Environment(VelmoStore.self) private var store

    var body: some View {
        List {
            if store.blockedUsers.isEmpty {
                ContentUnavailableView(
                    "No blocked users",
                    systemImage: "hand.raised",
                    description: Text("People you block from friend requests will appear here.")
                )
                .listRowBackground(AppTokens.background)
            } else {
                ForEach(store.blockedUsers) { user in
                    HStack(spacing: AppTokens.Spacing.sm) {
                        AvatarView(initials: user.initials, color: AppTokens.oatmeal)
                        VStack(alignment: .leading, spacing: AppTokens.Spacing.xxs) {
                            Text(user.name)
                                .font(AppTokens.headlineFont)
                                .foregroundStyle(AppTokens.ink)
                            Text("@\(user.handle)")
                                .font(AppTokens.captionFont)
                                .foregroundStyle(AppTokens.secondaryInk)
                        }
                        Spacer()
                        Button("Unblock") {
                            store.unblock(user)
                        }
                        .font(AppTokens.headlineFont)
                        .foregroundStyle(AppTokens.accent)
                        .frame(minHeight: AppTokens.Size.hitTarget)
                    }
                    .padding(.vertical, AppTokens.Spacing.xxs)
                    .listRowBackground(AppTokens.surface)
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(AppTokens.background)
        .navigationTitle("Blocked users")
        .navigationBarTitleDisplayMode(.inline)
    }
}

@available(iOS 17.0, *)
private struct CommunityRulesView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppTokens.Spacing.xl) {
                rulesCard(
                    title: "Be kind",
                    detail: "Share feedback that helps people keep making things. Harassment and hateful language do not belong here."
                )
                rulesCard(
                    title: "Share what is yours",
                    detail: "Post your own work or give clear credit when you are inspired by someone else’s ideas."
                )
                rulesCard(
                    title: "Keep it welcoming",
                    detail: "Use reports and blocks to help protect the calm, creative space everyone deserves."
                )
            }
            .padding(AppTokens.Spacing.screen)
            .padding(.bottom, AppTokens.Spacing.huge)
        }
        .background(AppTokens.background)
        .navigationTitle("Community rules")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func rulesCard(title: String, detail: String) -> some View {
        CardSurface {
            VStack(alignment: .leading, spacing: AppTokens.Spacing.xs) {
                Text(title)
                    .font(AppTokens.headlineFont)
                    .foregroundStyle(AppTokens.ink)
                Text(detail)
                    .font(AppTokens.bodyFont)
                    .foregroundStyle(AppTokens.secondaryInk)
            }
        }
    }
}

@available(iOS 17.0, *)
private struct ProblemReportView: View {
    @Environment(VelmoStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @State private var message = ""
    @State private var didSubmit = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppTokens.Spacing.xl) {
                Text("Tell us what happened")
                    .font(AppTokens.titleFont)
                    .foregroundStyle(AppTokens.ink)
                Text("Your note stays on this device in this local demo.")
                    .font(AppTokens.bodyFont)
                    .foregroundStyle(AppTokens.secondaryInk)
                CardSurface {
                    TextField("Describe the problem", text: $message, axis: .vertical)
                        .font(AppTokens.bodyFont)
                        .lineLimit(4...8)
                }
            }
            .padding(AppTokens.Spacing.screen)
            .padding(.bottom, AppTokens.Spacing.huge)
        }
        .background(AppTokens.background)
        .navigationTitle("Report a problem")
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            Button("Submit report") {
                store.submitProblemReport(message)
                didSubmit = true
            }
            .buttonStyle(VelmoPrimaryButtonStyle())
            .disabled(message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            .padding(.horizontal, AppTokens.Spacing.screen)
            .padding(.vertical, AppTokens.Spacing.md)
            .background(AppTokens.background)
        }
        .alert("Report saved", isPresented: $didSubmit) {
            Button("Done") { dismiss() }
        } message: {
            Text("Thank you for helping improve Velmo.")
        }
    }
}

#Preview {
    SettingsView()
        .environment(VelmoStore())
}
