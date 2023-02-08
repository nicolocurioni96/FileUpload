//
//  UploadTask.swift
//  FileUpload
//
//  Created by Nicolò Curioni on 08/02/23.
//

import Foundation

class UploadTask {
    var file: File
    var inProgress = false
    var task: URLSessionUploadTask?
    
    init(file: File) {
        self.file = file
    }
}
