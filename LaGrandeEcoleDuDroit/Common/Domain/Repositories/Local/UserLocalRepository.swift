protocol UserLocalRepository {
    func setCurrentUser(user: User)
    
    func getCurrentUser() -> User?
}
