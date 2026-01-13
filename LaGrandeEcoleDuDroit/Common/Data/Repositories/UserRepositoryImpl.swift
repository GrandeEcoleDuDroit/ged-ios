import Foundation
import Combine

class UserRepositoryImpl: UserRepository {
    private let userLocalDataSource: UserLocalDataSource
    private let userRemoteDataSource: UserRemoteDataSource
    private let tag = String(describing: UserRepositoryImpl.self)
    private var userSubject = CurrentValueSubject<User?, Never>(nil)
    var user: AnyPublisher<User, Never> {
        userSubject
            .compactMap{ $0 }
            .eraseToAnyPublisher()
    }
    var currentUser: User? {
        userSubject.value
    }
    
    init(userLocalDataSource: UserLocalDataSource, userRemoteDataSource: UserRemoteDataSource) {
        self.userLocalDataSource = userLocalDataSource
        self.userRemoteDataSource = userRemoteDataSource
        initUser()
    }
    
    func getUsers() async throws -> [User] {
        do {
            return try await userRemoteDataSource.getUsers()
        } catch {
            e(tag, "Error getting users", error)
            throw error
        }
    }
    
    func getUserPublisher(userId: String) -> AnyPublisher<User?, Error> {
        userRemoteDataSource.listenUser(userId: userId)
    }
    
    func getCurrentUser() -> User? {
        userLocalDataSource.getUser()
    }
    
    func getUser(userId: String) async throws -> User? {
        do {
            return try await userRemoteDataSource.getUser(userId: userId)
        } catch {
            e(tag, "Error getting user \(userId)", error)
            throw error
        }
    }
    
    func createUser(user: User) async throws {
        do {
            try await userRemoteDataSource.createUser(user: user)
            try? userLocalDataSource.storeUser(user: user)
            userSubject.send(user)
        } catch {
            e(tag, "Error creating user \(user.id)", error)
            throw error
        }
    }
    
    func storeUser(_ user: User) {
        do {
            try userLocalDataSource.storeUser(user: user)
            userSubject.send(user)
        } catch {
            e(tag, "Error storing user \(user.id)", error)
        }
    }
    
    func updateProfilePicture(user: User, imageData: Data, fileName: String) async throws {
        do {
            try await userRemoteDataSource.updateProfilePicture(user: user, imageData: imageData, fileName: fileName)
            try? userLocalDataSource.updateProfilePictureFileName(fileName: fileName)
        } catch {
            e(tag, "Error updating profile picture of user \(user.id)", error)
            throw error
        }
    }
    
    func deleteUser(user: User) async throws {
        do {
            try await userRemoteDataSource.deleteUser(user: user)
            userLocalDataSource.deleteUser()
            userSubject.send(nil)
        } catch {
            e(tag, "Error deleting user \(user.id)", error)
            throw error
        }
    }
    
    func deleteLocalUser() {
        userLocalDataSource.deleteUser()
    }
    
    func deleteProfilePicture(user: User) async throws {
        do {
            try await userRemoteDataSource.deleteProfilePicture(user: user)
            try? userLocalDataSource.updateProfilePictureFileName(fileName: nil)
        } catch {
            e(tag, "Error deleting profile picture of user \(user.id)", error)
            throw error
        }
    }
    
    func reportUser(report: UserReport) async throws {
        do {
            try await userRemoteDataSource.reportUser(report: report)
        } catch {
            e(tag, "Error reporting user \(report.reportedUser.email)", error)
            throw error
        }
    }
    
    private func initUser() {
        userSubject.send(userLocalDataSource.getUser())
    }
}
