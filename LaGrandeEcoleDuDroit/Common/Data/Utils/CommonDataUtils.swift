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
        e(tag, "\(message.toString()): \(error.localizedDescription)", error)
        switch error.code {
            case .notConnectedToInternet, .cannotFindHost: throw NetworkError.noInternetConnection
            default : throw error
        }
    }
    
    catch let error as NSError {
        e(tag, "\(message.toString()): \(error.localizedDescription)", error)
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
        e(tag, "\(message.toString()): \(error.localizedDescription)", error)
        throw handleSpecificException(error)
    }
}

func mapServerError(
    block: () async throws -> (URLResponse, ServerResponse),
    tag: String = "Unknown tag",
    message: String? = nil,
    specificHandle: ((URLResponse, ServerResponse) throws -> Void)? = nil
) async throws -> Void {
    do {
        let (urlResponse, serverResponse) = try await block()
        
        if let httpResponse = urlResponse as? HTTPURLResponse {
            if httpResponse.statusCode >= 400 {
                e(tag, "\(message.toString()): \(serverResponse.error.toString())")
                guard specificHandle == nil else {
                    return try specificHandle!(urlResponse, serverResponse)
                }
                
                throw NetworkError.internalServer(serverResponse.error)
            }
        }
    } catch {
        e(tag, "\(message.toString()): \(error.localizedDescription)", error)
        throw error
    }
}

func mapServerError<T>(
    block: () async throws -> (URLResponse, T),
    tag: String = "Unknown tag",
    message: String? = nil,
    specificHandle: ((URLResponse, T) -> T)? = nil
) async throws -> T {
    do {
        let (urlResponse, data) = try await block()
        
        if let httpResponse = urlResponse as? HTTPURLResponse {
            if httpResponse.statusCode >= 400 {
                let serverResponse = data as? ServerResponse
                e(tag, "\(message.toString()): \(serverResponse?.error ?? "No error response")")
                
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
    } catch {
        e(tag, "\(message.toString()): \(error.localizedDescription)", error)
        throw error
    }
}
