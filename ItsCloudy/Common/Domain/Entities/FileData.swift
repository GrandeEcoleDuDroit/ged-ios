import Foundation

struct FileData {
    let path: String
    let data: Data
    
    var name: String {
        (path as NSString).lastPathComponent
    }
    
    var fileExtension: String {
        (name as NSString).pathExtension
    }
}
