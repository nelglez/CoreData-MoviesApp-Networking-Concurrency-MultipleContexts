//
//  MyMovies+Convenience.swift
//  MyMovies
//
//  Created by Nelson Gonzalez on 2/16/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import CoreData

extension Movie {
    
    @discardableResult convenience init(title: String, identifier: UUID = UUID(), hasWatched: Bool = false, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        
        // Setting up the NSManagedObject (the Core Data related) part of the Task object
        self.init(context: context)
        
        self.title = title
        self.identifier = identifier
        self.hasWatched = hasWatched
    }
    
    
    @discardableResult convenience init?(movieRepresentation: MovieRepresentation, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        
        guard let identifier =  movieRepresentation.identifier else { return nil }
        
        
        self.init(title: movieRepresentation.title, identifier: identifier, hasWatched: movieRepresentation.hasWatched ?? false, context: context)
    }

}
