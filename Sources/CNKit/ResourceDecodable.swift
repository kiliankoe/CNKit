protocol ResourceDecodable: APIResource, Decodable, CNResourceRepresentable {
    var requestResource: RequestResource? { get set }
}

extension ResourceDecodable {
//    init(from decoder: Decoder, with resource: RequestResource) throws {
//        try self.init(from: decoder)
//        self.requestResource = resource
//    }

//    mutating func setResource(_ requestResource: RequestResource) {
//        self.requestResource = requestResource
//    }
}
