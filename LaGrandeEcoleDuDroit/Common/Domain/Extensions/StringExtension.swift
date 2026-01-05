extension String {
    func trim() -> String {
        self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func isBlank() -> Bool {
        self.trim().isEmpty
    }
    
    func isNotBlank() -> Bool {
        !self.trim().isEmpty
    }
    
    func capitalizeFirstLetters(separator: Character = " ") -> String {
        let split = self.split(separator: separator)
        var result: [String] = []
        
        split.forEach { s in
            let firstLetter = s.prefix(1).uppercased()
            let remainingText = s.dropFirst()
            result += [firstLetter + remainingText]
        }
        
        return result.joined(separator: String(separator))
    }
    
    func toInt() -> Int {
        Int(self)!
    }
    
    func toIntOrDefault(_ value: Int) -> Int {
        Int(self) ?? value
    }
    
    func toInt32OrDefault(_ value: Int32) -> Int32 {
        Int32(self) ?? value
    }
    
    func take(_ n: Int) -> String {
        String(self.prefix(n))
    }
}

extension String? {
    func orEmpty() -> String {
        self ?? ""
    }
}
