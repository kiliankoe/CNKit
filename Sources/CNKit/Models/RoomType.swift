import Foundation

// List of types:
// https://fusionforge.zih.tu-dresden.de/plugins/mediawiki/wiki/campusnavigator/index.php/Raumtypen
// https://github.com/kiliankoe/campus-navigator/blob/master/CampusNavigator/CoreData/Room.m
public enum RoomType: Int {
    case stairwell = 11
    case elevator = 12
    case restroom = 13
    case accessibleRestroom = 14
    case babyChangingRoom = 15
    case library = 21
    case lecturehall = 22
    case seminarroom = 23
    case drawingroom = 24
    case restingroom = 26
    case coatroom = 27
    case room = 29
    case other = -1

    init(value: Int) {
        if let type = RoomType(rawValue: value) {
            self = type
        } else {
            self = .other
        }
    }

    public var color: Int {
        switch self {
        case .stairwell: return 0xd4bfb4
        case .elevator: return 0xbd927b
        case .restroom,
             .accessibleRestroom,
             .babyChangingRoom: return 0xa3dbf0
        case .lecturehall: return 0xffa35c
        case .seminarroom: return 0xecf7aa
        case .coatroom: return 0xa09cbd
        case .room: return 0xf0f0f0
        default: return 0xffffff // white
        }
    }
}
