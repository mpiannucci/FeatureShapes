// The Swift Programming Language
// https://docs.swift.org/swift-book

import SwiftUI
@preconcurrency import GeoJSON


public struct FeatureShape: Shape {
    let feature: Feature
    let projection: Projection
    
    public func path(in rect: CGRect) -> Path {
        var path = Path()
        
        switch feature.geometry {
        case .point(let p):
            let projected = projection.project(point: p, in: rect)
            path.move(to: projected)
            path.addArc(center: projected, radius: 5.0, startAngle: .degrees(0), endAngle: .degrees(360), clockwise: true)
        default:
            break
        }
        
        return path
    }
}

#if DEBUG
let point = Feature(
    geometry: .point(Point(longitude: 125.6, latitude: 10.1)),
    properties: [
        "name": "Dinagat Island"
    ]
)


struct FeatureShape_Previews: PreviewProvider {
    static var previews: some View {
        FeatureShape(feature: point, projection: IdentityProjection())
            .fill(.red)
    }
}
#endif
