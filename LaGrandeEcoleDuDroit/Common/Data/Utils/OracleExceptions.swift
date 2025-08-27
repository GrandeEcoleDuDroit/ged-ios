func parseOracleError(code: String?, message: String?) -> Error {
    switch code {
        case "ORA-12801": RequestError.dupplicateData
        default: RequestError.internalServer(message)
    }
}
    
