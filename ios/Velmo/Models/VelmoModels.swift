import Foundation
import SwiftUI

enum PostKind: String, CaseIterable, Identifiable {
    case drawing = "Drawing"
    case board = "Board"
    case photo = "Photo"
    case video = "Video"
    case project = "Project"

    var id: String { rawValue }
    var symbol: String {
        switch self {
        case .drawing: "paintbrush.pointed.fill"
        case .board: "square.grid.2x2.fill"
        case .photo: "photo.fill"
        case .video: "play.rectangle.fill"
        case .project: "scissors"
        }
    }
}

enum InboxActivityKind: String, CaseIterable, Identifiable {
    case notification = "Notifications"
    case boardInvitation = "Board Invitations"
    case spaceInvitation = "Space Invitations"
    case creationActivity = "Creation Activity"

    var id: String { rawValue }

    var symbol: String {
        switch self {
        case .notification: "heart.fill"
        case .boardInvitation: "square.grid.2x2.fill"
        case .spaceInvitation: "person.3.fill"
        case .creationActivity: "sparkles"
        }
    }
}

struct CreativePost: Identifiable, Hashable {
    let id: UUID
    let name: String
    let handle: String
    let avatar: String
    let kind: PostKind
    let topic: String
    let title: String
    let caption: String
    let palette: [Color]
    let symbol: String
    let artworkImageData: Data?
    let boardName: String?
    var inspiredCount: Int
    var commentCount: Int
    var isInspired: Bool
    var isSaved: Bool

    init(
        id: UUID = UUID(),
        name: String,
        handle: String,
        avatar: String,
        kind: PostKind,
        topic: String,
        title: String,
        caption: String,
        palette: [Color],
        symbol: String,
        artworkImageData: Data? = nil,
        boardName: String? = nil,
        inspiredCount: Int,
        commentCount: Int,
        isInspired: Bool = false,
        isSaved: Bool = false
    ) {
        self.id = id
        self.name = name
        self.handle = handle
        self.avatar = avatar
        self.kind = kind
        self.topic = topic
        self.title = title
        self.caption = caption
        self.palette = palette
        self.symbol = symbol
        self.artworkImageData = artworkImageData
        self.boardName = boardName
        self.inspiredCount = inspiredCount
        self.commentCount = commentCount
        self.isInspired = isInspired
        self.isSaved = isSaved
    }
}

struct InspirationBoard: Identifiable, Hashable {
    let id: UUID
    let title: String
    let description: String
    let palette: [Color]
    let symbols: [String]
    let privacy: String
    var itemCount: Int
    var collaborators: [String]

    init(
        id: UUID = UUID(),
        title: String,
        description: String,
        palette: [Color],
        symbols: [String],
        privacy: String,
        itemCount: Int,
        collaborators: [String] = []
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.palette = palette
        self.symbols = symbols
        self.privacy = privacy
        self.itemCount = itemCount
        self.collaborators = collaborators
    }
}

struct CreativeSpace: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let description: String
    let members: Int
    let symbol: String
    let color: Color
    var isJoined: Bool
}

struct SuggestedCreator: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let handle: String
    let initials: String
    let focus: String
    let color: Color
    var isFollowing: Bool
}

struct FriendRequest: Identifiable, Hashable {
    let id: UUID
    let name: String
    let handle: String
    let initials: String
    let mutualFriends: Int?
    let bio: String
    let timestamp: String
    let color: Color

    init(
        id: UUID = UUID(),
        name: String,
        handle: String,
        initials: String,
        mutualFriends: Int?,
        bio: String,
        timestamp: String,
        color: Color
    ) {
        self.id = id
        self.name = name
        self.handle = handle
        self.initials = initials
        self.mutualFriends = mutualFriends
        self.bio = bio
        self.timestamp = timestamp
        self.color = color
    }
}

struct InboxActivity: Identifiable, Hashable {
    let id: UUID
    let kind: InboxActivityKind
    let title: String
    let detail: String
    let timestamp: String
    let symbol: String
    let color: Color
    var isUnread: Bool

    init(
        id: UUID = UUID(),
        kind: InboxActivityKind,
        title: String,
        detail: String,
        timestamp: String,
        symbol: String,
        color: Color,
        isUnread: Bool = true
    ) {
        self.id = id
        self.kind = kind
        self.title = title
        self.detail = detail
        self.timestamp = timestamp
        self.symbol = symbol
        self.color = color
        self.isUnread = isUnread
    }
}
