import Foundation

class OracleApiImpl: OracleApi {
    func createUser(oracleUser: OracleUser) async throws {
        guard let url = URL(string: "\(serverBaseUrl)/users/create") else {
            throw NSError(domain: "Invalid URL", code: HttpErrorCode.notFound, userInfo: nil)
        }
        
        let userJson = try JSONEncoder().encode(oracleUser)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = userJson
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NSError(domain: "NetworkError", code: HttpErrorCode.internalServerError, userInfo: nil)
        }
        
        if (200...299).contains(httpResponse.statusCode) {
            let serverResponse = try JSONDecoder().decode(ServerResponse.self, from: data)
            print(serverResponse)
        } else {
            let serverResponse = try JSONDecoder().decode(ServerResponse.self, from: data)
            throw NSError(domain: "ServerError", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: serverResponse.error ?? "Error to create uer"])
        }
    }
}
