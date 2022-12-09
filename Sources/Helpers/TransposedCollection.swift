extension Collection where Element: Collection {
    @inlinable
    public var transposed: TransposedCollection<Self> {
        TransposedCollection(base: self)
    }
}

public struct TransposedCollection<Base: Collection> where Base.Element: Collection {
    @usableFromInline
    internal let baseRows: Base
    @usableFromInline
    internal let baseCols: Base.Element

    @inlinable
    internal init(base: Base) {
        precondition(!base.isEmpty)

        self.baseRows = base
        self.baseCols = base.first!
    }
}

extension TransposedCollection: Collection {
    public struct Index: Comparable {
        @usableFromInline
        internal var baseIndex: Base.Element.Index

        @inlinable
        internal init(baseIndex: Base.Element.Index) {
            self.baseIndex = baseIndex
        }

        @inlinable
        public static func ==(lhs: Index, rhs: Index) -> Bool {
            lhs.baseIndex == rhs.baseIndex
        }

        @inlinable
        public static func <(lhs: Index, rhs: Index) -> Bool {
            lhs.baseIndex < rhs.baseIndex
        }
    }

    @inlinable
    public var startIndex: Index {
        Index(baseIndex: baseCols.startIndex)
    }

    @inlinable
    public var endIndex: Index {
        Index(baseIndex: baseCols.endIndex)
    }

    @inlinable
    public subscript(index: Index) -> LazyMapCollection<Base, Base.Element.Element> {
        return baseRows.lazy.map { $0[index.baseIndex] }
    }

    @inlinable
    public func index(after index: Index) -> Index {
        Index(baseIndex: baseCols.index(after: index.baseIndex))
    }

    @inlinable
    public func index(_ i: Index, offsetBy distance: Int) -> Index {
        Index(baseIndex: baseCols.index(i.baseIndex, offsetBy: distance))
    }

    @inlinable
    public func index(
        _ i: Index,
        offsetBy distance: Int,
        limitedBy limit: Index
    ) -> Index? {
        baseCols.index(i.baseIndex, offsetBy: distance, limitedBy: limit.baseIndex).map(Index.init)
    }

    @inlinable
    public func distance(from start: Index, to end: Index) -> Int {
        baseCols.distance(from: start.baseIndex, to: end.baseIndex)
    }
}

extension TransposedCollection: BidirectionalCollection
    where Base.Element: BidirectionalCollection {
    @inlinable
    public func index(before index: Index) -> Index {
        Index(baseIndex: baseCols.index(before: index.baseIndex))
    }
}

extension TransposedCollection: RandomAccessCollection
    where Base.Element: RandomAccessCollection {}

extension TransposedCollection: LazySequenceProtocol, LazyCollectionProtocol
    where Base: LazySequenceProtocol {}

extension TransposedCollection.Index: Hashable where Base.Element.Index: Hashable {}
