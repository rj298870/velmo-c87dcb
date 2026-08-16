import SwiftUI

@available(iOS 17.0, *)
struct AvatarView: View {
    let initials: String
    let color: Color
    var size: CGFloat = AppTokens.Size.avatar

    var body: some View {
        Text(initials)
            .font(AppTokens.captionFont)
            .foregroundStyle(AppTokens.ink)
            .frame(width: size, height: size)
            .background(color.opacity(0.72), in: Circle())
            .overlay(Circle().stroke(AppTokens.surface, lineWidth: AppTokens.Spacing.xxs))
            .accessibilityLabel("Profile image for \(initials)")
    }
}

@available(iOS 17.0, *)
struct MediaArtworkView: View {
    let palette: [Color]
    let symbol: String
    let title: String
    var compact = false

    var body: some View {
        ZStack {
            LinearGradient(colors: palette, startPoint: .topLeading, endPoint: .bottomTrailing)
            Circle()
                .fill(AppTokens.surface.opacity(0.22))
                .frame(width: artworkCircleSize, height: artworkCircleSize)
                .offset(x: AppTokens.Spacing.xl, y: -AppTokens.Spacing.lg)
            RoundedRectangle(cornerRadius: AppTokens.controlRadius, style: .continuous)
                .fill(AppTokens.surface.opacity(0.26))
                .frame(width: artworkSquareSize, height: artworkSquareSize)
                .rotationEffect(.degrees(-12))
                .offset(x: -AppTokens.Spacing.xl, y: AppTokens.Spacing.lg)
            Image(systemName: symbol)
                .font(AppTokens.displayFont)
                .foregroundStyle(AppTokens.surface)
                .symbolRenderingMode(.hierarchical)
        }
        .frame(height: compact ? AppTokens.Size.compactMedia : AppTokens.Size.media)
        .clipShape(RoundedRectangle(cornerRadius: AppTokens.mediaRadius, style: .continuous))
        .accessibilityLabel("Artwork: \(title)")
    }

    private var artworkCircleSize: CGFloat {
        compact ? AppTokens.Size.hitTarget : AppTokens.Size.primaryButton * 2
    }

    private var artworkSquareSize: CGFloat {
        compact ? AppTokens.Size.hitTarget : AppTokens.Size.primaryButton + AppTokens.Spacing.lg
    }
}

@available(iOS 17.0, *)
struct TopicChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(AppTokens.captionFont)
                .foregroundStyle(isSelected ? AppTokens.onAccent : AppTokens.secondaryInk)
                .padding(.horizontal, AppTokens.Spacing.sm)
                .frame(minHeight: AppTokens.Size.hitTarget)
                .background(isSelected ? AppTokens.accent : AppTokens.oatmeal, in: Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

@available(iOS 17.0, *)
struct PostActionButton: View {
    let title: String
    let symbol: String
    let isActive: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(title, systemImage: symbol)
                .font(AppTokens.captionFont)
                .foregroundStyle(isActive ? AppTokens.accent : AppTokens.secondaryInk)
                .frame(minHeight: AppTokens.Size.hitTarget)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

@available(iOS 17.0, *)
struct BoardCoverView: View {
    let board: InspirationBoard

    var body: some View {
        ZStack {
            LinearGradient(colors: board.palette, startPoint: .topLeading, endPoint: .bottomTrailing)
            HStack(spacing: AppTokens.Spacing.xs) {
                ForEach(board.symbols, id: \.self) { symbol in
                    Image(systemName: symbol)
                        .font(AppTokens.titleFont)
                        .foregroundStyle(AppTokens.surface)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(AppTokens.surface.opacity(0.18), in: RoundedRectangle(cornerRadius: AppTokens.controlRadius, style: .continuous))
                }
            }
            .padding(AppTokens.Spacing.md)
        }
        .frame(height: AppTokens.Size.promptMedia)
        .clipShape(RoundedRectangle(cornerRadius: AppTokens.mediaRadius, style: .continuous))
        .accessibilityLabel("Cover for \(board.title)")
    }
}

@available(iOS 17.0, *)
struct CardSurface<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        content
            .padding(AppTokens.Spacing.md)
            .background(AppTokens.surface, in: RoundedRectangle(cornerRadius: AppTokens.cardRadius, style: .continuous))
            .shadow(color: AppTokens.shadow, radius: AppTokens.Spacing.xs, y: AppTokens.Spacing.xxs)
    }
}
