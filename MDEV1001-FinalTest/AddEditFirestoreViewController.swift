//
//  AddEditFirestoreViewController.swift
//  MDEV1001-FinalTest
//
//  Created by Khushi Shukla on 2023-08-18.
//

import UIKit
import Firebase

class AddEditFirestoreViewController: UIViewController {

    // UI References
    @IBOutlet weak var AddEditTitleLabel: UILabel!
    @IBOutlet weak var UpdateButton: UIButton!
    
    // Movie Fields
    @IBOutlet weak var songIDTextField: UITextField!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var artistTextField: UITextField!
    @IBOutlet weak var genreTextField: UITextField!
    @IBOutlet weak var albumTextField: UITextField!
    @IBOutlet weak var labelTextField: UITextField!
    @IBOutlet weak var youtubeLinkTextField: UITextField!
    @IBOutlet weak var durationTextField: UITextField!
    @IBOutlet weak var releaseDateTextField: UITextField!
    @IBOutlet weak var trackNumberTextField: UITextView!
    @IBOutlet weak var ratingTextField: UITextField!
    @IBOutlet weak var composerTextField: UITextField!
    
    
    var song: Songs?
    var songViewController: FirestoreCRUDViewController?
    var songUpdateCallback: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let song = song{
            // Editing existing movie
            songIDTextField.text = "\(song.songID)"
            titleTextField.text = song.title
            genreTextField.text = song.genre
            albumTextField.text = song.album
            artistTextField.text = song.artist
            composerTextField.text = song.composer
            durationTextField.text = song.duration
            labelTextField.text = song.label
            ratingTextField.text = "\(song.rating)"
            releaseDateTextField.text = song.releaseDate
            trackNumberTextField.text = "\(song.trackNumber)"
            youtubeLinkTextField.text = "\(song.youtubeLink)"
            AddEditTitleLabel.text = "Edit Song"
            UpdateButton.setTitle("Update", for: .normal)
        } else {
            AddEditTitleLabel.text = "Add Song"
            UpdateButton.setTitle("Add", for: .normal)
        }
    }
    
    @IBAction func CancelButton_Pressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func UpdateButton_Pressed(_ sender: UIButton) {
        guard
            
              let title = titleTextField.text,
              let album = albumTextField.text,
              let genre = genreTextField.text,
              let composer = composerTextField.text,
              let artist = artistTextField.text,
              let duration = durationTextField.text,
              let label = labelTextField.text,
              let rating = ratingTextField.text,
              let releaseDate = releaseDateTextField.text,
              let trackNumber = trackNumberTextField.text,
              let youtubeLink = youtubeLinkTextField.text
        else {
            print("Invalid data")
            return
        }

        let db = Firestore.firestore()

        if let song = song {
            // Update existing movie
            guard let documentID = song.documentID else {
                print("Document ID not available.")
                return
            }
            
            let rating = Double(rating) ?? 0.0
                    let trackNumber = Int(trackNumber) ?? 0

            let songRef = db.collection("songs").document(documentID)
            songRef.updateData([
                
                "title": title,
                "album": album,
                "genre": genre,
                "composer": composer,
                "youtubeLink": youtubeLink,
                "rating": rating,
                "artist": artist,
                "duration": duration,
                "label": label,
                "releaseDate": releaseDate,
                "trackNumber": trackNumber
            ]) { [weak self] error in
                if let error = error {
                    print("Error updating song: \(error)")
                } else {
                    print("Song updated successfully.")
                    self?.dismiss(animated: true) {
                        self?.songUpdateCallback?()
                    }
                }
            }
        } else {
            
            let rating = Double(rating) ?? 0.0
                    let trackNumber = Int(trackNumber) ?? 0
            // Add new movie
            let newSong     = [
               
                "title": title,
                "album": album,
                "genre": genre,
                "composer": composer,
                "youtubeLink": youtubeLink,
                "rating": rating,
                "artist": artist,
                "duration": duration,
                "label": label,
                "releaseDate": releaseDate,
                "trackNumber": trackNumber
            ] as [String : Any]

            var ref: DocumentReference? = nil
            ref = db.collection("songs").addDocument(data: newSong) { [weak self] error in
                if let error = error {
                    print("Error adding song: \(error)")
                } else {
                    print("Song added successfully.")
                    self?.dismiss(animated: true) {
                        self?.songUpdateCallback?()
                    }
                }
            }
        }
    }
}
