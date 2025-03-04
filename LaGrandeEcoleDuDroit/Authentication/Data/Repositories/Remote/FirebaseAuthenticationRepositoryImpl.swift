import Foundation
import FirebaseAuth

private let tag = String(describing: FirebaseAuthenticationRepositoryImpl.self)

class FirebaseAuthenticationRepositoryImpl: FirebaseAuthenticationRepository {
    private let firebaseAuthApi: FirebaseAuthApi
    
    init(firebaseAuthApi: FirebaseAuthApi) {
        self.firebaseAuthApi = firebaseAuthApi
    }
    
    func loginWithEmailAndPassword(email: String, password: String) async throws {
        do {
            try await firebaseAuthApi.signIn(email: email, password: password)
        } catch let error as NSError {
            e(tag, error.localizedDescription, error)
            if let authErrorCode = AuthErrorCode(rawValue: error.code) {
                switch authErrorCode {
                    case .wrongPassword, .userNotFound, .invalidCredential:
                        throw AuthenticationError.invalidCredentials
                    case .userDisabled:
                        throw AuthenticationError.userDisabled
                    case .networkError:
                        throw AuthenticationError.network
                    case .tooManyRequests:
                        throw AuthenticationError.tooManyRequests
                    default:
                        throw AuthenticationError.unknown
                }
            } else {
                throw AuthenticationError.unknown
            }
        }
        catch {
            e(tag, error.localizedDescription, error)
            throw AuthenticationError.unknown
        }
    }
    
    func registerWithEmailAndPassword(email: String, password: String) async throws {
        do {
            try await firebaseAuthApi.createUserWithEmail(email: email, password: password)
        } catch let error as NSError {
            e(tag, error.localizedDescription, error)
            if let authErrorCode = AuthErrorCode(rawValue: error.code) {
                switch authErrorCode {
                    case .emailAlreadyInUse, .credentialAlreadyInUse:
                        throw AuthenticationError.accountAlreadyExist
                    case .networkError:
                        throw AuthenticationError.network
                    case .tooManyRequests:
                        throw AuthenticationError.tooManyRequests
                    default:
                        throw AuthenticationError.unknown
                }
            } else {
                throw AuthenticationError.unknown
            }
        }
        catch {
            e(tag, error.localizedDescription, error)
            throw AuthenticationError.unknown
        }
    }
    
    func logout() async throws {
        do {
            try await firebaseAuthApi.signOut()
        } catch let error as NSError {
            e(tag, error.localizedDescription, error)
            if let authErrorCode = AuthErrorCode(rawValue: error.code) {
                switch authErrorCode {
                    case .networkError:
                        throw AuthenticationError.network
                    case .tooManyRequests:
                        throw AuthenticationError.tooManyRequests
                    default:
                        throw AuthenticationError.unknown
                }
            } else {
                throw AuthenticationError.unknown
            }
        }
        catch {
            e(tag, error.localizedDescription, error)
            throw AuthenticationError.unknown
        }
    }
    
    func sendEmailVerification() async throws {
        do {
            try await firebaseAuthApi.sendEmailVerification()
        } catch let error as NSError {
            e(tag, error.localizedDescription, error)
            if let authErrorCode = AuthErrorCode(rawValue: error.code) {
                switch authErrorCode {
                    case .networkError:
                        throw AuthenticationError.network
                    case .tooManyRequests:
                        throw AuthenticationError.tooManyRequests
                    default:
                        throw AuthenticationError.unknown
                }
            } else {
                throw AuthenticationError.unknown
            }
        }
        catch {
            e(tag, error.localizedDescription, error)
            throw AuthenticationError.unknown
        }
    }
    
    func isEmailVerified() async throws -> Bool {
        do {
            return try await firebaseAuthApi.isEmailVerified()
        } catch let error as NSError {
            e(tag, error.localizedDescription, error)
            if let authErrorCode = AuthErrorCode(rawValue: error.code) {
                switch authErrorCode {
                    case .userNotFound:
                        throw AuthenticationError.userNotFound
                    case .networkError:
                        throw AuthenticationError.network
                    case .tooManyRequests:
                        throw AuthenticationError.tooManyRequests
                    default:
                        throw AuthenticationError.unknown
                }
            } else {
                throw AuthenticationError.unknown
            }
        }
        catch {
            e(tag, error.localizedDescription, error)
            throw AuthenticationError.unknown
        }
    }
    
    func resetPassword(email: String) async throws {
        do {
            try await firebaseAuthApi.resetPassword(email: email)
        } catch let error as NSError {
            e(tag, error.localizedDescription, error)
            if let authErrorCode = AuthErrorCode(rawValue: error.code) {
                switch authErrorCode {
                    case .userNotFound:
                        throw AuthenticationError.userNotFound
                    case .networkError:
                        throw AuthenticationError.network
                    case .tooManyRequests:
                        throw AuthenticationError.tooManyRequests
                    default:
                        throw AuthenticationError.unknown
                }
            }
        }
        catch {
            e(tag, error.localizedDescription, error)
            throw AuthenticationError.unknown
        }
    }
    
    func isAuthenticated() -> Bool {
        firebaseAuthApi.isAuthenticated()
    }
}
