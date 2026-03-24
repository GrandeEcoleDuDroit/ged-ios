import Foundation

public struct MultipartRequest {
    private let boundary: String = "Boundary-\(UUID().uuidString)"
    private let separator: String = "\r\n"
    private var data: Data = Data()
    
    var headerValue: String {
        "multipart/form-data; boundary=\(boundary)"
    }

    var body: Data {
        var bodyData = data
        bodyData.append("--\(boundary)--")
        return bodyData
    }
    
    init() {}

    mutating func addValue(name: String, value: String) {
        appendBoundary()
        appendContentDisposition(name: name)
        data.append(value + separator)
    }
    
    mutating func addJsonValue<T>(name: String, jsonValue: T) throws where T: Encodable {
        appendBoundary()
        appendJsonContentDisposition(name: name)
        appendContentType(mimeType: "application/json")
        data.append(try JSONEncoder().encode(jsonValue))
        appendSeparator()
    }

    mutating func addImage(fileData: FileData) {
        appendBoundary()
        appendImageContentDisposition(fileName: fileData.name)
        appendContentType(mimeType: "image/\(fileData.fileExtension)")
        data.append(fileData.data)
        appendSeparator()
    }

    private mutating func appendBoundary() {
        data.append("--\(boundary)\(separator)")
    }
    
    private mutating func appendSeparator() {
        data.append(separator)
    }
    
    private mutating func appendContentDisposition(name: String) {
        data.append("Content-Disposition: form-data; name=\"\(name)\"" + separator.repeatText(2))
    }
    
    private mutating func appendContentType(mimeType: String) {
        data.append("Content-Type: \(mimeType)" + separator.repeatText(2))
    }
}

extension MultipartRequest {
    private mutating func appendJsonContentDisposition(name: String) {
        data.append("Content-Disposition: form-data; name=\"\(name)\"" + separator)
    }
    
    private mutating func appendImageContentDisposition(fileName: String) {
        data.append("Content-Disposition: form-data; name=\"image\"; filename=\"\(fileName)\"" + separator)
    }
}
