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
    
    func trimmedAndCapitalizedFirstLetter() -> String {
        let trimmedText = self.trim()
        
        guard !trimmedText.isEmpty else {
            return ""
        }
        
        let firstLetter = trimmedText.prefix(1).uppercased()
        let remainingText = trimmedText.dropFirst()
        
        return firstLetter + remainingText
    }
    
    func uppercaseFirstLetter() -> String {
        let firstLetter = self.prefix(1).uppercased()
        let remainingText = self.dropFirst()
        return firstLetter + remainingText
    }
    
    func toInt() -> Int {
        Int(self)!
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
