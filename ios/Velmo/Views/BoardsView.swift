import SwiftUI

@available(iOS 17.0, *)
struct BoardsView: View {
    @Environment(VelmoStore.self) private var store
    @State private var selectedTab = "My Boards"
    @State private var showCreateBoard = false
    @State private var selectedBoard: InspirationBoard?
    private let tabs = ["My Boards", "Saved", "Shared"]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AppTokens.Spacing.xl) {
                    Picker("Boards", selection: $selectedTab) {
                        ForEach(tabs, id: \.self) { Text($0).tag($0) }
                    }
                    .pickerStyle(.segmented)
                    LazyVGrid(columns: gridColumns, spacing: AppTokens.Spacing.lg) {
                        ForEach(store.boards) { board in
                            Button { selectedBoard = board } label: {
                                BoardCard(board: board)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(.horizontal, AppTokens.Spacing.screen)
                .padding(.top, AppTokens.Spacing.md)
                .padding(.bottom, AppTokens.Spacing.huge)
            }
            .background(AppTokens.background)
            .navigationTitle("Boards")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showCreateBoard = true } label: {
                        Image(systemName: "plus")
                            .font(AppTokens.symbolFont)
                            .frame(width: AppTokens.Size.hitTarget, height: AppTokens.Size.hitTarget)
                    }
                    .accessibilityLabel("Create board")
                }
            }
            .sheet(isPresented: $showCreateBoard) {
                CreateBoardSheet()
                    .environment(store)
            }
            .sheet(item: $selectedBoard) { board in
                BoardDetailView(board: board)
                    .environment(store)
            }
        }
    }

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    private var gridColumns: [GridItem] {
        let count = dynamicTypeSize.isAccessibilitySize ? 1 : 2
        return Array(repeating: GridItem(.flexible(), spacing: AppTokens.Spacing.lg), count: count)
    }
}

@available(iOS 17.0, *)
private struct BoardCard: View {
    let board: InspirationBoard

    var body: some View {
        VStack(alignment: .leading, spacing: AppTokens.Spacing.sm) {
            BoardCoverView(board: board)
            Text(board.title)
                .font(AppTokens.headlineFont)
                .foregroundStyle(AppTokens.ink)
                .lineLimit(2)
            HStack(spacing: AppTokens.Spacing.xs) {
                Label("\(board.itemCount)", systemImage: "square.grid.2x2")
                Label(board.privacy, systemImage: board.privacy == "Public" ? "globe" : "lock.fill")
            }
            .font(AppTokens.captionFont)
            .foregroundStyle(AppTokens.secondaryInk)
        }
    }
}

#Preview {
    BoardsView()
        .environment(VelmoStore())
}
