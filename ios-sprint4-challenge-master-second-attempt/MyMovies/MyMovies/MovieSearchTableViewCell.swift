//
//  MoviewSearchTableViewCell.swift
//  MyMovies
//
//  Created by Nelson Gonzalez on 2/16/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class MovieSearchTableViewCell: UITableViewCell {
    @IBOutlet weak var movieTitleLabel: UILabel!
    
    @IBOutlet weak var addMovieButton: UIButton!
    
    var movieController: MovieController?
    var movies: MovieRepresentation? {
        didSet {
            updateViews()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func updateViews(){
        guard let movies = movies else {return}
        movieTitleLabel.text = movies.title
        
    }
    
    @IBAction func addMovieButtonPressed(_ sender: UIButton) {
        guard let movies = movies else {return}
        //Save movie to database and persistent storage.
        movieController?.createMovie(title: movies.title)
        addMovieButton.setTitle("Saved", for: .normal)
        addMovieButton.backgroundColor = .lightGray
        
        
        
    }
    
}
