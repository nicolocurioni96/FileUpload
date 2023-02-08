//
//  DownloadService.swift
//  FileUpload
//
//  Created by Nicolò Curioni on 08/02/23.
//

import Foundation

class DownloadService {
    var downloadSession: URLSession!
    
    func start(file: File) {
        let downloadTask = DownloadTask(file: file)
        
        guard let downloadTaskURL = downloadTask.url else {
            return
        }
        
        // Create request
        let request = NSMutableURLRequest(url: downloadTaskURL)
        
        request.httpMethod = "GET"
        
        // Create download task
        downloadTask.task = downloadSession.downloadTask(with: request as URLRequest)
        downloadTask.task?.resume()
        downloadTask.inProgress = true
    }
}
