#if canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#endif

public struct FastString {
    @usableFromInline
    internal typealias Data = UnsafePointer<CChar>
    @usableFromInline
    internal typealias MutableData = UnsafeMutablePointer<CChar>

    @usableFromInline
    internal class Deallocator {
        @usableFromInline
        internal let data: Data?

        @inlinable
        internal init(_ data: Data?) {
            self.data = data
        }

        deinit {
            self.data?.deallocate()
        }
    }

    public let count: Int

    @usableFromInline
    internal let data: Data?
    @usableFromInline
    internal let deallocator: Deallocator?

    @inlinable
    public init() {
        self.count = 0
        self.data = nil
        self.deallocator = nil
    }

    @inlinable
    public init(_ string: UnsafePointer<CChar>?) {
        self.count = string.map { Self.stringLength($0) } ?? 0
        self.data = string
        self.deallocator = nil
    }

    @inlinable
    public init(_ string: UnsafePointer<CChar>?, count: Int) {
        precondition(string != nil || count == 0, "Count must be 0 if there is no data!")

        self.count = count
        self.data = string
        self.deallocator = nil
    }

    @inlinable
    public init(repeating character: CChar, count: Int) {
        let data = MutableData.allocate(capacity: count)
        for i in 0..<count {
            data[i] = character
        }

        self.count = count
        self.data = .init(data)
        self.deallocator = .init(data)
    }

    @inlinable
    public init(copying string: FastString) {
        if let data = string.data {
            let newData = MutableData.allocate(capacity: string.count)
            newData.assign(from: data, count: string.count)

            self.count = string.count
            self.data = .init(newData)
            self.deallocator = .init(newData)
        } else {
            self = .init()
        }
    }

    @inlinable
    public init(copying string: String) {
        let count = string.utf8.count
        let data = string.withCString {
            let data = MutableData.allocate(capacity: count)
            data.assign(from: $0, count: count)
            return data
        }

        self.count = count
        self.data = .init(data)
        self.deallocator = .init(data)
    }

    @inlinable
    public init?(contentsOfFile file: FastString) {
        guard let file = fopen(file.data, "rb") else { return nil }

        fseek(file, 0, SEEK_END)
        let count = ftell(file)
        fseek(file, 0, SEEK_SET)

        let data = MutableData.allocate(capacity: count)
        fread(data, 1, count, file)
        fclose(file)

        self.count = count
        self.data = .init(data)
        self.deallocator = .init(data)
    }

    @inlinable
    public init?(contentsOfFile file: UnsafePointer<CChar>) {
        guard let file = fopen(file, "rb") else { return nil }

        fseek(file, 0, SEEK_END)
        let count = ftell(file)
        fseek(file, 0, SEEK_SET)

        let data = MutableData.allocate(capacity: count)
        fread(data, 1, count, file)
        fclose(file)

        self.count = count
        self.data = .init(data)
        self.deallocator = .init(data)
    }
    
    @inlinable
    public init<T: BinaryInteger>(_ value: T, radix: Int = 10) {
        precondition(radix >= 2 && radix <= 36, "Radix must be between 2 and 36!")
        
        let count = Self.integerLength(value, radix: radix)
        
        let data = MutableData.allocate(capacity: count)
        Self.printInteger(value, radix: radix, length: count, to: data)
        
        self.count = count
        self.data = .init(data)
        self.deallocator = .init(data)
    }

    @usableFromInline
    internal init(_ string: Data?, count: Int, deallocator: Deallocator?) {
        precondition(string != nil || count == 0, "Count must be 0 if there is no data!")

        self.count = count
        self.data = string
        self.deallocator = deallocator
    }

    @inlinable
    public func copy() -> FastString {
        .init(copying: self)
    }

    @inlinable
    public var string: String {
        guard let data = self.data else { return .init() }

        return .init(unsafeUninitializedCapacity: self.count) { buffer in
            buffer.baseAddress!.assign(from: UnsafeRawPointer(data).assumingMemoryBound(to: UInt8.self), count: self.count)
            return self.count
        }
    }

    @usableFromInline
    internal static func compareMemory(_ lhs: Data?, _ rhs: Data?, count: Int) -> Int32 {
        guard count != 0 else { return 0 }

        return memcmp(lhs,rhs,count)
    }

    @usableFromInline
    internal static func stringLength(_ string: Data) -> Int {
        var pointer = string
        while pointer.pointee != 0 {
            pointer += 1
        }
        return pointer - string
    }
    
    @usableFromInline
    internal static func integerLength<T: BinaryInteger>(_ value: T, radix: Int) -> Int {
        guard value != 0 else { return 1 }
        
        var length = value < 0 ? 1 : 0
        var value = value.magnitude
        while value > 0 {
            value /= T.Magnitude(radix)
            length += 1
        }
        
        return length
    }
    
    @usableFromInline
    internal static func printInteger<T: BinaryInteger>(_ value: T, radix: Int, length: Int, to buffer: MutableData) {
        guard value != 0 else {
            buffer[0] = "0"
            return
        }
        
        let radix = T.Magnitude(radix)
        
        if value < 0 {
            buffer[0] = "-"
        }
        
        var value = value.magnitude
        var i = 1
        while value > 0 {
            let digit = CChar(value % radix)
            let digitCharacter = digit < 10 ? digit + "0" : digit - 10 + "A"
            buffer[length - i] = digitCharacter
            value /= radix
            i += 1
        }
    }
}

