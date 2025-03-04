import Foundation

private let tag = String(describing: ImageApiImpl.self)

class ImageApiImpl: ImageApi {
    private func baseUrl(endPoint: String) -> URL? {
        URL.oracleUrl(endpoint: "/image/" + endPoint)
    }
    
    func uploadImage(imageData: Data, fileName: String) async throws {
        guard let url = baseUrl(endPoint: "upload") else {
            throw RequestError.invalidURL("Invalid URL")
        }
        let fileExtension = (fileName as NSString).pathExtension
        
        let boundary = "Boundary-\(UUID().uuidString)"
        
        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/\(fileExtension)\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.setValue("\(body.count)", forHTTPHeaderField: "Content-Length")
        request.httpBody = body
        
        let session = RequestUtils.getUrlSession()
        let (dataReceived, response) = try await session.data(for: request)
        let serverResponse = try JSONDecoder().decode(ServerResponse.self, from: dataReceived)
        
        if let httpResponse = response as? HTTPURLResponse {
            if httpResponse.statusCode >= 200 && httpResponse.statusCode < 300 {
                e(tag, serverResponse.message)
            } else {
                e(tag, serverResponse.error ?? "Error to upload image")
                throw RequestError.invalidResponse(serverResponse.error)
            }
        } else {
            e(tag, serverResponse.error ?? "Error to upload image")
            throw RequestError.invalidResponse(serverResponse.error)
        }
    }
}
