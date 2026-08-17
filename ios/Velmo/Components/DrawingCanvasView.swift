import SwiftUI
import PencilKit

@available(iOS 17.0, *)
struct DrawingCanvasView: UIViewRepresentable {
    let canvas: PKCanvasView
    let color: Color
    let brushWidth: CGFloat
    let isErasing: Bool

    func makeUIView(context: Context) -> PKCanvasView {
        canvas.backgroundColor = UIColor(AppTokens.surface)
        canvas.isOpaque = true
        canvas.drawingPolicy = .anyInput
        applyTool()
        return canvas
    }

    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        applyTool()
    }

    private func applyTool() {
        if isErasing {
            canvas.tool = PKEraserTool(.vector)
        } else {
            canvas.tool = PKInkingTool(.pen, color: UIColor(color), width: brushWidth)
        }
    }
}
