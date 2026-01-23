enum AuthenticationState: Codable, Equatable {
    case authenticated(userId: String)
    case unauthenticated
    
    private var id: Int {
        switch self {
            case .authenticated: 1
            case .unauthenticated: 2
        }
    }
    
    static func == (lhs: AuthenticationState, rhs: AuthenticationState) -> Bool {
        lhs.id == rhs.id
    }
}
