import os
import FirebaseCrashlytics

private let crashlytics = Crashlytics.crashlytics()

func d(_ tag: String, _ message: String) {
    let logger = Logger(subsystem: "com.upsaclay.gedoise", category: tag)
    logger.debug("\(message)")
}

func i(_ tag: String, _ message: String) {
    let logger = Logger(subsystem: "com.upsaclay.gedoise", category: tag)
    logger.info("\(message)")
}

func w(_ tag: String, _ message: String) {
    #if DEBUG
    let logger = Logger(subsystem: "com.upsaclay.gedoise", category: tag)
    logger.warning("\(message)")
    #else
    let logger = Logger(subsystem: "com.upsaclay.gedoise", category: tag)
    logger.warning("\(message)")
    crashlytics.log("\(tag): \(message)")
    #endif
}

func e(_ tag: String, _ message: String, _ error: Error? = nil) {
    #if DEBUG
    let logger = Logger(subsystem: "com.upsaclay.gedoise", category: tag)
    logger.error("\(message)")
    #else
    let logger = Logger(subsystem: "com.upsaclay.gedoise", category: tag)
    logger.error("\(message)")
    crashlytics.log("\(tag): \(message)")
    if let error = error {
        crashlytics.recordError(error)
    }
    #endif
}
