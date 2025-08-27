func parseOracleError(code: String?, message: String?) -> Error {
    switch code {
        case "ORA-12801": NetworkError.dupplicateData
        default: NetworkError.internalServer(message)
    }
}
    
