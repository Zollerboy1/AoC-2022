extension Sequence {
    public func cut(where predicate: (Element) -> Bool) -> ([Element], some Sequence<Element>) {
        var array = [Element]()
        var iterator = self.makeIterator()

        while let next = iterator.next(), !predicate(next) {
            array.append(next)
        }

        return (array, IteratorSequence(iterator))
    }
}

extension Sequence where Element: Equatable {
    public func cut(separator: Element) -> ([Element], some Sequence<Element>) {
        self.cut { $0 == separator }
    }
}

extension Collection {
    public func cut(where predicate: (Element) -> Bool) -> (SubSequence, SubSequence) {
        if let index = self.firstIndex(where: predicate) {
            return (self[self.startIndex..<index], self[self.index(after: index)...])
        } else {
            return (self[...], self[self.endIndex..<self.endIndex])
        }
    }
}

extension Collection where Element: Equatable {
    public func cut(separator: Element) -> (SubSequence, SubSequence) {
        self.cut { $0 == separator }
    }
}
