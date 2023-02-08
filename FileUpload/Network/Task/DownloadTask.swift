//
//  DownloadTask.swift
//  FileUpload
//
//  Created by Nicolò Curioni on 08/02/23.
//

import Foundation

class DownloadTask {
    var file: File
    var url: URL?
    var inProgress = false
    var resumeData: Data?
    var task: URLSessionDownloadTask?
    
    init(file: File) {
        self.file = file
        self.url = URL(string: file.link)
    }
}
