import Foundation

public protocol CNResourceRepresentable {
    /// CN resource for this value.
    var resource: CNResource? { get }
}

//extension BuildingComplex: CNResourceRepresentable {
//    public var resource: CNResource? {
//        return CNResource.building(building: self.abbreviation)
//    }
//}

//extension Timetable: CNResourceRepresentable {
//    public var resource: CNResource? {
//        <#code#>
//    }
//}

// Would love to have this for other types as well, but `Floor`s and `Room`s don't know the building they're in :/
