//
//  HomeFeedViewController.swift
//  AudioSound
//
//  Created by Olisemedua Onwuatogwu on 4/21/23.
//

import UIKit
import AVFoundation

class HomeFeedViewController: UIViewController {
//    var audioPlayer: AVPlayer!
    var audioBox = AudioBox() // new sound player
    var activeCellIndex: Int?
    var activeCell: PostCell?

    @IBOutlet weak var tableView: UITableView!
    
    private var audioPosts = [Audio](){
        didSet{
            // Reload table view data any
            // time the posts variable gets updated.
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        quaryPosts()
        tableView.delegate = self
        tableView.dataSource = self
        }
    
    
    private func quaryPosts(){
        let query = Audio.query()
        
        query.find{
            [weak self] result in
            
            switch result {
            case .success(let audio):
                // Update local audioPosts property with fetched
                // posts
                self?.audioPosts = audio
            case .failure(let error):
                self?.showAlert(description:error.localizedDescription)
                //.localizedDescription turns
                // type error to a string
            }
        }
    }
    
    private func showAlert(description: String? = nil) {
        let alertController = UIAlertController(title: "Oops...", message: "\(description ?? "Please try again...")", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(action)
        present(alertController, animated: true)
    }

    @IBAction func onLoggedOutTapped(_ sender: Any) {
        showConfirmLogoutAlert()
    }
    
    private func showConfirmLogoutAlert() {
        let alertController = UIAlertController(title: "Log out of \(User.current?.username ?? "current account")?", message: nil, preferredStyle: .alert)
        let logOutAction = UIAlertAction(title: "Log out", style: .destructive) { _ in
            NotificationCenter.default.post(name: Notification.Name("logout"), object: nil)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addAction(logOutAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
    }
}

extension HomeFeedViewController : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return audioPosts.count;
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as? PostCell else {
            return UITableViewCell()
        }
        
        cell.configureCell(with: audioPosts[indexPath.row])
        
        return cell
    }
  
    // set the height of each cell
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        return tableView.frame.height
        }
}

extension HomeFeedViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // this just plays the first cell
        
        let cellFrame :CGRect
        let isCellFullyVisible : Bool
        

        
        // this will play the first cell
        if( indexPath.item == 0){
            
                    
            
            cellFrame = tableView.rectForRow(at: indexPath )
            isCellFullyVisible = tableView.bounds.contains(cellFrame)
            
            if(isCellFullyVisible){
                if let audioUrl = (audioPosts[indexPath.item].audioFile?.url){
                    audioBox.play(fileurl:audioUrl);
                    activeCellIndex = indexPath.row;
                    
                    
                    guard let audioPlayer = audioBox.audioPlayer
                    else{
                        return
                    }
                    
                    
                    guard let cell = cell as? PostCell
                    else{
                        return
                    }
                    
                    cell.addProgressBarObserver(audioPlayer: audioPlayer)
                    activeCell = cell;
                }
            }
            
            
            
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Get the visible cells in the table view
        var cellFrame :CGRect
        var isCellFullyVisible : Bool
        
        // get cells we can currently see
        if let visibleCells = tableView.visibleCells as? [PostCell] {
            
            for cell in visibleCells {
                
                if let indexPath = tableView.indexPath(for: cell) {
                    
                    // we make sure its not the cell we are
                    // currently viewing
                    if(indexPath.row != activeCellIndex){
                        
                        // get the cell rectangle
                        cellFrame = tableView.rectForRow(at: indexPath )
                        
                        // we check if our table bounds contain
                        // the cell
                        isCellFullyVisible = tableView.bounds.contains(cellFrame)
                        
                        if(isCellFullyVisible){
                            
                            guard let activeCell = activeCell
                            else{
                                return
                            }
                            
                            guard let audioPlayer = audioBox.audioPlayer
                            else{
                                return
                            }
                            
                            // remove obsever from the previous active
                            // cell of type post cell
                            activeCell.removeProgressBarObserver()
                            
                            if var audioUrl = (audioPosts[indexPath.item].audioFile?.url){
                                
                                audioBox.play(fileurl:audioUrl);
                                activeCellIndex = indexPath.row;
                                
                                // refresh the audio player
                                guard let audioPlayer = audioBox.audioPlayer
                                else{
                                    return
                                }
                                
                                // add observer to current cell
                                cell.addProgressBarObserver(audioPlayer: audioPlayer)
                            }
                        }
                    }
                }
                
            }
        }
    }
}


