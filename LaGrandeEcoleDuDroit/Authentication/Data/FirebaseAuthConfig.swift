import FirebaseAuth

class FirebaseAuthConfig {
    init() {
        #if DEBUG
        Auth.auth().useEmulator(withHost:"127.0.0.1", port:9099)
        #endif
    }
}
