import Foundation
import Observation
import SwiftUI

@Observable
final class VelmoStore {
    var posts: [CreativePost]
    var boards: [InspirationBoard]
    var spaces: [CreativeSpace]
    var creators: [SuggestedCreator]
    var selectedTopic = "All"
    var feedMode = "For You"
    var lastSavedBoardName: String?
    var draftCaption = ""
    var profileIsPrivate = false

    init() {
        posts = SeedData.posts
        boards = SeedData.boards
        spaces = SeedData.spaces
        creators = SeedData.creators
        restoreSavedPosts()
    }

    func toggleInspired(for postID: UUID) {
        guard let index = posts.firstIndex(where: { $0.id == postID }) else { return }
        posts[index].isInspired.toggle()
        posts[index].inspiredCount += posts[index].isInspired ? 1 : -1
    }

    func save(postID: UUID, to boardID: UUID) {
        guard let postIndex = posts.firstIndex(where: { $0.id == postID }),
              let boardIndex = boards.firstIndex(where: { $0.id == boardID }) else { return }
        if !posts[postIndex].isSaved {
            posts[postIndex].isSaved = true
            boards[boardIndex].itemCount += 1
        }
        lastSavedBoardName = boards[boardIndex].title
        persistSavedPosts()
    }

    func createBoard(title: String, privacy: String = "Private") {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else { return }
        boards.insert(
            InspirationBoard(
                title: trimmedTitle,
                description: "A fresh place for ideas that feel like you.",
                palette: [AppTokens.oatmeal, AppTokens.lavender],
                symbols: ["sparkles", "heart.fill", "paintpalette.fill"],
                privacy: privacy,
                itemCount: 0
            ),
            at: 0
        )
    }

    func toggleSpace(_ spaceID: UUID) {
        guard let index = spaces.firstIndex(where: { $0.id == spaceID }) else { return }
        spaces[index].isJoined.toggle()
    }

    func toggleFollow(_ creatorID: UUID) {
        guard let index = creators.firstIndex(where: { $0.id == creatorID }) else { return }
        creators[index].isFollowing.toggle()
    }

    func publishDraft() {
        let text = draftCaption.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        posts.insert(
            CreativePost(
                name: "Mia Vega",
                handle: "miamakes",
                avatar: "MV",
                kind: .project,
                topic: "Creative Projects",
                title: "A little thought for today",
                caption: text,
                palette: [AppTokens.honey, AppTokens.accent],
                symbol: "sparkles",
                boardName: "Creative Projects",
                inspiredCount: 0,
                commentCount: 0
            ),
            at: 0
        )
        draftCaption = ""
    }

    private func persistSavedPosts() {
        let identifiers = posts.filter(\.isSaved).map(\.id.uuidString)
        UserDefaults.standard.set(identifiers, forKey: "velmo.savedPosts")
    }

    private func restoreSavedPosts() {
        let identifiers = Set(UserDefaults.standard.stringArray(forKey: "velmo.savedPosts") ?? [])
        for index in posts.indices {
            posts[index].isSaved = identifiers.contains(posts[index].id.uuidString)
        }
    }
}

enum SeedData {
    static let posts: [CreativePost] = [
        CreativePost(name: "Nora Lin", handle: "noradraws", avatar: "NL", kind: .drawing, topic: "Art", title: "Wildflower studies", caption: "A little watercolor break between classes. I love how the loose edges turned out.", palette: [AppTokens.lavender, AppTokens.honey], symbol: "paintpalette.fill", boardName: "Art Ideas", inspiredCount: 248, commentCount: 18),
        CreativePost(name: "Jay Alvarez", handle: "jaymakes", avatar: "JA", kind: .board, topic: "Vision Boards", title: "Room to breathe", caption: "Saving soft corners, big windows, and a lamp that feels like a warm hug.", palette: [AppTokens.sage, AppTokens.oatmeal], symbol: "lamp.table.fill", boardName: "Dream Home", inspiredCount: 391, commentCount: 24),
        CreativePost(name: "Rina Park", handle: "rinacooks", avatar: "RP", kind: .project, topic: "Food", title: "Sunday recipe cards", caption: "Made a tiny collage for my grandma’s lemon cake. The handwritten notes are my favorite part.", palette: [AppTokens.honey, AppTokens.accent], symbol: "fork.knife", boardName: "Recipes to Try", inspiredCount: 176, commentCount: 12),
        CreativePost(name: "Theo Green", handle: "theogrows", avatar: "TG", kind: .photo, topic: "Plants", title: "Balcony garden, week four", caption: "The basil finally decided to show up. Tiny wins are still wins.", palette: [AppTokens.sage, AppTokens.blue], symbol: "leaf.fill", boardName: "My Garden", inspiredCount: 209, commentCount: 16),
        CreativePost(name: "Sami Cole", handle: "samisketch", avatar: "SC", kind: .video, topic: "Drawing", title: "From scribble to setup", caption: "A quick process clip from my new gaming desk sketch.", palette: [AppTokens.blue, AppTokens.lavender], symbol: "play.fill", boardName: "Gaming Setups", inspiredCount: 154, commentCount: 9)
    ]

    static let boards: [InspirationBoard] = [
        InspirationBoard(title: "Dream Home", description: "Soft light, little rituals, and places to land.", palette: [AppTokens.oatmeal, AppTokens.sage], symbols: ["sofa.fill", "lamp.table.fill", "sun.max.fill"], privacy: "Private", itemCount: 32, collaborators: ["JL"]),
        InspirationBoard(title: "Art Ideas", description: "Colors and marks I want to return to.", palette: [AppTokens.lavender, AppTokens.honey], symbols: ["paintbrush.pointed.fill", "circle.hexagongrid.fill", "pencil.and.scribble"], privacy: "Public", itemCount: 48),
        InspirationBoard(title: "Summer Memories", description: "Slow afternoons and tiny adventures.", palette: [AppTokens.honey, AppTokens.accent], symbols: ["sun.max.fill", "camera.fill", "sailboat.fill"], privacy: "Friends", itemCount: 19),
        InspirationBoard(title: "Creative Projects", description: "Things I want to make with my hands.", palette: [AppTokens.blue, AppTokens.lavender], symbols: ["scissors", "sparkles", "paperclip"], privacy: "Private", itemCount: 27)
    ]

    static let spaces: [CreativeSpace] = [
        CreativeSpace(name: "Sketch Space", description: "Small marks, big ideas.", members: 12840, symbol: "pencil.and.scribble", color: AppTokens.lavender, isJoined: true),
        CreativeSpace(name: "Plant Corner", description: "Growing things together.", members: 8640, symbol: "leaf.fill", color: AppTokens.sage, isJoined: false),
        CreativeSpace(name: "Recipe Lab", description: "Cook, collage, repeat.", members: 6130, symbol: "fork.knife", color: AppTokens.honey, isJoined: false)
    ]

    static let creators: [SuggestedCreator] = [
        SuggestedCreator(name: "Ari Kim", handle: "arikim", initials: "AK", focus: "Collage maker", color: AppTokens.lavender, isFollowing: false),
        SuggestedCreator(name: "Moss Lane", handle: "mosslane", initials: "ML", focus: "Plant doodles", color: AppTokens.sage, isFollowing: true),
        SuggestedCreator(name: "Ivy Rose", handle: "ivyrose", initials: "IR", focus: "Photo stories", color: AppTokens.honey, isFollowing: false)
    ]
}
