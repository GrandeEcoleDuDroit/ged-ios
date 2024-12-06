import FirebaseAuth
import FirebaseFirestore

class GedConfig {
    #if DEBUG
    static let serverUrl = "http://192.168.1.67:3000" // Set your local server url here
    #else
    static let serverUrl = "http:89.168.52.45//:3000"
    #endif
    
    init() {
//        #if DEBUG
////      Firebase Auth
//        Auth.auth().useEmulator(withHost:"127.0.0.1", port:9099)
//
////      Firestore
//        let settings = FirestoreSettings()
//        settings.host = "127.0.0.1:8080"
//        settings.cacheSettings = MemoryCacheSettings()
//        settings.isSSLEnabled = false
//        Firestore.firestore().settings = settings
//        #endif
    }
}
