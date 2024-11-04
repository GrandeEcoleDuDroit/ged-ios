extension String {
    var trimmedAndCapitalized: String {
        // Trim the string
        let trimmedText = self.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Check if the trimmed text is empty
        guard !trimmedText.isEmpty else {
            return ""
        }
        
        // Capitalize the first letter
        let firstLetter = trimmedText.prefix(1).uppercased()
        let remainingText = trimmedText.dropFirst()
        
        return firstLetter + remainingText
    }
}
