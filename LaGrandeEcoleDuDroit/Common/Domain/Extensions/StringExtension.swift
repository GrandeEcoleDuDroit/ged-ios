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
    
    func capitalize() -> String {
        prefix(1).uppercased()
    }
    
    func capitalizeWords() -> String {
        let pattern = /(^|[\s'-])(\p{L})/

        return replacing(pattern) { match in
            let separator = match.1
            let letter = match.2
            return "\(separator)\(letter.uppercased())"
        }
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
