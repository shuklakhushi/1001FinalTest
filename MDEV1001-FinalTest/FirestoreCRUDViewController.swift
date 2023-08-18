//
//  FirestoreCRUDViewController.swift
//  MDEV1001-FinalTest
//
//  Created by Khushi Shukla on 2023-08-18.
//

import UIKit
import FirebaseFirestore
import FirebaseFirestoreSwift

class FirestoreCRUDViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var songs: [Songs] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        fetchSongsFromFirestore()
    }

    func fetchSongsFromFirestore() {
        let db = Firestore.firestore()
        db.collection("songs").getDocuments { (snapshot, error) in
            if let error = error {
                print("Error fetching documents: \(error)")
                return
            }

            var fetchedSongs: [Songs] = []

            for document in snapshot!.documents {
                let data = document.data()

                do {
                    var song = try Firestore.Decoder().decode(Songs.self, from: data)
                    song.documentID = document.documentID // Set the documentID
                    fetchedSongs.append(song)
                } catch {
                    print("Error decoding song data: \(error)")
                }
            }

            DispatchQueue.main.async {
                self.songs = fetchedSongs
                self.tableView.reloadData()
            }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songs.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SongCell", for: indexPath) as! SongTableViewCell

        let song = songs[indexPath.row]

        cell.titleLabel?.text = song.title
        cell.labelLabel?.text = song.label
        cell.ratingLabel?.text = "\(song.rating)"

        let rating = song.rating

        if rating > 4.5 {
            cell.ratingLabel.backgroundColor = UIColor.green
            cell.ratingLabel.textColor = UIColor.black
        } else if rating > 2 {
            cell.ratingLabel.backgroundColor = UIColor.yellow
            cell.ratingLabel.textColor = UIColor.black
        } else {
            cell.ratingLabel.backgroundColor = UIColor.red
            cell.ratingLabel.textColor = UIColor.white
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "AddEditSegue", sender: indexPath)
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let song = songs[indexPath.row]
            songDeleteConfirmationAlert(for: song) { confirmed in
                if confirmed {
                    self.deleteSongs(at: indexPath)
                }
            }
        }
    }

    @IBAction func addButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "AddEditSegue", sender: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddEditSegue" {
            if let addEditVC = segue.destination as? AddEditFirestoreViewController {
                addEditVC.songViewController = self
                if let indexPath = sender as? IndexPath {
                    let song = songs[indexPath.row]
                    addEditVC.song = song
                } else {
                    addEditVC.song = nil
                }

                addEditVC.songUpdateCallback = { [weak self] in
                    self?.fetchSongsFromFirestore()
                }
            }
        }
    }

    func songDeleteConfirmationAlert(for song: Songs, completion: @escaping (Bool) -> Void) {
        let alert = UIAlertController(title: "Delete Song", message: "Are you sure you want to delete this song?", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
            completion(false)
        })

        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
            completion(true)
        })

        present(alert, animated: true, completion: nil)
    }

    func deleteSongs(at indexPath: IndexPath) {
        let song = songs[indexPath.row]

        guard let documentID = song.documentID else {
            print("Invalid document ID")
            return
        }

        let db = Firestore.firestore()
        db.collection("songs").document(documentID).delete { [weak self] error in
            if let error = error {
                print("Error deleting document: \(error)")
            } else {
                DispatchQueue.main.async {
                    print("song deleted successfully.")
                    self?.songs.remove(at: indexPath.row)
                    self?.tableView.deleteRows(at: [indexPath], with: .fade)
                }
            }
        }
    }
}
