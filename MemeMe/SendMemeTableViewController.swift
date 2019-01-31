//
//  SendMemeTableViewController.swift
//  MemeMe
//
//  Created by Khaled H on 29/01/2019.
//  Copyright © 2019 Khaled H. All rights reserved.
//

import UIKit

class SendMemeTableViewController: UITableViewController {

    
    var memes: [Meme]! {
        let object = UIApplication.shared.delegate
        let appDelegate = object as! AppDelegate
        return appDelegate.memes
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tabBarController?.tabBar.isHidden = false
        
        //print("table is set " + String(memes.count))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.memes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableViewCell", for: indexPath) as! TableViewCell
        let meme = self.memes[(indexPath as NSIndexPath).row]
        
//         Set image
        cell.memeImg?.image = meme.memeImg
        
        return cell
    }
    
    
}
