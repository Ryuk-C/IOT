//
//  DeviceData.swift
//  WateringMobileApp
//
//  Created by Cuma on 15/01/2025.
//

import Foundation

struct DeviceData: Codable {
    let soilMoisture: Double
    let waterLevel: Double
    let timestamp: String?
    
    enum CodingKeys: String, CodingKey {
        case soilMoisture = "soil_moisture"
        case waterLevel = "water_level"
        case timestamp
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        soilMoisture = try container.decode(Double.self, forKey: .soilMoisture)
        waterLevel = try container.decode(Double.self, forKey: .waterLevel)
        timestamp = try container.decodeIfPresent(String.self, forKey: .timestamp)
    }
} 
