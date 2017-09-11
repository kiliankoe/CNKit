import MapKit

extension MKMapRect {

    /// Resize the MKMapRect with a given factor by moving the origin and adjusting the width and height.
    ///
    /// - Parameter factor: factor
    mutating func resize(_ factor: Double) {
        origin.x -= factor / 2
        origin.y -= factor / 2
        size.height += factor
        size.width += factor
    }
}

