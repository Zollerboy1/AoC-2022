extension Collection {
    @inlinable
    public var suffixes: some Collection<SubSequence> {
        SuffixesCollection(base: self)
    }
}

public struct SuffixesCollection<Base: Collection> {
    @usableFromInline
    internal let base: Base

    @inlinable
    internal init(base: Base) {
        self.base = base
    }
}

extension SuffixesCollection: Collection {
    public struct Index: Comparable {
        @usableFromInline
        internal var lowerBound: Base.Index?

        @inlinable
        internal init(lowerBound: Base.Index?) {
            self.lowerBound = lowerBound
        }

        @inlinable
        public static func ==(lhs: Index, rhs: Index) -> Bool {
            lhs.lowerBound == rhs.lowerBound
        }

        @inlinable
        public static func <(lhs: Index, rhs: Index) -> Bool {
            guard let lhsLowerBound = lhs.lowerBound else { return false }
            guard let rhsLowerBound = rhs.lowerBound else { return true }
            
            return lhsLowerBound < rhsLowerBound
        }
    }

    @inlinable
    public var startIndex: Index {
        Index(lowerBound: base.startIndex)
    }

    @inlinable
    public var endIndex: Index {
        Index(lowerBound: nil)
    }

    @inlinable
    public subscript(index: Index) -> Base.SubSequence {
        guard let lowerBound = index.lowerBound else {
            preconditionFailure("Index out of bounds.")
        }
        
        return base[lowerBound..<base.endIndex]
    }
    
    @inlinable
    public func index(after index: Index) -> Index {
        guard let lowerBound = index.lowerBound else {
            preconditionFailure("Advancing past the end index.")
        }
        
        if lowerBound == base.endIndex {
            return Index(lowerBound: nil)
        } else {
            return Index(lowerBound: base.index(after: lowerBound))
        }
    }

    @inlinable
    public func index(_ i: Index, offsetBy distance: Int) -> Index {
        guard distance != 0 else { return i }
        
        guard let lowerBound = i.lowerBound else {
            if distance < 0 {
                return Index(lowerBound: base.index(base.endIndex, offsetBy: distance + 1))
            } else {
                preconditionFailure("Advancing past the end index.")
            }
        }
        
        if distance > 0 {
            if let newUpperBound = base.index(lowerBound, offsetBy: distance, limitedBy: base.endIndex) {
                return Index(lowerBound: newUpperBound)
            } else if base.index(lowerBound, offsetBy: distance - 1, limitedBy: base.endIndex) != nil {
                return Index(lowerBound: nil)
            } else {
                preconditionFailure("Advancing past the end index.")
            }
        } else {
            return Index(lowerBound: base.index(lowerBound, offsetBy: distance))
        }
    }

    @inlinable
    public func index(
        _ i: Index,
        offsetBy distance: Int,
        limitedBy limit: Index
    ) -> Index? {
        guard distance != 0 else { return i }
        
        switch (i.lowerBound, limit.lowerBound) {
        case let (lowerBound?, limitLowerBound?):
            if distance > 0 {
                if limitLowerBound > lowerBound {
                    return Index(lowerBound: base.index(lowerBound, offsetBy: distance, limitedBy: limitLowerBound))
                } else {
                    if let newUpperBound = base.index(lowerBound, offsetBy: distance, limitedBy: base.endIndex) {
                        return Index(lowerBound: newUpperBound)
                    } else if base.index(lowerBound, offsetBy: distance - 1, limitedBy: base.endIndex) != nil {
                        return Index(lowerBound: nil)
                    } else {
                        preconditionFailure("Advancing past the end index.")
                    }
                }
            } else {
                return Index(lowerBound: base.index(lowerBound, offsetBy: distance, limitedBy: limitLowerBound))
            }
        case let (lowerBound?, nil):
            if distance > 0 {
                if let newUpperBound = base.index(lowerBound, offsetBy: distance, limitedBy: base.endIndex) {
                    return Index(lowerBound: newUpperBound)
                } else if base.index(lowerBound, offsetBy: distance - 1, limitedBy: base.endIndex) != nil {
                    return Index(lowerBound: nil)
                } else {
                    return nil
                }
            } else {
                return Index(lowerBound: base.index(lowerBound, offsetBy: distance))
            }
        case let (nil, limitLowerBound?):
            if distance < 0 {
                return Index(lowerBound: base.index(base.endIndex, offsetBy: distance + 1, limitedBy: limitLowerBound))
            } else {
                preconditionFailure("Advancing past the end index.")
            }
        case (nil, nil):
            return nil
        }
    }

    @inlinable
    public func distance(from start: Index, to end: Index) -> Int {
        switch (start.lowerBound, end.lowerBound) {
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

extension SuffixesCollection: BidirectionalCollection
    where Base: BidirectionalCollection {
    @inlinable
    public func index(before index: Index) -> Index {
        if let lowerBound = index.lowerBound {
            return Index(lowerBound: base.index(before: lowerBound))
        } else {
            return Index(lowerBound: base.endIndex)
        }
    }
    
    @inlinable
    public func distance(from start: Index, to end: Index) -> Int {
        switch (start.lowerBound, end.lowerBound) {
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

extension SuffixesCollection: CustomStringConvertible {
    public var description: String {
        "\(type(of: self))[" + self.map(String.init(describing:)).joined(separator: ", ") + "]"
    }
}

extension SuffixesCollection: RandomAccessCollection
    where Base: RandomAccessCollection {}

extension SuffixesCollection: LazySequenceProtocol, LazyCollectionProtocol
    where Base: LazySequenceProtocol {}

extension SuffixesCollection.Index: Hashable where Base.Index: Hashable {}
