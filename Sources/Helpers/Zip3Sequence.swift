@inlinable
public func zip<Sequence1: Sequence, Sequence2: Sequence, Sequence3: Sequence>(
    _ sequence1: Sequence1, _ sequence2: Sequence2, _ sequence3: Sequence3
) -> some Sequence<(Sequence1.Element, Sequence2.Element, Sequence3.Element)> {
    return Zip3Sequence(sequence1, sequence2, sequence3)
}

public struct Zip3Sequence<Sequence1: Sequence, Sequence2: Sequence, Sequence3: Sequence> {
    @usableFromInline
    internal let _sequence1: Sequence1
    @usableFromInline
    internal let _sequence2: Sequence2
    @usableFromInline
    internal let _sequence3: Sequence3

    @inlinable
    internal init(_ sequence1: Sequence1, _ sequence2: Sequence2, _ sequence3: Sequence3) {
        _sequence1 = sequence1
        _sequence2 = sequence2
        _sequence3 = sequence3
    }
}

public extension Zip3Sequence {
    struct Iterator {
        @usableFromInline
        internal var _baseStream1: Sequence1.Iterator
        @usableFromInline
        internal var _baseStream2: Sequence2.Iterator
        @usableFromInline
        internal var _baseStream3: Sequence3.Iterator
        @usableFromInline
        internal var _reachedEnd: Bool = false

        @inlinable
        internal init(
            _ iterator1: Sequence1.Iterator,
            _ iterator2: Sequence2.Iterator,
            _ iterator3: Sequence3.Iterator
        ) {
            self._baseStream1 = iterator1
            self._baseStream2 = iterator2
            self._baseStream3 = iterator3
        }
    }
}

extension Zip3Sequence.Iterator: IteratorProtocol {
    public typealias Element = (Sequence1.Element, Sequence2.Element, Sequence3.Element)

    @inlinable
    public mutating func next() -> Element? {
        if _reachedEnd {
            return nil
        }

        guard let element1 = _baseStream1.next(),
              let element2 = _baseStream2.next(),
              let element3 = _baseStream3.next()
        else {
            _reachedEnd = true
            return nil
        }

        return (element1, element2, element3)
    }
}

extension Zip3Sequence: Sequence {
    public typealias Element = (Sequence1.Element, Sequence2.Element, Sequence3.Element)

    @inlinable
    public __consuming func makeIterator() -> Iterator {
        return Iterator(
            _sequence1.makeIterator(),
            _sequence2.makeIterator(),
            _sequence3.makeIterator()
        )
    }

    @inlinable
    public var underestimatedCount: Int {
        return Swift.min(
            _sequence1.underestimatedCount,
            _sequence2.underestimatedCount,
            _sequence3.underestimatedCount
        )
    }
}
