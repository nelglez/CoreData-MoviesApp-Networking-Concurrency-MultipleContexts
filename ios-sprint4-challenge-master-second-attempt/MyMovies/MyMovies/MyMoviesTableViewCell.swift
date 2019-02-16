//
//  MyMoviesTableViewCell.swift
//  MyMovies
//
//  Created by Nelson Gonzalez on 2/16/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class MyMoviesTableViewCell: UITableViewCell {
    
    @IBOutlet weak var movieTitleLabel: UILabel!
    @IBOutlet weak var hasWatchedButton: UIButton!
    
    var movieController: MovieController?
    var movies: Movie? {
        didSet {
            updateViews()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func updateViews() {
        guard let movies = movies else {return}
        movieTitleLabel.text = movies.title
        if movies.hasWatched {
            hasWatchedButton.setTitle("Watched", for: .normal)
        } else {
            hasWatchedButton.setTitle("Unwatched", for: .normal)
        }
    }

    @IBAction func hasWatchedButtonPressed(_ sender: UIButton) {
        //Change in firebase hasWatched from false to true, change in persistent storage too.
        guard let movies = movies else {return}
        if movies.hasWatched == false {
            movies.hasWatched = true
            movieController?.update(movie: movies, hasWatched: true)
            updateViews()
        } else {
            movies.hasWatched = false
            movieController?.update(movie: movies, hasWatched: false)
            updateViews()
        }
        
    }

    
}
