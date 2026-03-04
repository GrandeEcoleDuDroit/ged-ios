import Foundation

struct AuthToken {
    let token: String
    let expirationDate: Date
    
    func isValid() -> Bool {
        Date() < expirationDate
    }
}

enum AuthTokenState {
    case valid(String)
    case unauthenticated
    case error(Error? = nil)
}
