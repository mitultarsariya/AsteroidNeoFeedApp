//
//  Model.swift
//  AsteroidNeoApp
//
//  Created by iMac on 05/08/22.
//

import Foundation

struct ModelBaseFeed: Codable {
    var links: WelcomeLinks?
    var elementCount: Int?
    var nearEarthObjects: [String: [NearEarthObject]]?

    enum CodingKeys: String, CodingKey {
        case links
        case elementCount = "element_count"
        case nearEarthObjects = "near_earth_objects"
    }
}

struct WelcomeLinks: Codable {
    var next, prev, linksSelf: String?

    enum CodingKeys: String, CodingKey {
        case next, prev
        case linksSelf = "self"
    }
}

struct NearEarthObject: Codable {
    var links: NearEarthObjectLinks?
    var id, neoReferenceID, name: String?
    var nasaJplURL: String?
    var absoluteMagnitudeH: Double?
    var estimatedDiameter: EstimatedDiameter?
    var isPotentiallyHazardousAsteroid: Bool?
    var closeApproachData: [CloseApproachDatum]?
    var isSentryObject: Bool?

    enum CodingKeys: String, CodingKey {
        case links, id
        case neoReferenceID = "neo_reference_id"
        case name
        case nasaJplURL = "nasa_jpl_url"
        case absoluteMagnitudeH = "absolute_magnitude_h"
        case estimatedDiameter = "estimated_diameter"
        case isPotentiallyHazardousAsteroid = "is_potentially_hazardous_asteroid"
        case closeApproachData = "close_approach_data"
        case isSentryObject = "is_sentry_object"
    }
}

struct CloseApproachDatum: Codable {
    var closeApproachDate, closeApproachDateFull: String?
    var epochDateCloseApproach: Int?
    var relativeVelocity: RelativeVelocity?
    var missDistance: MissDistance?
    var orbitingBody: OrbitingBody?

    enum CodingKeys: String, CodingKey {
        case closeApproachDate = "close_approach_date"
        case closeApproachDateFull = "close_approach_date_full"
        case epochDateCloseApproach = "epoch_date_close_approach"
        case relativeVelocity = "relative_velocity"
        case missDistance = "miss_distance"
        case orbitingBody = "orbiting_body"
    }
}

struct MissDistance: Codable {
    var astronomical, lunar, kilometers, miles: String?
}

enum OrbitingBody: String, Codable {
    case earth = "Earth"
}

// MARK: - RelativeVelocity
struct RelativeVelocity: Codable {
    var kilometersPerSecond, kilometersPerHour, milesPerHour: String?

    enum CodingKeys: String, CodingKey {
        case kilometersPerSecond = "kilometers_per_second"
        case kilometersPerHour = "kilometers_per_hour"
        case milesPerHour = "miles_per_hour"
    }
}

// MARK: - EstimatedDiameter
struct EstimatedDiameter: Codable {
    var kilometers, meters, miles, feet: Feet?
}

// MARK: - Feet
struct Feet: Codable {
    var estimatedDiameterMin, estimatedDiameterMax: Double?

    enum CodingKeys: String, CodingKey {
        case estimatedDiameterMin = "estimated_diameter_min"
        case estimatedDiameterMax = "estimated_diameter_max"
    }
}

// MARK: - NearEarthObjectLinks
struct NearEarthObjectLinks: Codable {
    var linksSelf: String?

    enum CodingKeys: String, CodingKey {
        case linksSelf = "self"
    }
}
