import FirebaseFirestore

extension Query {
    func withOffsetTime(_ offsetTime: Timestamp?) -> Query {
        if let offsetTime {
            self.whereField(MessageField.timestamp, isGreaterThanOrEqualTo: offsetTime)
        } else {
            self
        }
    }
}
