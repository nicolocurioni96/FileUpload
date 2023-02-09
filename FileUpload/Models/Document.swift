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
    
    init(id: String = UUID().uuidString, name: String, size: Double) {
        self.id = id
        self.name = name
        self.size = size
    }
}
