struct FcmData<T: Encodable>: Encodable {
    let type: FcmDataType
    let value: T
}

enum FcmDataType: String, Encodable {
    case message = "message"
}