extension FastString: Comparable {
    @inlinable
    public static func ==(lhs: FastString, rhs: FastString) -> Bool {
        lhs.count == rhs.count && Self.compareMemory(lhs.data, rhs.data, count: rhs.count) == 0
    }

    @inlinable
    public static func <(lhs: FastString, rhs: FastString) -> Bool {
        let comparison = Self.compareMemory(lhs.data, rhs.data, count: Swift.min(lhs.count, rhs.count))
        if comparison != 0 {
            return comparison < 0
        }

        return lhs.count < rhs.count
    }
}

extension FastString: BidirectionalCollection, RandomAccessCollection {
    @inlinable
    public var startIndex: Int { 0 }

    @inlinable
    public var endIndex: Int { self.count }

    @inlinable
    public var isEmpty: Bool { self.count == 0 }

    @inlinable
    public func index(after i: Int) -> Int {
        i + 1
    }

    @inlinable
    public func index(before i: Int) -> Int {
        i - 1
    }

    @inlinable
    public subscript(index: Int) -> CChar {
        precondition(0 <= index && index < self.count, "Index out of bounds!")
        return self.data![index]
    }

    @inlinable
    public subscript(bounds: Range<Int>) -> FastString {
        precondition(0 <= bounds.lowerBound && bounds.upperBound <= self.count, "Range out of bounds!")

        return .init(self.data?.advanced(by: bounds.lowerBound), count: bounds.count, deallocator: self.deallocator)
    }

    @inlinable
    public func starts(with possiblePrefix: FastString) -> Bool {
        self.count >= possiblePrefix.count && Self.compareMemory(self.data, possiblePrefix.data, count: possiblePrefix.count) == 0
    }

    @inlinable
    public func ends(with possibleSuffix: FastString) -> Bool {
        self.count >= possibleSuffix.count && Self.compareMemory(self.data?.advanced(by: self.count - possibleSuffix.count), possibleSuffix.data, count: possibleSuffix.count) == 0
    }

    @inlinable
    public func firstIndex(of element: CChar) -> Int? {
        if !self.isEmpty,
            let pointer = memchr(self.data, Int32(element), self.count) {
            return self.data?.distance(to: pointer.assumingMemoryBound(to: CChar.self))
        }

        return nil
    }

    @inlinable
    public func firstIndex(where predicate: (CChar) throws -> Bool) rethrows -> Int? {
        for i in 0..<self.count {
            if try predicate(self[i]) {
                return i
            }
        }

        return nil
    }

    @inlinable
    public func lastIndex(of element: CChar) -> Int? {
        for i in (0..<self.count).reversed() {
            if self[i] == element {
                return i
            }
        }

        return nil
    }

    @inlinable
    public func lastIndex(where predicate: (CChar) throws -> Bool) rethrows -> Int? {
        for i in (0..<self.count).reversed() {
            if try predicate(self[i]) {
                return i
            }
        }

        return nil
    }

    @inlinable
    public func contains(_ element: CChar) -> Bool {
        self.firstIndex(of: element) != nil
    }

    @inlinable
    public func contains(where predicate: (CChar) throws -> Bool) rethrows -> Bool {
        try self.firstIndex(where: predicate) != nil
    }

    @inlinable
    public func count(of element: CChar) -> Int {
        var count = 0
        for i in 0..<self.count {
            if self[i] == element {
                count += 1
            }
        }

        return count
    }
    
    @inlinable
    public func cut(where predicate: (Element) -> Bool) -> (SubSequence, SubSequence) {
        if let index = self.firstIndex(where: predicate) {
            return (self[self.startIndex..<index], self[self.index(after: index)...])
        } else {
            return (self[...], self[self.endIndex..<self.endIndex])
        }
    }
    
    @inlinable
    public func cut(separator: Element) -> (SubSequence, SubSequence) {
        self.cut { $0 == separator }
    }
}

extension FastString: ExpressibleByStringLiteral {
    @inlinable
    public init(stringLiteral value: StaticString) {
        let count = value.utf8CodeUnitCount
        let data = MutableData.allocate(capacity: count)
        data.assign(from: UnsafeRawPointer(value.utf8Start).assumingMemoryBound(to: CChar.self), count: count)
        
        self.count = count
        self.data = .init(data)
        self.deallocator = .init(data)
    }
}

extension FastString: CustomDebugStringConvertible {
    public var debugDescription: String {
        self.string
    }
}


@inlinable
public func fastPrint(_ string: FastString) {
    fwrite(string.data, 1, string.count, stdout)
}



extension CChar: ExpressibleByUnicodeScalarLiteral {
    @inlinable
    public init(unicodeScalarLiteral value: Unicode.Scalar) {
        self = CChar(value.value)
    }
}


extension Int {
    @inlinable
    public init?(_ string: FastString, radix: Int = 10) {
        let value = strtol(string.data, nil, Int32(radix))

        guard errno != ERANGE else { return nil }

        guard !(value == 0 && string.count(of: "0") == string.count) else { return nil }

        self = value
    }
}
