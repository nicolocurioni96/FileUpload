//
//  HomeController.swift
//  FileUpload
//
//  Created by Nicolò Curioni on 08/02/23.
//

import UIKit
import MobileCoreServices
import UniformTypeIdentifiers
import Photos

class HomeController: UITableViewController {
    
    // MARK: Outlets
    @IBOutlet weak var uploadDocumentButton: UIBarButtonItem!
    
    var file: File? = nil
    var files: [DocumentFile] = []
    var imagePicker = UIImagePickerController()
    
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
        
        // Set the URLSession on the download service
        downloadService.downloadSession = downloadSession
        uploadService.uploadSession = uploadSession
        
        imagePicker.delegate = self
    }
    
    // MARK: IBActions
    @IBAction func uploadFile(_ sender: Any) {
        didUploadData()
    }
    
    private func uploadDocument() {
        //        let file = File(link: "https://file.io",data: "text=this is the file content");
        //        uploadService.start(file: file)
    }
    
    private func downloadDocument() {
        let file = File(link: "https://file.io",data: "text=this is the file content");
        downloadService.start(file: file)
    }
    
    private func didUploadData() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(title: "Choose file", style: .default, handler: { _ in
            self.chooseFile()
        }))
        
        alertController.addAction(UIAlertAction(title: "Choose image", style: .default, handler: { _ in
            self.chooseImageFromGallery()
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        self.present(alertController, animated: true)
    }
    
    private func chooseFile() {
        let requiredTypes = [UTType.bmp, UTType.jpeg, UTType.pdf, UTType.tiff]
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: requiredTypes, asCopy: true)
        
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        documentPicker.shouldShowFileExtensions = true
        
        self.present(documentPicker, animated: true)
    }
    
    private func chooseImageFromGallery() {
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
            imagePicker.sourceType = .savedPhotosAlbum
            imagePicker.allowsEditing = false
            
            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    // MARK: Methods
    
    // Return the documents path + file name
    func localFilePath(for url: URL) -> URL {
        return documentPath.appendingPathComponent(url.lastPathComponent)
    }
    
    private func getImageFileSize(from asset: PHAsset) -> Double {
        let resource = PHAssetResource.assetResources(for: asset)
        let imageSizeByte = resource.first?.value(forKey: "fileSize") as! Double
        let imageSizeMB = imageSizeByte / (1024.0 * 1024.0)
        return imageSizeMB
    }
    
    // MARK: TableView DataSource & Delegate
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return files.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FileCell", for: indexPath) as! FileTableViewCell
        let document = self.files[indexPath.row]
        
        cell.labelTitle.adjustsFontSizeToFitWidth = true
        cell.labelTitle.text = document.name
        cell.imageViewIcon.image = UIImage(data: document.data ?? Data())
        cell.labelSubtitle.text = "\(document.size) MB"
        
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

// MARK: UIDocumentPickerDelegate
extension HomeController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let file = urls.first else {
            return
        }
        
        let fileName = file.deletingPathExtension().lastPathComponent
        
        do {
            let attribute = try FileManager.default.attributesOfItem(atPath: file.path)
            
            if let size = attribute[FileAttributeKey.size] as? NSNumber {
                let fileSizeInMB = size.doubleValue / 1000000.0
                
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    
                    self.files.append(DocumentFile(name: fileName, size: fileSizeInMB, data: file.dataRepresentation))
                    self.tableView.reloadData()
                }
                
                print("⚠️ Import result: \(fileName) with \(fileSizeInMB) MB of size")
            }
        } catch {
            print("Error: \(error)")
        }
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print("⚠️ Document was cancelled, during the import operation")
    }
}

// MARK: UINavigationControllerDelegate &  UIImagePickerControllerDelegate
extension HomeController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        guard let image = info[.originalImage] as? UIImage else {
            /// Don't use `fatalError` in Production!
            /// Use only for Debug purposes.
            fatalError("⚠️ Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        
        guard let imageData = image.pngData(),
        let asset = info[UIImagePickerController.InfoKey.phAsset] as? PHAsset else {
            return
        }
     
        let assetResources = PHAssetResource.assetResources(for: asset)
            
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.files.append(DocumentFile(name: assetResources.first?.originalFilename ?? "", size: self.getImageFileSize(from: asset), data: imageData))
            self.tableView.reloadData()
        }
    }
}
