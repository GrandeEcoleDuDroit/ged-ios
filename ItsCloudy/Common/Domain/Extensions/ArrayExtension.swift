import Foundation

extension Array {
    func toSet() -> Set<Element> where Element: Hashable {
        Set(self)
    }
    
    func replace(where predicate: (Element) -> Bool, with newValue: Element) -> [Element] {
        map { predicate($0) ? newValue : $0 }
    }
    
    mutating func remove(_ element: Element) where Element: Equatable {
        if let index = firstIndex(of: element) {
            remove(at: index)
        }
    }
    
    func take(_ count: Int) -> [Element] {
        guard count >= 0 else {
            return []
        }
        return Array(prefix(count))
    }
}
