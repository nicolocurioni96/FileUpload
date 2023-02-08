//
//  File.swift
//  FileUpload
//
//  Created by Nicolò Curioni on 08/02/23.
//

import Foundation

class File: Codable {
    var success: Bool = false
    var key: String = ""
    var link: String = ""
    var expiry: String = ""
    var data: String = ""
    
    init(link: String, data: String) {
        self.link = link
        self.data = data
    }
    
    init(success: Bool, key: String, link: String, expiry: String) {
        self.success = success
        self.key = key
        self.link = link
        self.expiry = expiry
    }
}
