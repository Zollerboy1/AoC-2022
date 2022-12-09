extension BidirectionalCollection {
    @inlinable
    public var prefixes: some Collection<SubSequence> {
        PrefixesCollection(base: self)
    }
}

public struct PrefixesCollection<Base: Collection> {
    @usableFromInline
    internal let base: Base

    @inlinable
    internal init(base: Base) {
        self.base = base
    }
}

extension PrefixesCollection: Collection {
    public struct Index: Comparable {
        @usableFromInline
        internal var upperBound: Base.Index?

        @inlinable
        internal init(upperBound: Base.Index?) {
            self.upperBound = upperBound
        }

        @inlinable
        public static func ==(lhs: Index, rhs: Index) -> Bool {
            lhs.upperBound == rhs.upperBound
        }

        @inlinable
        public static func <(lhs: Index, rhs: Index) -> Bool {
            guard let lhsUpperBound = lhs.upperBound else { return false }
            guard let rhsUpperBound = rhs.upperBound else { return true }
            
            return lhsUpperBound < rhsUpperBound
        }
    }

    @inlinable
    public var startIndex: Index {
        Index(upperBound: base.startIndex)
    }

    @inlinable
    public var endIndex: Index {
        Index(upperBound: nil)
    }

    @inlinable
    public subscript(index: Index) -> Base.SubSequence {
        guard let upperBound = index.upperBound else {
            preconditionFailure("Index out of bounds.")
        }
        
        return base[base.startIndex..<upperBound]
    }

    @inlinable
    public func index(after index: Index) -> Index {
        guard let upperBound = index.upperBound else {
            preconditionFailure("Advancing past the end index.")
        }
        
        if upperBound == base.endIndex {
            return Index(upperBound: nil)
        } else {
            return Index(upperBound: base.index(after: upperBound))
        }
    }

    @inlinable
    public func index(_ i: Index, offsetBy distance: Int) -> Index {
        guard distance != 0 else { return i }
        
        guard let upperBound = i.upperBound else {
            if distance < 0 {
                return Index(upperBound: base.index(base.endIndex, offsetBy: distance + 1))
            } else {
                preconditionFailure("Advancing past the end index.")
            }
        }
        
        if distance > 0 {
            if let newUpperBound = base.index(upperBound, offsetBy: distance, limitedBy: base.endIndex) {
                return Index(upperBound: newUpperBound)
            } else if base.index(upperBound, offsetBy: distance - 1, limitedBy: base.endIndex) != nil {
                return Index(upperBound: nil)
            } else {
                preconditionFailure("Advancing past the end index.")
            }
        } else {
            return Index(upperBound: base.index(upperBound, offsetBy: distance))
        }
    }

    @inlinable
    public func index(
        _ i: Index,
        offsetBy distance: Int,
        limitedBy limit: Index
    ) -> Index? {
        guard distance != 0 else { return i }
        
        switch (i.upperBound, limit.upperBound) {
        case let (upperBound?, limitUpperBound?):
            if distance > 0 {
                if limitUpperBound > upperBound {
                    return Index(upperBound: base.index(upperBound, offsetBy: distance, limitedBy: limitUpperBound))
                } else {
                    if let newUpperBound = base.index(upperBound, offsetBy: distance, limitedBy: base.endIndex) {
                        return Index(upperBound: newUpperBound)
                    } else if base.index(upperBound, offsetBy: distance - 1, limitedBy: base.endIndex) != nil {
                        return Index(upperBound: nil)
                    } else {
                        preconditionFailure("Advancing past the end index.")
                    }
                }
            } else {
                return Index(upperBound: base.index(upperBound, offsetBy: distance, limitedBy: limitUpperBound))
            }
        case let (upperBound?, nil):
            if distance > 0 {
                if let newUpperBound = base.index(upperBound, offsetBy: distance, limitedBy: base.endIndex) {
                    return Index(upperBound: newUpperBound)
                } else if base.index(upperBound, offsetBy: distance - 1, limitedBy: base.endIndex) != nil {
                    return Index(upperBound: nil)
                } else {
                    return nil
                }
            } else {
                return Index(upperBound: base.index(upperBound, offsetBy: distance))
            }
        case let (nil, limitUpperBound?):
            if distance < 0 {
                return Index(upperBound: base.index(base.endIndex, offsetBy: distance + 1, limitedBy: limitUpperBound))
            } else {
                preconditionFailure("Advancing past the end index.")
            }
        case (nil, nil):
            return nil
        }
    }

    @inlinable
    public func distance(from start: Index, to end: Index) -> Int {
        switch (start.upperBound, end.upperBound) {
        case let (start?, end?):
            return base.distance(from: start, to: end)
        case let (start?, nil):
            return base.distance(from: start, to: base.endIndex) + 1
        case let (nil, end?):
            if base is any BidirectionalCollection {
                return base.distance(from: base.endIndex, to: end) + 1
            } else {
                preconditionFailure("Start must be less than or equal to end.")
            }
        case (nil, nil):
            return 0
        }
    }
}

extension PrefixesCollection: BidirectionalCollection where Base: BidirectionalCollection {
    @inlinable
    public func index(before index: Index) -> Index {
        if let upperBound = index.upperBound {
            return Index(upperBound: base.index(before: upperBound))
        } else {
            return Index(upperBound: base.endIndex)
        }
    }
    
    @inlinable
    public func distance(from start: Index, to end: Index) -> Int {
        switch (start.upperBound, end.upperBound) {
        case let (start?, end?):
            return base.distance(from: start, to: end)
        case let (start?, nil):
            return base.distance(from: start, to: base.endIndex) + 1
        case let (nil, end?):
            return base.distance(from: base.endIndex, to: end) + 1
        case (nil, nil):
            return 0
        }
    }
}

extension PrefixesCollection: CustomStringConvertible {
    public var description: String {
        "\(type(of: self))[" + self.map(String.init(describing:)).joined(separator: ", ") + "]"
    }
}

extension PrefixesCollection: RandomAccessCollection
    where Base: RandomAccessCollection {}

extension PrefixesCollection: LazySequenceProtocol, LazyCollectionProtocol
    where Base: LazySequenceProtocol {}

extension PrefixesCollection.Index: Hashable where Base.Index: Hashable {}
