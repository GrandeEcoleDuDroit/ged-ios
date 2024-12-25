extension String {
    var isBlank: Bool {
        self.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var trimmedAndCapitalizedFirstLetter: String {
        let trimmedText = self.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedText.isEmpty else {
            return ""
        }
        
        let firstLetter = trimmedText.prefix(1).uppercased()
        let remainingText = trimmedText.dropFirst()
        
        return firstLetter + remainingText
    }
}
