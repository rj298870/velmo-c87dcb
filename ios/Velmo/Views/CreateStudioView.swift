import SwiftUI
import PencilKit

@available(iOS 17.0, *)
struct CreateStudioView: View {
    @Environment(VelmoStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @State private var phase: StudioPhase = .start
    @State private var selectedTemplate = "Mood Board"
    @State private var canvas = PKCanvasView()
    @State private var selectedInk = AppTokens.ink
    @State private var brushWidth = AppTokens.Spacing.xxs
    @State private var isErasing = false
    @State private var drawingImage: UIImage?
    private let templates = ["Mood Board", "Dream Room", "Weekly Goals", "Recipe Card", "Travel Memories", "Scrapbook Page"]
    private let inkColors = [AppTokens.ink, AppTokens.accent, AppTokens.lavender, AppTokens.blue, AppTokens.sage, AppTokens.honey]

    var body: some View {
        NavigationStack {
            Group {
                switch phase {
                case .start:
                    startContent
                case .templates:
                    templateContent
                case .drawing:
                    drawingContent
                case .editor:
                    editorContent
                }
            }
            .background(AppTokens.background)
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") { dismiss() }
                        .font(AppTokens.bodyFont)
                }
                if phase == .drawing {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Finish Drawing", action: finishDrawing)
                            .font(AppTokens.headlineFont)
                            .foregroundStyle(AppTokens.accent)
                    }
                }
                if phase == .editor {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Post") {
                            store.publishDraft(artworkImageData: drawingImage?.pngData())
                            dismiss()
                        }
                        .font(AppTokens.headlineFont)
                        .foregroundStyle(AppTokens.accent)
                    }
                }
            }
        }
    }

    private var navigationTitle: String {
        switch phase {
        case .editor:
            "Create"
        case .drawing:
            "Drawing"
        case .start, .templates:
            "Create something"
        }
    }

    private var startContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppTokens.Spacing.xxl) {
                MediaArtworkView(palette: [AppTokens.lavender, AppTokens.accent], symbol: "paintbrush.pointed.fill", title: "Create studio")
                VStack(alignment: .leading, spacing: AppTokens.Spacing.xs) {
                    Text("Start with a feeling")
                        .font(AppTokens.displayFont)
                        .foregroundStyle(AppTokens.ink)
                    Text("Bring together photos, colors, and little ideas into something that feels like you.")
                        .font(AppTokens.bodyFont)
                        .foregroundStyle(AppTokens.secondaryInk)
                }
                VStack(spacing: AppTokens.Spacing.sm) {
                    studioAction("Start drawing", symbol: "pencil.and.scribble") { phase = .drawing }
                    studioAction("Make a collage", symbol: "square.on.square") { phase = .templates }
                    studioAction("Use a template", symbol: "sparkles") { phase = .templates }
                }
                CardSurface {
                    HStack(spacing: AppTokens.Spacing.sm) {
                        Image(systemName: "folder.fill")
                            .font(AppTokens.titleFont)
                            .foregroundStyle(AppTokens.accent)
                        VStack(alignment: .leading, spacing: AppTokens.Spacing.xxs) {
                            Text("My Creations")
                                .font(AppTokens.headlineFont)
                                .foregroundStyle(AppTokens.ink)
                            Text("12 saved drafts and posted collages")
                                .font(AppTokens.captionFont)
                                .foregroundStyle(AppTokens.secondaryInk)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(AppTokens.captionFont)
                            .foregroundStyle(AppTokens.mutedInk)
                    }
                }
            }
            .padding(AppTokens.Spacing.screen)
            .padding(.bottom, AppTokens.Spacing.huge)
        }
    }

    private var templateContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppTokens.Spacing.xl) {
                Text("Templates")
                    .font(AppTokens.titleFont)
                    .foregroundStyle(AppTokens.ink)
                LazyVGrid(columns: templateColumns, spacing: AppTokens.Spacing.md) {
                    ForEach(templates, id: \.self) { template in
                        Button {
                            selectedTemplate = template
                            drawingImage = nil
                            phase = .editor
                        } label: {
                            TemplateCard(title: template, isSelected: selectedTemplate == template)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(AppTokens.Spacing.screen)
            .padding(.bottom, AppTokens.Spacing.huge)
        }
    }

    private var drawingContent: some View {
        DrawingCanvasView(canvas: canvas, color: selectedInk, brushWidth: brushWidth, isErasing: isErasing)
            .clipShape(RoundedRectangle(cornerRadius: AppTokens.mediaRadius, style: .continuous))
            .padding(AppTokens.Spacing.screen)
            .safeAreaInset(edge: .bottom, spacing: 0) {
                drawingTools
            }
    }

    private var drawingTools: some View {
        VStack(spacing: AppTokens.Spacing.sm) {
            HStack(spacing: AppTokens.Spacing.xs) {
                ForEach(inkColors.indices, id: \.self) { index in
                    Button {
                        selectedInk = inkColors[index]
                        isErasing = false
                    } label: {
                        Circle()
                            .fill(inkColors[index])
                            .frame(width: AppTokens.Size.hitTarget, height: AppTokens.Size.hitTarget)
                            .overlay {
                                Circle().stroke(AppTokens.surface, lineWidth: selectedInk == inkColors[index] && !isErasing ? AppTokens.Spacing.xxs : 0)
                            }
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Select ink color")
                }
            }
            HStack(spacing: AppTokens.Spacing.sm) {
                ForEach([AppTokens.Spacing.xxs, AppTokens.Spacing.xs, AppTokens.Spacing.sm], id: \.self) { width in
                    Button {
                        brushWidth = width
                        isErasing = false
                    } label: {
                        Circle()
                            .fill(AppTokens.ink)
                            .frame(width: width * AppTokens.Spacing.xxs, height: width * AppTokens.Spacing.xxs)
                            .frame(width: AppTokens.Size.hitTarget, height: AppTokens.Size.hitTarget)
                            .background(brushWidth == width && !isErasing ? AppTokens.oatmeal : AppTokens.surface, in: Circle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Select brush size")
                }
                Spacer()
                Button {
                    isErasing.toggle()
                } label: {
                    Label("Erase", systemImage: "eraser.fill")
                        .font(AppTokens.headlineFont)
                        .foregroundStyle(isErasing ? AppTokens.onAccent : AppTokens.ink)
                        .frame(minHeight: AppTokens.Size.hitTarget)
                        .padding(.horizontal, AppTokens.Spacing.sm)
                        .background(isErasing ? AppTokens.accent : AppTokens.oatmeal, in: Capsule())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(AppTokens.Spacing.md)
        .background(AppTokens.surface)
    }

    private var editorContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppTokens.Spacing.xl) {
                artworkPreview
                CardSurface {
                    VStack(alignment: .leading, spacing: AppTokens.Spacing.sm) {
                        Text(selectedTemplate)
                            .font(AppTokens.titleFont)
                            .foregroundStyle(AppTokens.ink)
                        Text("Your canvas is ready. Add a thought, then choose where it belongs.")
                            .font(AppTokens.bodyFont)
                            .foregroundStyle(AppTokens.secondaryInk)
                    }
                }
                TextField("Share an idea, moment, or creation…", text: Bindable(store).draftCaption, axis: .vertical)
                    .font(AppTokens.bodyFont)
                    .lineLimit(4...7)
                    .padding(AppTokens.Spacing.md)
                    .background(AppTokens.surface, in: RoundedRectangle(cornerRadius: AppTokens.cardRadius, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: AppTokens.cardRadius, style: .continuous).stroke(AppTokens.border, lineWidth: AppTokens.Spacing.xxs / AppTokens.Spacing.xxs))
                HStack(spacing: AppTokens.Spacing.sm) {
                    ToolPill(title: "Photos", symbol: "photo.on.rectangle")
                    ToolPill(title: "Text", symbol: "textformat")
                    ToolPill(title: "Colors", symbol: "paintpalette")
                }
                Button("Save to Drafts") { dismiss() }
                    .font(AppTokens.headlineFont)
                    .foregroundStyle(AppTokens.accent)
                    .frame(maxWidth: .infinity)
                    .frame(height: AppTokens.Size.primaryButton)
                    .background(AppTokens.oatmeal, in: Capsule())
            }
            .padding(AppTokens.Spacing.screen)
            .padding(.bottom, AppTokens.Spacing.huge)
        }
    }

    @ViewBuilder
    private var artworkPreview: some View {
        if let drawingImage {
            Image(uiImage: drawingImage)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .frame(height: AppTokens.Size.media)
                .background(AppTokens.surface, in: RoundedRectangle(cornerRadius: AppTokens.mediaRadius, style: .continuous))
                .clipShape(RoundedRectangle(cornerRadius: AppTokens.mediaRadius, style: .continuous))
                .accessibilityLabel("Your finished drawing")
        } else {
            MediaArtworkView(palette: [AppTokens.honey, AppTokens.lavender], symbol: "sparkles", title: selectedTemplate)
        }
    }

    private func finishDrawing() {
        let bounds = canvas.bounds
        guard !bounds.isEmpty else { return }
        drawingImage = canvas.drawing.image(from: bounds, scale: UIScreen.main.scale)
        selectedTemplate = "My Drawing"
        phase = .editor
    }

    private func studioAction(_ title: String, symbol: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(title, systemImage: symbol)
                .font(AppTokens.headlineFont)
                .foregroundStyle(AppTokens.onAccent)
                .frame(maxWidth: .infinity)
                .frame(height: AppTokens.Size.primaryButton)
                .background(AppTokens.accent, in: Capsule())
        }
        .buttonStyle(.plain)
    }

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    private var templateColumns: [GridItem] {
        let count = dynamicTypeSize.isAccessibilitySize ? 1 : 2
        return Array(repeating: GridItem(.flexible(), spacing: AppTokens.Spacing.md), count: count)
    }
}

@available(iOS 17.0, *)
private enum StudioPhase {
    case start
    case templates
    case drawing
    case editor
}

@available(iOS 17.0, *)
private struct TemplateCard: View {
    let title: String
    let isSelected: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: AppTokens.Spacing.md) {
            MediaArtworkView(palette: isSelected ? [AppTokens.accent, AppTokens.honey] : [AppTokens.oatmeal, AppTokens.lavender], symbol: "square.on.square", title: title, compact: true)
            Text(title)
                .font(AppTokens.headlineFont)
                .foregroundStyle(AppTokens.ink)
                .lineLimit(2)
        }
        .padding(AppTokens.Spacing.sm)
        .background(AppTokens.surface, in: RoundedRectangle(cornerRadius: AppTokens.cardRadius, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: AppTokens.cardRadius, style: .continuous).stroke(isSelected ? AppTokens.accent : AppTokens.border, lineWidth: AppTokens.Spacing.xxs / AppTokens.Spacing.xxs))
    }
}

@available(iOS 17.0, *)
private struct ToolPill: View {
    let title: String
    let symbol: String

    var body: some View {
        Label(title, systemImage: symbol)
            .font(AppTokens.captionFont)
            .foregroundStyle(AppTokens.secondaryInk)
            .padding(.horizontal, AppTokens.Spacing.sm)
            .frame(minHeight: AppTokens.Size.hitTarget)
            .background(AppTokens.oatmeal, in: Capsule())
    }
}

#Preview {
    CreateStudioView()
        .environment(VelmoStore())
}
