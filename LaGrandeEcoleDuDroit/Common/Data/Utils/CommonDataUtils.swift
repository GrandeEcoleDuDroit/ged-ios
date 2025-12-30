import Foundation
import FirebaseFirestore

func mapFirebaseError<T>(
    block: () async throws -> T,
    tag: String = "Unknown tag",
    message: String? = nil,
    handleSpecificException: (Error) -> Error = { $0 }
) async throws -> T {
    do {
        return try await block()
    }
    catch let error as URLError {
        e(tag, message.orEmpty(), error)
        switch error.code {
            case .notConnectedToInternet, .cannotFindHost: throw NetworkError.noInternetConnection
            default : throw error
        }
    }
    
    catch let error as NSError {
        e(tag, message.orEmpty(), error)
        if let errorCode = FirestoreErrorCode.Code(rawValue: error.code) {
            switch errorCode {
                case .resourceExhausted:
                    throw NetworkError.tooManyRequests
                default:
                    throw handleSpecificException(error)
            }
        } else {
            throw handleSpecificException(error)
        }
    }
    
    catch {
        e(tag, message.orEmpty(), error)
        throw handleSpecificException(error)
    }
}

func mapServerError(
    block: () async throws -> (URLResponse, ServerResponse),
    tag: String = "Unknown tag",
    message: String? = nil,
    specificHandle: ((URLResponse, ServerResponse) throws -> Void)? = nil
) async throws -> Void {
    let (urlResponse, serverResponse) = try await block()
    
    if let httpResponse = urlResponse as? HTTPURLResponse {
        if httpResponse.statusCode >= 400 {
            e(tag, "\(message.orEmpty()): \(serverResponse.error.orEmpty())")

            guard specificHandle == nil else {
                return try specificHandle!(urlResponse, serverResponse)
            }
            
            throw NetworkError.internalServer(serverResponse.error.orEmpty())
        }
    }
}

func mapServerError<T>(
    block: () async throws -> (URLResponse, T),
    tag: String = "Unknown tag",
    message: String? = nil,
    specificHandle: ((URLResponse, T) -> T)? = nil
) async throws -> T {
    let (urlResponse, data) = try await block()
    
    if let httpResponse = urlResponse as? HTTPURLResponse {
        if httpResponse.statusCode >= 400 {
            let serverResponse = data as? ServerResponse
            e(tag, "\(message.orEmpty()): \(String(describing: serverResponse?.error))")

            guard specificHandle == nil else {
                return specificHandle!(urlResponse, data)
            }
            
            throw NetworkError.internalServer(serverResponse?.error)
        } else {
            return data
        }
    } else {
        return data
    }
}
