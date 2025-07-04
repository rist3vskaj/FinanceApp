extension String {
    
    func fuzzyMatches(_ pattern: String) -> Bool {
        if pattern.isEmpty { return true }

        var patternIndex = pattern.startIndex
        let lowercasedSelf = self.lowercased()
        let lowercasedPattern = pattern.lowercased()

        for char in lowercasedSelf {
            if char == lowercasedPattern[patternIndex] {
                patternIndex = lowercasedPattern.index(after: patternIndex)
                if patternIndex == lowercasedPattern.endIndex {
                    return true
                }
            }
        }
        return false
    }
}
