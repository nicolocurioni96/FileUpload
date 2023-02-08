//
//  UploadService.swift
//  FileUpload
//
//  Created by Nicolò Curioni on 08/02/23.
//

import Foundation

class UploadService {
    var uploadSession: URLSession!
    
    func start(file: File) {
        let uploadTask = UploadTask(file: file)
        let uploadData = Data(file.data.utf8)
        
        // Create the request
        guard let url = URL(string: file.link) else {
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // Create the upload task
        uploadTask.task = uploadSession.uploadTask(with: request, from: uploadData)
        
        // Start the upload process
        uploadTask.task?.resume()
        uploadTask.inProgress = true
    }
}
