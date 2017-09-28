import Foundation

public protocol ResourceRepresentable {
    var resource: Resource? { get }
}

extension BuildingComplex: ResourceRepresentable {
    public var resource: Resource? {
        return Resource.building(building: self.abbreviation)
    }
}

extension Floor.Room: ResourceRepresentable {
    public var resource: Resource? {
        return Resource.room(room: self.identifier.fullID)
    }
}
