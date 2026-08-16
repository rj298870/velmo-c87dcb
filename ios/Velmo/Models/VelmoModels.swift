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

// MARK: - Inbox

enum InboxSection: String, CaseIterable, Identifiable {
    case friendRequests = "Friend Requests"
    case notifications = "Notifications"
    case boardInvitations = "Board Invitations"
    case spaceInvitations = "Space Invitations"
    case creationActivity = "Creation Activity"

    var id: String { rawValue }
}

enum FriendRequestStatus {
    case pending
    case accepted
    case declined
}

struct FriendRequest: Identifiable, Hashable {
    let id: UUID
    let name: String
    let handle: String
    let initials: String
    let color: Color
    let mutualFriends: Int
    let bioOrSharedInterests: String
    let receivedAt: Date
    var status: FriendRequestStatus

    init(
        id: UUID = UUID(),
        name: String,
        handle: String,
        initials: String,
        color: Color,
        mutualFriends: Int,
        bioOrSharedInterests: String,
        receivedAt: Date,
        status: FriendRequestStatus = .pending
    ) {
        self.id = id
        self.name = name
        self.handle = handle
        self.initials = initials
        self.color = color
        self.mutualFriends = mutualFriends
        self.bioOrSharedInterests = bioOrSharedInterests
        self.receivedAt = receivedAt
        self.status = status
    }
}

struct InboxNotification: Identifiable, Hashable {
    enum Kind {
        case notification, boardInvitation, spaceInvitation, creationActivity

        var section: InboxSection {
            switch self {
            case .notification: .notifications
            case .boardInvitation: .boardInvitations
            case .spaceInvitation: .spaceInvitations
            case .creationActivity: .creationActivity
            }
        }

        var symbol: String {
            switch self {
            case .notification: "bell.fill"
            case .boardInvitation: "square.grid.2x2.fill"
            case .spaceInvitation: "person.3.fill"
            case .creationActivity: "sparkles"
            }
        }
    }

    let id: UUID
    let kind: Kind
    let title: String
    let subtitle: String
    let receivedAt: Date
    var isRead: Bool

    init(
        id: UUID = UUID(),
        kind: Kind,
        title: String,
        subtitle: String,
        receivedAt: Date,
        isRead: Bool = false
    ) {
        self.id = id
        self.kind = kind
        self.title = title
        self.subtitle = subtitle
        self.receivedAt = receivedAt
        self.isRead = isRead
    }
}
