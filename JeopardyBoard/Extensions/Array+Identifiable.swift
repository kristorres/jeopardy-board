import Foundation

extension Array where Element: Identifiable {
    
    /// Returns the first index where the specified value appears in this array.
    ///
    /// - Parameter element: An element to search for in the array.
    ///
    /// - Returns: The first index where `element` is found, or `nil` otherwise.
    func firstIndex(matching element: Element) -> Int? {
        for index in 0 ..< self.count {
            if self[index].id == element.id {
                return index
            }
        }
        return nil
    }
}
