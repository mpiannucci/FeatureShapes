//
//  File.swift
//  
//
//  Created by Matthew Iannucci on 9/25/23.
//

import Foundation
import GeoJSON
import SwiftUI

public protocol ProjectToPath {
    func asPath(in rect: CGRect, projection: Projection) -> Path
}

extension Point : ProjectToPath {
    public func asPath(in rect: CGRect, projection: Projection) -> Path {
        var path = Path()
        
        let projected = projection.project(position: self.coordinates, in: rect)
        path.move(to: projected)
        path.addArc(center: projected, radius: 5.0, startAngle: .degrees(0), endAngle: .degrees(360), clockwise: true)
        
        return path
    }
}

extension MultiPoint : ProjectToPath {
    public func asPath(in rect: CGRect, projection: Projection) -> Path {
        var path = Path()
        
        self.coordinates.forEach { pos in
            let projected = projection.project(position: pos, in: rect)
            path.move(to: projected)
            path.addArc(center: projected, radius: 5.0, startAngle: .degrees(0), endAngle: .degrees(360), clockwise: true)
        }
        
        return path
    }
}

extension LineString : ProjectToPath {
    public func asPath(in rect: CGRect, projection: Projection) -> Path {
        var path = Path()
        
        if let firstPoint = self.coordinates.first {
            path.move(to: projection.project(position: firstPoint, in: rect))
        }
        
        self.coordinates.forEach { pos in
            path.addLine(to: projection.project(position: pos, in: rect))
        }
        
        return path
    }
}

extension MultiLineString : ProjectToPath {
    public func asPath(in rect: CGRect, projection: Projection) -> Path {
        var path = Path()
        
        self.coordinates.forEach { line in
            path.addPath(line.asPath(in: rect, projection: projection))
        }
        
        return path
    }
}

extension GeoJSON.Polygon : ProjectToPath {
    public func asPath(in rect: CGRect, projection: Projection) -> Path {
        var path = Path()
        
        // First polygon ring is the exterior bounds
        if let exterior = self.coordinates.first {
            if let firstPoint = exterior.coordinates.first {
                path.move(to: projection.project(position: firstPoint, in: rect))
            }
            
            exterior.coordinates.forEach { pos in
                path.addLine(to: projection.project(position: pos, in: rect))
            }
        }
        
        // The following rings are holes in the parent
        self.coordinates.suffix(from: 1).forEach { interiorPolygon in
            if let firstPoint = interiorPolygon.coordinates.first {
                path.move(to: projection.project(position: firstPoint, in: rect))
            }
            
            interiorPolygon.coordinates.forEach { pos in
                // Reverse paths are used as clip paths, needs testing
                path.addLine(to: projection.project(position: pos, in: rect))
            }
        }
        
        return path
    }
}

extension MultiPolygon : ProjectToPath {
    public func asPath(in rect: CGRect, projection: Projection) -> Path {
        var path = Path()
        
        self.coordinates.forEach { polygon in
            path.addPath(polygon.asPath(in: rect, projection: projection))
        }
        
        return path
    }
}

extension Geometry : ProjectToPath {
    public func asPath(in rect: CGRect, projection: Projection) -> Path {
        var path = Path()
        
        switch self {
        case .point(let point):
            path.addPath(point.asPath(in: rect, projection: projection))
        case .multiPoint(let points):
            path.addPath(points.asPath(in: rect, projection: projection))
        case .lineString(let line):
            path.addPath(line.asPath(in: rect, projection: projection))
        case .multiLineString(let lines):
            path.addPath(lines.asPath(in: rect, projection: projection))
        case .polygon(let polygon):
            path.addPath(polygon.asPath(in: rect, projection: projection))
        case .multiPolygon(let polygons):
            path.addPath(polygons.asPath(in: rect, projection: projection))
        case .geometryCollection(let collection):
            collection.forEach { geom in
                path.addPath(geom.asPath(in: rect, projection: projection))
            }
        }
        
        return path
    }
}
