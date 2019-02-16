//
//  Movie+Encodable.swift
//  MyMovies
//
//  Created by Nelson Gonzalez on 2/16/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

extension Movie: Encodable {
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        // Encode each of the 5 attributes of the Entry individually
        try container.encode(title, forKey: .title)
        try container.encode(identifier, forKey: .identifier)
        try container.encode(hasWatched, forKey: .hasWatched)
    }
    
    enum CodingKeys: String, CodingKey {
        case title
        case identifier
        case hasWatched
    }
}
