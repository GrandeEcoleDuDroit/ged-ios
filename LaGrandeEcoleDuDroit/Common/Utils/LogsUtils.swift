import os
import FirebaseCrashlytics

private let crashlytics = Crashlytics.crashlytics()

func d(_ tag: String, _ message: String) {
    let logger = Logger(subsystem: "com.upsaclay.gedoise", category: tag)
    logger.debug("🔄 \(message)")
}

func i(_ tag: String, _ message: String) {
    let logger = Logger(subsystem: "com.upsaclay.gedoise", category: tag)
    logger.info("🚹 \(message)")
}

func w(_ tag: String, _ message: String) {
    let logger = Logger(subsystem: "com.upsaclay.gedoise", category: tag)
    logger.warning("⚠️ \(message)")
}

func e(_ tag: String, _ message: String, _ error: Error? = nil) {
    let logger = Logger(subsystem: "com.upsaclay.gedoise", category: tag)
    logger.critical("🛑 \(message)")
    #if DEBUG
    #else
    crashlytics.log("\(tag): \(message)")
    if let error = error {
        crashlytics.recordError(error)
    }
    #endif
}
