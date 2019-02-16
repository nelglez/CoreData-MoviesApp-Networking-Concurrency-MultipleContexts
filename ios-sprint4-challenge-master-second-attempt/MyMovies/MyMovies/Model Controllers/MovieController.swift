//
//  MovieController.swift
//  MyMovies
//
//  Created by Spencer Curtis on 8/17/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation
import CoreData

class MovieController {
    
    init(){
        fetchEntriesFromServer()
    }
    
    // MARK: - Properties
    
    var searchedMovies: [MovieRepresentation] = []
    
    private let apiKey = "4cc920dab8b729a619647ccc4d191d5e"
    private let baseURL = URL(string: "https://api.themoviedb.org/3/search/movie")!
    private let firebaseUrl = URL(string: "https://nelson-moviesapp.firebaseio.com/")!
    
    func searchForMovie(with searchTerm: String, completion: @escaping (Error?) -> Void) {
        
        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)
        
        let queryParameters = ["query": searchTerm,
                               "api_key": apiKey]
        
        components?.queryItems = queryParameters.map({URLQueryItem(name: $0.key, value: $0.value)})
        
        guard let requestURL = components?.url else {
            completion(NSError())
            return
        }
        
        URLSession.shared.dataTask(with: requestURL) { (data, _, error) in
            
            if let error = error {
                NSLog("Error searching for movie with search term \(searchTerm): \(error)")
                completion(error)
                return
            }
            
            guard let data = data else {
                NSLog("No data returned from data task")
                completion(NSError())
                return
            }
            
            do {
                let movieRepresentations = try JSONDecoder().decode(MovieRepresentations.self, from: data).results
                self.searchedMovies = movieRepresentations
                completion(nil)
            } catch {
                NSLog("Error decoding JSON data: \(error)")
                completion(error)
            }
        }.resume()
    }
    
    func put(movie: Movie, completion: @escaping(Error?)-> Void = { _ in }) {
        guard let identifier = movie.identifier else {return}
        let url = firebaseUrl.appendingPathComponent(identifier.uuidString).appendingPathExtension("json")
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "PUT"
        
        let encoder = JSONEncoder()
        
        do {
            let jsonData = try encoder.encode(movie)
            urlRequest.httpBody = jsonData
        } catch {
            print("error encoding entry: \(error)")
            completion(error)
            return
        }
        
        URLSession.shared.dataTask(with: urlRequest) { (data, _, error) in
            if let error = error {
                print("Error with request: \(error)")
                completion(error)
                return
            }
            }.resume()
        
    }
    
    
    func fetchEntriesFromServer(completion: @escaping(Error?) -> Void = { _ in }) {
        let url = firebaseUrl.appendingPathExtension("json")
        
        URLSession.shared.dataTask(with: url) { (data, _, error) in
            if let error = error {
                print("Error fetching data: \(error)")
                completion(error)
                return
            }
            
            guard let data = data else {
                print("Error getting data")
                completion(NSError())
                return
            }
            
            var movieRepresentation: [MovieRepresentation] = []
            
            // Use container to get a new background context
            let backgroundMoc = CoreDataStack.shared.container.newBackgroundContext()
            
            
            backgroundMoc.performAndWait {
                do {
                    movieRepresentation = try JSONDecoder().decode([String: MovieRepresentation].self, from: data).map({$0.value})
                    
                    
                    
                    // entryRepresentation = decodedDict
                    for eachMovie in movieRepresentation {
                        if let movie = self.fetchSingleEntryFromPersistentStore(identifier: eachMovie.identifier ?? UUID(), context: backgroundMoc) {
                            self.update(movie: movie, movieRepresentation: eachMovie)
                        } else {
                            
                            _ = Movie(movieRepresentation: eachMovie, context: backgroundMoc)
                        }
                    }
                    
                    try CoreDataStack.shared.save(context: backgroundMoc)
                    //   self.saveToPersistentStore()
                    
                    completion(nil)
                } catch {
                    print("Error decoding or importing tasks: \(error)")
                    completion(error)
                }
            }
            
            
            
            }.resume()
    }
    
    func update(movie: Movie, movieRepresentation: MovieRepresentation){
        
        // Check to make sure there is a context
        guard let context = movie.managedObjectContext else { return }
        
        context.perform {
            guard movie.identifier == movieRepresentation.identifier else {
                fatalError("Updating the wrong movie!")
            }
            
            movie.title = movieRepresentation.title
            movie.identifier = movieRepresentation.identifier
            movie.hasWatched = movieRepresentation.hasWatched ?? false
            
        }
        
        
    }
    
    
    
    func fetchSingleEntryFromPersistentStore(identifier: UUID, context: NSManagedObjectContext) -> Movie? {
        let fetchedRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        fetchedRequest.predicate = NSPredicate(format: "identifier == %@", identifier.uuidString)
        
        var entry: Movie?
        
        //  let moc = CoreDataStack.shared.mainContext
        context.performAndWait {
            do {
                entry = try context.fetch(fetchedRequest).first
            } catch {
                NSLog("Error fetching task with \(identifier): \(error)")
            }
            // return (try? moc.fetch(fetchedRequest))?.first
        }
        return entry
    }
    
    
    
    //Create Movie
    
    func createMovie(title: String){
        let movie = Movie(title: title)
        
        do {
            try CoreDataStack.shared.save()
        } catch {
            print("Error creating task: \(error)")
        }

        put(movie: movie)
    }
    
    
    //Update Movie
    
    func update(movie: Movie, hasWatched: Bool){
        
        movie.hasWatched = hasWatched

        do {
            try CoreDataStack.shared.save()
        } catch {
            NSLog("Error creating task: \(error)")
        }
        
        
        //entry from above
        self.put(movie: movie)
        //saveToPersistentStore()
        
    }
    
    //Delete Movie
    
    func delete(movie: Movie){
        let moc = CoreDataStack.shared.mainContext
        
        moc.delete(movie)//Remore from moc but not persistent store.
        
        self.deleteMovieFromServer(movie: movie)
        
        // saveToPersistentStore()
        do {
            try CoreDataStack.shared.save()
        } catch {
            NSLog("Error creating task: \(error)")
        }
    }
    
    func deleteMovieFromServer(movie: Movie, completion: @escaping(Error?) -> Void = { _ in }) {
        guard let identifier = movie.identifier else {return}
        let url = firebaseUrl.appendingPathComponent(identifier.uuidString).appendingPathExtension("json")
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "DELETE"
        
        URLSession.shared.dataTask(with: urlRequest) { (_, _, error) in
            if let error = error {
                print("Error deleting entry: \(error)")
                completion(error)
                return
            }
            completion(nil)
            }.resume()
    }
}
