//
//  Document.swift
//  FileUpload
//
//  Created by Nicolò Curioni on 08/02/23.
//

import Foundation

class DocumentFile {
    var id = UUID().uuidString
    var name: String = ""
    var size: Double = 0
    var data: Data? = nil
    
    init(id: String = UUID().uuidString, name: String, size: Double, data: Data? = nil) {
        self.id = id
        self.name = name
        self.size = size
        self.data = data
    }
}
