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
        case .point(let point):
            let projected = projection.project(position: point.coordinates, in: rect)
            path.move(to: projected)
            path.addArc(center: projected, radius: 5.0, startAngle: .degrees(0), endAngle: .degrees(360), clockwise: true)
        case .multiPoint(let points):
            points.coordinates.forEach { position in
                let projected = projection.project(position: position, in: rect)
                path.move(to: projected)
                path.addArc(center: projected, radius: 5.0, startAngle: .degrees(0), endAngle: .degrees(360), clockwise: true)
            }
        case .lineString(let line):
            if let firstPoint = line.coordinates.first {
                path.move(to: projection.project(position: firstPoint, in: rect))
            }
            
            line.coordinates.forEach { pos in
                path.addLine(to: projection.project(position: pos, in: rect))
            }
        case .multiLineString(let lines):
            lines.coordinates.forEach { line in
                if let firstPoint = line.coordinates.first {
                    path.move(to: projection.project(position: firstPoint, in: rect))
                }
                
                line.coordinates.forEach { pos in
                    path.addLine(to: projection.project(position: pos, in: rect))
                }
            }
        case .polygon(let polygon):
            // First polygon ring is the exterior bounds
            if let exterior = polygon.coordinates.first {
                if let firstPoint = exterior.coordinates.first {
                    path.move(to: projection.project(position: firstPoint, in: rect))
                }
                
                exterior.coordinates.forEach { pos in
                    path.addLine(to: projection.project(position: pos, in: rect))
                }
            }
            
            // The following rings are holes in the parent
            polygon.coordinates.suffix(from: 1).forEach { interiorPolygon in
                if let firstPoint = interiorPolygon.coordinates.first {
                    path.move(to: projection.project(position: firstPoint, in: rect))
                }
                
                interiorPolygon.coordinates.forEach { pos in
                    // Reverse paths are used as clip paths, needs testing
                    path.addLine(to: projection.project(position: pos, in: rect))
                }
            }
        case .multiPolygon(let polygons):
            polygons.coordinates.forEach { polygon in
                // First polygon ring is the exterior bounds
                if let exterior = polygon.coordinates.first {
                    if let firstPoint = exterior.coordinates.first {
                        path.move(to: projection.project(position: firstPoint, in: rect))
                    }
                    
                    exterior.coordinates.forEach { pos in
                        path.addLine(to: projection.project(position: pos, in: rect))
                    }
                }
                
                // The following rings are holes in the parent
                polygon.coordinates.suffix(from: 1).forEach { interiorPolygon in
                    if let firstPoint = interiorPolygon.coordinates.first {
                        path.move(to: projection.project(position: firstPoint, in: rect))
                    }
                    
                    interiorPolygon.coordinates.forEach { pos in
                        // Reverse paths are used as clip paths, needs testing
                        path.addLine(to: projection.project(position: pos, in: rect))
                    }
                }
            }
            break
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
