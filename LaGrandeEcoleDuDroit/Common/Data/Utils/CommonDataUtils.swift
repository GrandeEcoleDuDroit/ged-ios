import Foundation
import FirebaseFirestore

func mapFirebaseException<T>(
    block: () async throws -> T,
    tag: String = "Unknown tag",
    message: String? = nil,
    handleSpecificException: (Error) -> Error = { $0 }
) async throws -> T {
    do {
        return try await block()
    }
    catch let error as URLError {
        e(tag, error.localizedDescription, error)
        switch error.code {
            case .notConnectedToInternet, .cannotFindHost: throw NetworkError.noInternetConnection
            default : throw error
        }
    }
    
    catch let error as NSError {
        e(tag, error.localizedDescription, error)
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
        e(tag, error.localizedDescription, error)
        throw handleSpecificException(error)
    }
}

func mapRetrofitError(
    block: () async throws -> (URLResponse, ServerResponse),
    specificHandle: ((URLResponse, ServerResponse) throws -> Void)? = nil
) async throws -> Void {
    let (urlResponse, serverResponse) = try await block()
    
    if let httpResponse = urlResponse as? HTTPURLResponse {
        if httpResponse.statusCode >= 400 {
            guard specificHandle == nil else {
                return try specificHandle!(urlResponse, serverResponse)
            }
            
            throw NetworkError.internalServer(serverResponse.error)
        }
    }
}

func handleRetrofitError<T>(
    block: () async throws -> (URLResponse, T),
    specificHandle: ((URLResponse, T) -> T)? = nil
) async throws -> T {
    let (urlResponse, data) = try await block()
    
    if let httpResponse = urlResponse as? HTTPURLResponse {
        if httpResponse.statusCode >= 400 {
            guard specificHandle == nil else {
                return specificHandle!(urlResponse, data)
            }
            
            if let data = data as? Data {
                let errorBody = String(data: data, encoding: .utf8)
                throw NetworkError.internalServer(errorBody)
            } else {
                throw NetworkError.internalServer(nil)
            }
        } else {
            return data
        }
    } else {
        return data
    }
}

