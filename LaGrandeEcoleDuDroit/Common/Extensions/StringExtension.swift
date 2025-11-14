extension String {
    func isBlank() -> Bool {
        self.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    func trimmedAndCapitalizedFirstLetter() -> String {
        let trimmedText = self.trimmingCharacters(in: .whitespacesAndNewlines)
        
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
}

extension String? {
    func toString() -> String {
        self ?? ""
    }
}
