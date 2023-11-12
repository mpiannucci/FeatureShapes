// The Swift Programming Language
// https://docs.swift.org/swift-book

import SwiftUI
@preconcurrency import GeoJSON


public struct FeatureShape: Shape {
    public let feature: Feature
    public let projection: Projection
    
    public func path(in rect: CGRect) -> Path {
        var path = Path()
        
        if let geometry = feature.geometry {
            path.addPath(geometry.asPath(in: rect, projection: projection))
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

let line = Feature(
    geometry: .lineString(try! LineString(coordinates: [
        Position(longitude: 10, latitude: 10),
        Position(longitude: 20, latitude: 10),
        Position(longitude: 20, latitude: 30)
    ])),
    properties: [:]
)

let multiline = Feature(
    geometry: .multiLineString(MultiLineString(coordinates: [
        try! LineString(coordinates: [
            Position(longitude: 10, latitude: 10),
            Position(longitude: 20, latitude: 10),
            Position(longitude: 20, latitude: 30)
        ]),
        try! LineString(coordinates: [
            Position(longitude: 10, latitude: 50),
            Position(longitude: 20, latitude: 50),
            Position(longitude: 20, latitude: 80)
        ])
    ])),
    properties: [:]
)

let filledPolygon = Feature(
    geometry: .polygon(try! Polygon(coordinates: [
        Polygon.LinearRing(coordinates: [
            Position(longitude: 10, latitude: 50),
            Position(longitude: 50, latitude: 50),
            Position(longitude: 50, latitude: 100),
            Position(longitude: 10, latitude: 100),
            Position(longitude: 10, latitude: 50)
        ])
    ])),
    properties: [:]
)

let polygonHole = Feature(
    geometry: .polygon(try! Polygon(coordinates: [
        Polygon.LinearRing(coordinates: [
            Position(longitude: 10, latitude: 50),
            Position(longitude: 200, latitude: 50),
            Position(longitude: 200, latitude: 200),
            Position(longitude: 10, latitude: 200),
            Position(longitude: 10, latitude: 50)
        ]),
        Polygon.LinearRing(coordinates: [
            Position(longitude: 50, latitude: 100),
            Position(longitude: 50, latitude: 150),
            Position(longitude: 100, latitude: 150),
            Position(longitude: 100, latitude: 100),
            Position(longitude: 50, latitude: 100)
        ])
    ])),
    properties: [:]
)

let filledMultipolygon = Feature(
    geometry: .multiPolygon(MultiPolygon(coordinates: [
        try! Polygon(coordinates: [
            Polygon.LinearRing(coordinates: [
                Position(longitude: 10, latitude: 50),
                Position(longitude: 200, latitude: 50),
                Position(longitude: 200, latitude: 200),
                Position(longitude: 10, latitude: 200),
                Position(longitude: 10, latitude: 50)
            ]),
            Polygon.LinearRing(coordinates: [
                Position(longitude: 50, latitude: 100),
                Position(longitude: 50, latitude: 150),
                Position(longitude: 100, latitude: 150),
                Position(longitude: 100, latitude: 100),
                Position(longitude: 50, latitude: 100)
            ])
        ]),
        try! Polygon(coordinates: [
            Polygon.LinearRing(coordinates: [
                Position(longitude: 10, latitude: 500),
                Position(longitude: 250, latitude: 500),
                Position(longitude: 250, latitude: 600),
                Position(longitude: 10, latitude: 600),
                Position(longitude: 10, latitude: 500)
            ])
        ])
    ])),
    properties: [:]
)

struct FeatureShape_Previews: PreviewProvider {
    static var previews: some View {
        FeatureShape(feature: point, projection: IdentityProjection())
            .fill(.red)
            .previewDisplayName("Point")
        FeatureShape(feature: line, projection: IdentityProjection())
            .stroke(lineWidth: 2.0)
            .foregroundColor(.red)
            .previewDisplayName("Line")
        FeatureShape(feature: multiline, projection: IdentityProjection())
            .stroke(lineWidth: 2.0)
            .foregroundColor(.blue)
            .previewDisplayName("Mulitline")
        FeatureShape(feature: filledPolygon, projection: IdentityProjection())
            .fill(.purple)
            .previewDisplayName("Polygon")
        FeatureShape(feature: polygonHole, projection: IdentityProjection())
            .fill(.purple)
            .previewDisplayName("Polygon With Hole")
        FeatureShape(feature: filledMultipolygon, projection: IdentityProjection())
            .fill(.green)
            .previewDisplayName("MultiPolygon")
    }
}
#endif
