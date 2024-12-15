import os

func d(_ tag: String, _ message: String) {
    let logger = Logger(subsystem: "com.upsaclay.gedoise", category: tag)
    logger.debug("\(message)")
}

func e(_ tag: String, _ message: String) {
    let logger = Logger(subsystem: "com.upsaclay.gedoise", category: tag)
    logger.error("\(message)")
}

func i(_ tag: String, _ message: String) {
    let logger = Logger(subsystem: "com.upsaclay.gedoise", category: tag)
    logger.info("\(message)")
}

func w(_ tag: String, _ message: String) {
    let logger = Logger(subsystem: "com.upsaclay.gedoise", category: tag)
    logger.warning("\(message)")
}
