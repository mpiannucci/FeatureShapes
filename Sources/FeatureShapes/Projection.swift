//
//  File.swift
//  
//
//  Created by Matthew Iannucci on 9/23/23.
//

import Foundation
import GeoJSON

public protocol Projection: Sendable {
    func project(position: Position, in rect: CGRect) -> CGPoint
}

public struct IdentityProjection : Projection {
    public init() {}
    
    public func project(position: GeoJSON.Position, in rect: CGRect) -> CGPoint {
        return CGPoint(x: position.longitude, y: position.latitude)
    }
    
}
