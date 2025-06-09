import os
import FirebaseCrashlytics

private let crashlytics = Crashlytics.crashlytics()
private let subsystem = "com.upsaclay.gedoise"

func d(_ tag: String, _ message: String) {
    let logger = Logger(subsystem: subsystem, category: tag)
    let date = DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .medium)
    logger.debug("🔄 \(date) \(tag)\t\(subsystem)\t D \(message)")
}

func i(_ tag: String, _ message: String) {
    let logger = Logger(subsystem: subsystem, category: tag)
    let date = DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .medium)
    logger.info("🚹 \(date) \(tag)\t\(subsystem)\t I \(message)")
}

func w(_ tag: String, _ message: String) {
    let logger = Logger(subsystem: subsystem, category: tag)
    let date = DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .medium)
    logger.warning("⚠️ \(date) \(tag)\t\(subsystem)\t W \(message)")
}

func e(_ tag: String, _ message: String, _ error: Error? = nil) {
    let logger = Logger(subsystem: subsystem, category: tag)
    let date = DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .medium)
    logger.critical("🛑 \(date) \(tag)\t\(subsystem)\t E \(message)")
    logger.critical("🛑 \(message)")
    #if DEBUG
    #else
    crashlytics.log("\(date) \(tag)\t\(subsystem)\t E \(message)")
    if let error = error {
        crashlytics.recordError(error)
    }
    #endif
}
