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
    
    var file: File? = nil
    
    var files: [File] = []
    
    // Get the documents directory
    let documentPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    
    let downloadService = DownloadService()
    
    lazy var downloadSession: URLSession = {
        let configuration = URLSessionConfiguration.background(withIdentifier: "\(Bundle.main.bundleIdentifier!).download")
        
        // Download can be scheduled by system for optimal performance
        
        return URLSession(configuration: configuration, delegate: self, delegateQueue: .main)
    }()
    
    let uploadService = UploadService()
    
    lazy var uploadSession: URLSession = {
        let configuration = URLSessionConfiguration.default
        
        return URLSession(configuration: configuration, delegate: self, delegateQueue: .main)
    }()
    
    // MARK: View Life-cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(FileTableViewCell.self, forCellReuseIdentifier: "FileCell")
        
        // Set the URLSession on the download service
        downloadService.downloadSession = downloadSession
        uploadService.uploadSession = uploadSession
    }
    
    // MARK: IBActions
    @IBAction func uploadFile(_ sender: Any) {
        didUploadData()
    }
    
    private func didUploadData() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(title: "Choose file", style: .default, handler: { _ in
            
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        self.present(alertController, animated: true)
    }
    
    // MARK: Methods
    
    // Return the documents path + file name
    func localFilePath(for url: URL) -> URL {
        return documentPath.appendingPathComponent(url.lastPathComponent)
    }
    
    // MARK: TableView DataSource & Delegate
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return files.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FileCell", for: indexPath) as! FileTableViewCell
        
        
        return cell
    }
}

// MARK: URLSessionDelegate
extension HomeController: URLSessionDelegate {
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        DispatchQueue.main.async {
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate,
               let completionHandler = appDelegate.backgroundSessionCompletionHandler{
                
                appDelegate.backgroundSessionCompletionHandler = nil
                
                completionHandler()
            }
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        if totalBytesExpectedToWrite > 0 {
            let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
            print("Progress \(downloadTask) \(progress)")
        }
    }
    
    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        print("🔴 \(#function) - with error: \(error?.localizedDescription ?? "")")
    }
}

// MARK: URLSessionDownloadDelegate
extension HomeController: URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard let sourceURL = downloadTask.originalRequest?.url else {
            return
        }
        
        // Create target path
        let targetPath = localFilePath(for: sourceURL)
        
        print("** \(targetPath)")
        print("** \(location)")
        
        // First, remove file, if it was previously downloaded
        let fileManager = FileManager.default
        try? fileManager.removeItem(at: targetPath)
        
        // Write file to target location
        do {
            try fileManager.copyItem(at: location, to: targetPath)
        } catch {
            print("🔴 Error copying file to disk: \(error.localizedDescription)")
        }
        
        do {
            let text = try String(contentsOf: targetPath, encoding: .utf8)
            print("⚠️ \(text)")
            
            //self.files.append(File(link: targetPath.path + targetPath.pathExtension, data: text))
        } catch {
            print("🔴 Error reading file")
        }
    }
}

// MARK: URLSessionDataDelegate
extension HomeController: URLSessionDataDelegate {
    // Error received
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            print("🔴 Error: \(error.localizedDescription)")
        }
    }
    
    // Response received
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        print("⚠️ \(#function)")
        
        completionHandler(URLSession.ResponseDisposition.allow)
    }
    
    // Data received
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        print("⚠️ \(#function)")
        
        // Convert to JSON
        do {
            
            guard let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? NSDictionary,
                  let success = jsonResult["success"] as? Bool,
                  let key = jsonResult["key"] as? String,
                  let link = jsonResult["link"] as? String,
                  let expiry = jsonResult["expiry"] as? String else {
                
                return
            }
            
            
            self.file = File(success: success, key: key, link: link, expiry: expiry)
        } catch {
            print("🔴 Error converting server response to JSON")
        }
        
        // Print to the UI or add to the array of files
        // in the TableView
        if let responseText = String(data: data, encoding: .utf8) {
            print("⚪️ \(responseText)")
        }
    }
}
