import Foundation

struct FcmMessage<T: Encodable>: Encodable {
    let notification: FcmNotification
    let data: FcmData<T>
    let android: AndroidConfig
    let apns: ApnsConfig
}
