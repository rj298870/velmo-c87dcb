import SwiftUI

@available(iOS 17.0, *)
struct VelmoOnboardingView: View {
    @Environment(VelmoStore.self) private var store
    @AppStorage("velmo.hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var step = 0
    @State private var displayName = ""
    @State private var username = ""
    @State private var birthday = Calendar.current.date(byAdding: .year, value: -20, to: .now) ?? .now
    @State private var interests: Set<String> = []

    private let welcomeSlides = [
        OnboardingSlide(symbol: "square.grid.2x2.fill", title: "Keep ideas close", detail: "Save the drawings, photos, and small sparks you want to return to in personal boards."),
        OnboardingSlide(symbol: "pencil.and.scribble", title: "Make it yours", detail: "Sketch with your finger or Pencil, add a photo, or write a thought when inspiration lands."),
        OnboardingSlide(symbol: "person.2.fill", title: "Share with friends", detail: "Follow creative people you love and keep connections calm through a private activity inbox.")
    ]
    private let topics = ["Art", "Vision Boards", "DIY", "Home", "Food", "Gaming", "Travel", "Plants", "Photography", "Drawing"]

    var body: some View {
        ZStack {
            AppTokens.background.ignoresSafeArea()
            switch step {
            case 0...2:
                welcomeContent
            case 3:
                profileContent
            default:
                interestsContent
            }
        }
        .animation(store.reduceMotionEnabled ? nil : .smooth, value: step)
    }

    private var welcomeContent: some View {
        let slide = welcomeSlides[step]

        return VStack(spacing: AppTokens.Spacing.xxl) {
            Spacer()
            ZStack {
                Circle()
                    .fill(AppTokens.accent.opacity(0.12))
                    .frame(width: AppTokens.Size.media, height: AppTokens.Size.media)
                Image(systemName: slide.symbol)
                    .font(AppTokens.displayFont)
                    .foregroundStyle(AppTokens.accent)
                    .symbolRenderingMode(.hierarchical)
            }
            VStack(spacing: AppTokens.Spacing.sm) {
                Text(slide.title)
                    .font(AppTokens.displayFont)
                    .foregroundStyle(AppTokens.ink)
                    .multilineTextAlignment(.center)
                Text(slide.detail)
                    .font(AppTokens.bodyFont)
                    .foregroundStyle(AppTokens.secondaryInk)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            HStack(spacing: AppTokens.Spacing.xs) {
                ForEach(welcomeSlides.indices, id: \.self) { index in
                    Capsule()
                        .fill(index == step ? AppTokens.accent : AppTokens.border)
                        .frame(width: index == step ? AppTokens.Spacing.xl : AppTokens.Spacing.xs, height: AppTokens.Spacing.xxs)
                }
            }
            Spacer()
            Button(step == welcomeSlides.indices.last ? "Set up profile" : "Next") {
                step += 1
            }
            .buttonStyle(VelmoPrimaryButtonStyle())
        }
        .padding(AppTokens.Spacing.screen)
    }

    private var profileContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppTokens.Spacing.xxl) {
                VStack(alignment: .leading, spacing: AppTokens.Spacing.xs) {
                    Text("Your profile")
                        .font(AppTokens.displayFont)
                        .foregroundStyle(AppTokens.ink)
                    Text("A few details make your creative corner feel like home.")
                        .font(AppTokens.bodyFont)
                        .foregroundStyle(AppTokens.secondaryInk)
                }
                CardSurface {
                    VStack(alignment: .leading, spacing: AppTokens.Spacing.md) {
                        TextField("Display name", text: $displayName)
                            .font(AppTokens.bodyFont)
                            .textContentType(.name)
                        Divider()
                        TextField("Username", text: $username)
                            .font(AppTokens.bodyFont)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                        Divider()
                        DatePicker("Birthday", selection: $birthday, displayedComponents: .date)
                            .font(AppTokens.bodyFont)
                    }
                }
            }
            .padding(AppTokens.Spacing.screen)
            .padding(.top, AppTokens.Spacing.huge)
            .padding(.bottom, AppTokens.Spacing.huge)
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            Button("Choose interests") {
                step = 4
            }
            .buttonStyle(VelmoPrimaryButtonStyle())
            .disabled(trimmedDisplayName.isEmpty || trimmedUsername.isEmpty)
            .padding(.horizontal, AppTokens.Spacing.screen)
            .padding(.vertical, AppTokens.Spacing.md)
            .background(AppTokens.background)
        }
    }

    private var interestsContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppTokens.Spacing.xxl) {
                VStack(alignment: .leading, spacing: AppTokens.Spacing.xs) {
                    Text("Your interests")
                        .font(AppTokens.displayFont)
                        .foregroundStyle(AppTokens.ink)
                    Text("Choose a few things you’d love to see more of.")
                        .font(AppTokens.bodyFont)
                        .foregroundStyle(AppTokens.secondaryInk)
                }
                interestChips
            }
            .padding(AppTokens.Spacing.screen)
            .padding(.top, AppTokens.Spacing.huge)
            .padding(.bottom, AppTokens.Spacing.huge)
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            Button("Get started", action: completeOnboarding)
                .buttonStyle(VelmoPrimaryButtonStyle())
                .disabled(interests.isEmpty)
                .padding(.horizontal, AppTokens.Spacing.screen)
                .padding(.vertical, AppTokens.Spacing.md)
                .background(AppTokens.background)
        }
    }

    private var interestChips: some View {
        FlowLayout(spacing: AppTokens.Spacing.xs) {
            ForEach(topics, id: \.self) { topic in
                TopicChip(title: topic, isSelected: interests.contains(topic)) {
                    if interests.contains(topic) {
                        interests.remove(topic)
                    } else {
                        interests.insert(topic)
                    }
                }
            }
        }
    }

    private var trimmedDisplayName: String {
        displayName.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var trimmedUsername: String {
        username.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func completeOnboarding() {
        store.saveOnboardingProfile(
            displayName: trimmedDisplayName,
            username: trimmedUsername,
            birthday: birthday,
            interests: interests.sorted()
        )
        hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "velmo.hasCompletedOnboarding")
    }
}

@available(iOS 17.0, *)
private struct OnboardingSlide {
    let symbol: String
    let title: String
    let detail: String
}

@available(iOS 17.0, *)
private struct FlowLayout: Layout {
    let spacing: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .zero
        var currentX: CGFloat = .zero
        var currentY: CGFloat = .zero
        var rowHeight: CGFloat = .zero

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentX + size.width > maxWidth, currentX > .zero {
                currentX = .zero
                currentY += rowHeight + spacing
                rowHeight = .zero
            }
            currentX += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
        return CGSize(width: maxWidth, height: currentY + rowHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var currentX = bounds.minX
        var currentY = bounds.minY
        var rowHeight: CGFloat = .zero

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentX + size.width > bounds.maxX, currentX > bounds.minX {
                currentX = bounds.minX
                currentY += rowHeight + spacing
                rowHeight = .zero
            }
            subview.place(at: CGPoint(x: currentX, y: currentY), proposal: ProposedViewSize(size))
            currentX += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}

#Preview {
    VelmoOnboardingView()
        .environment(VelmoStore())
}
