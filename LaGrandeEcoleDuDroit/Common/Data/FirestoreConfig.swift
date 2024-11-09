import FirebaseFirestore

class FirestoreConfig {
    init() {
        #if DEBUG
        let settings = FirestoreSettings()
        settings.host = "127.0.0.1:8080"
        settings.cacheSettings = MemoryCacheSettings()
        settings.isSSLEnabled = false
        Firestore.firestore().settings = settings
        #endif
    }
}
