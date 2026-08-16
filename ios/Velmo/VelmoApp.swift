import SwiftUI

@main
struct VelmoApp: App {
    @State private var store = VelmoStore()

    var body: some Scene {
        WindowGroup {
            VelmoRootView()
                .environment(store)
                .preferredColorScheme(.light)
        }
    }
}

@available(iOS 17.0, *)
struct VelmoRootView: View {
    @State private var selectedTab = AppTab.home
    @State private var showCreate = false

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem { Label("Home", systemImage: "house") }
                .tag(AppTab.home)
            ExploreView()
                .tabItem { Label("Search", systemImage: "magnifyingglass") }
                .tag(AppTab.search)
            Color.clear
                .tabItem { Label("Draw", systemImage: "paintbrush.pointed") }
                .tag(AppTab.draw)
            BoardsView()
                .tabItem { Label("Boards", systemImage: "square.grid.2x2") }
                .tag(AppTab.boards)
            ProfileView()
                .tabItem { Label("Profile", systemImage: "person") }
                .tag(AppTab.profile)
        }
        .tint(AppTokens.accent)
        .onChange(of: selectedTab) { _, tab in
            if tab == .draw {
                showCreate = true
                selectedTab = .home
            }
        }
        .sheet(isPresented: $showCreate) {
            CreateStudioView()
        }
    }
}

enum AppTab: Hashable {
    case home
    case search
    case draw
    case boards
    case profile
}
