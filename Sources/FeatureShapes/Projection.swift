//
//  File.swift
//  
//
//  Created by Matthew Iannucci on 9/23/23.
//

import Foundation
import GeoJSON

public protocol Projection: Sendable {
    func project(point: Point, in rect: CGRect) -> CGPoint
}

public struct IdentityProjection : Projection {
    public func project(point: GeoJSON.Point, in rect: CGRect) -> CGPoint {
        return CGPoint(x: point.coordinates.longitude, y: point.coordinates.latitude)
    }
    
}
