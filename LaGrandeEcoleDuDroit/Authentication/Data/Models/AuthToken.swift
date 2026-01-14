import Foundation

struct AuthToken {
    let token: String
    let expirationDate: Date
    
    func isValid() -> Bool {
        Date() < expirationDate
    }
}
