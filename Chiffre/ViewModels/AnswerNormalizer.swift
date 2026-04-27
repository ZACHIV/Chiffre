import Foundation

protocol AnswerNormalizing {
    func normalize(_ text: String) -> String
    func matches(_ input: String, target: String) -> Bool
}

struct AnswerNormalizer: AnswerNormalizing {
    func matches(_ input: String, target: String) -> Bool {
        let normalizedInput = normalize(input)
        let normalizedTarget = normalize(target)
        if normalizedInput == normalizedTarget {
            return true
        }

        let stripSpaces = { (value: String) in
            value.replacingOccurrences(of: " ", with: "")
        }
        return stripSpaces(normalizedInput) == stripSpaces(normalizedTarget)
    }

    func normalize(_ text: String) -> String {
        var normalized = text.lowercased().trimmingCharacters(in: .whitespaces)

        for prefix in ["le ", "la ", "el "] {
            if normalized.hasPrefix(prefix) {
                normalized = String(normalized.dropFirst(prefix.count))
                break
            }
        }

        normalized = normalized.replacingOccurrences(of: "€", with: "")
        normalized = normalized.replacingOccurrences(of: "$", with: "")
        normalized = normalized.replacingOccurrences(of: ",", with: ".")
        normalized = normalized.replacingOccurrences(
            of: "(\\d)h(\\d)",
            with: "$1:$2",
            options: .regularExpression
        )
        normalized = normalized.replacingOccurrences(of: " de ", with: " ")
        normalized = normalized
            .components(separatedBy: .whitespaces)
            .filter { !$0.isEmpty }
            .joined(separator: " ")

        return normalized
    }
}
