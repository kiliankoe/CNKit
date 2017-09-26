import Foundation

public protocol ResourceRepresentable {
    var resource: CNResource? { get }
}

extension BuildingComplex: ResourceRepresentable {
    public var resource: CNResource? {
        return CNResource.building(building: self.abbreviation)
    }
}

extension Floor.Room: ResourceRepresentable {
    public var resource: CNResource? {
        return CNResource.room(room: self.id)
    }

}
