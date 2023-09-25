# FeatureShapes

Create SwiftUI Shapes from GeoJSON Features. Inspired by [d3-path](https://github.com/d3/d3-path) and [d3-geo](https://github.com/d3/d3-geo).

## Installation

This package is available via Swift Package Manager, add its git url to your project to get started.

## Usage

Given a GeoJSON Feature: 

```swift
let line = Feature(
    geometry: .lineString(try! LineString(coordinates: [
        Position(longitude: 10, latitude: 10),
        Position(longitude: 20, latitude: 10),
        Position(longitude: 20, latitude: 30)
    ])),
    properties: [:]
)
```

It can be rendered using a `FeatureShape`:

```swift
        FeatureShape(feature: line, projection: IdentityProjection())
            .stroke(lineWidth: 2.0)
            .foregroundColor(.red)
```

### Projections

SwiftUI `Shapes` are drawn from `Path`s. To draw paths, you given instructions based on `CGPoint` locations inside 
of a given `CGRect`. The `GeoJSON` package assumes that all positions are `latitude` and `longitude` pairs but that 
may not be the case or the data may be in a bespoke projection system. To stay low level, the `Path`s created use a 
projection protocol map from `GeoJSON` location to `Path` location. 

Currently there is a single projection included with this package, the `IdentityProjection`. This projection simply converts 
the `GeoJSON Position` object to a `CGPoint`. 

To create a custom projection, simply create an object the implements the `Projection` protocol, mapping the `GeoJSON Position` objects 
in any way desired. 
