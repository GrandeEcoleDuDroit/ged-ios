import Foundation

enum ImageError: Error {
    case invalidFormat
}

extension ImageError: LocalizedError {
    var errorDescription: String? {
        switch self {
            case .invalidFormat: stringResource(.invalidImageFormatError)
        }
    }
}
