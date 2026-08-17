import SwiftUI
import PencilKit

@available(iOS 17.0, *)
struct CreateStudioView: View {
    @Environment(VelmoStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @State private var phase: StudioPhase = .start
    @State private var drawingDestination: DrawingDestination = .editor
    @State private var artworkTitle = "My creation"
    @State private var canvas = PKCanvasView()
    @State private var selectedInk = AppTokens.ink
    @State private var brushWidth = AppTokens.Spacing.xxs
    @State private var isErasing = false
    @State private var drawingImage: UIImage?
    @State private var writeHeading = ""
    @State private var writeBody = ""
    @State private var showPhotoPicker = false

    private let inkColors = [AppTokens.ink, AppTokens.accent, AppTokens.lavender, AppTokens.blue, AppTokens.sage, AppTokens.honey]

    var body: some View {
        NavigationStack {
            Group {
                switch phase {
                case .start:
                    startContent
                case .drawing:
                    drawingContent
                case .editor:
                    editorContent
                case .writing:
                    writingContent
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
                if phase == .writing {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Post", action: publishWrittenPost)
                            .font(AppTokens.headlineFont)
                            .foregroundStyle(AppTokens.accent)
                            .disabled(writeHeading.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && writeBody.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                }
            }
            .sheet(isPresented: $showPhotoPicker) {
                PhotoLibraryPicker(onImagePicked: { image in
                    drawingImage = image
                }, onFinished: {
                    showPhotoPicker = false
                })
            }
        }
    }

    private var navigationTitle: String {
        switch phase {
        case .editor:
            "Create"
        case .drawing:
            "Drawing"
        case .writing:
            "Write a post"
        case .start:
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
                    studioAction("Start drawing", symbol: "pencil.and.scribble") {
                        drawingDestination = .editor
                        phase = .drawing
                    }
                    studioAction("Write a post", symbol: "text.alignleft") {
                        phase = .writing
                    }
                    studioAction("Make a collage", symbol: "square.on.square") {
                        artworkTitle = "Collage"
                        drawingImage = nil
                        phase = .editor
                    }
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
                        Text(artworkTitle)
                            .font(AppTokens.titleFont)
                            .foregroundStyle(AppTokens.ink)
                        Text("Your canvas is ready. Add a thought, then choose where it belongs.")
                            .font(AppTokens.bodyFont)
                            .foregroundStyle(AppTokens.secondaryInk)
                    }
                }
                TextField(
                    "Share an idea, moment, or creation…",
                    text: Binding(
                        get: { store.draftCaption },
                        set: { store.draftCaption = $0 }
                    ),
                    axis: .vertical
                )
                    .font(AppTokens.bodyFont)
                    .lineLimit(4...7)
                    .padding(AppTokens.Spacing.md)
                    .background(AppTokens.surface, in: RoundedRectangle(cornerRadius: AppTokens.cardRadius, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: AppTokens.cardRadius, style: .continuous).stroke(AppTokens.border, lineWidth: AppTokens.Spacing.xxs / AppTokens.Spacing.xxs))
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

    private var writingContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppTokens.Spacing.xl) {
                if drawingImage != nil {
                    artworkPreview
                }
                CardSurface {
                    VStack(alignment: .leading, spacing: AppTokens.Spacing.sm) {
                        TextField("Heading", text: $writeHeading)
                            .font(AppTokens.titleFont)
                            .foregroundStyle(AppTokens.ink)
                        Divider()
                        TextEditor(text: $writeBody)
                            .font(AppTokens.bodyFont)
                            .foregroundStyle(AppTokens.ink)
                            .frame(minHeight: AppTokens.Size.media)
                            .scrollContentBackground(.hidden)
                    }
                }
                HStack(spacing: AppTokens.Spacing.sm) {
                    attachmentButton("Add Drawing", symbol: "pencil.and.scribble") {
                        drawingDestination = .writing
                        phase = .drawing
                    }
                    attachmentButton("Add Photos", symbol: "photo.on.rectangle") {
                        showPhotoPicker = true
                    }
                }
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
                .accessibilityLabel("Attached artwork")
        } else {
            MediaArtworkView(palette: [AppTokens.honey, AppTokens.lavender], symbol: "sparkles", title: artworkTitle)
        }
    }

    private func finishDrawing() {
        let bounds = canvas.bounds
        guard !bounds.isEmpty else { return }
        drawingImage = canvas.drawing.image(from: bounds, scale: UIScreen.main.scale)
        artworkTitle = "My Drawing"
        phase = drawingDestination == .writing ? .writing : .editor
    }

    private func publishWrittenPost() {
        store.publishDraft(
            title: writeHeading,
            body: writeBody,
            artworkImageData: drawingImage?.pngData()
        )
        dismiss()
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

    private func attachmentButton(_ title: String, symbol: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(title, systemImage: symbol)
                .font(AppTokens.headlineFont)
                .foregroundStyle(AppTokens.ink)
                .frame(maxWidth: .infinity)
                .frame(minHeight: AppTokens.Size.hitTarget)
                .background(AppTokens.oatmeal, in: Capsule())
        }
        .buttonStyle(.plain)
    }
}

@available(iOS 17.0, *)
private enum StudioPhase {
    case start
    case drawing
    case editor
    case writing
}

private enum DrawingDestination {
    case editor
    case writing
}

#Preview {
    CreateStudioView()
        .environment(VelmoStore())
}
