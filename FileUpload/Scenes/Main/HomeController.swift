//
//  HomeController.swift
//  FileUpload
//
//  Created by Nicolò Curioni on 08/02/23.
//

import UIKit

class HomeController: UITableViewController {
    
    // MARK: Outlets
    @IBOutlet weak var uploadDocumentButton: UIBarButtonItem!
    
    // MARK: View Life-cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(FileTableViewCell.self, forCellReuseIdentifier: "FileCell")
    }
    
    // MARK: TableView DataSource & Delegate
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FileCell", for: indexPath) as! FileTableViewCell
        
        
        return cell
    }
}
