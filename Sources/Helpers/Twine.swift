#if canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#endif

public struct Twine {
    @usableFromInline
    internal enum Node {
        case empty
        case string(FastString)
        case character(CChar)
        case integer(Int)
        indirect case twine(Twine)
        
        @usableFromInline
        internal static func twine(lhs: Node, rhs: Node) -> Node {
            .twine(.init(lhs: lhs, rhs: rhs))
        }
        
        @usableFromInline
        internal func print() {
            switch self {
            case .empty:
                break
            case let .string(string):
                fastPrint(string)
            case let .character(character):
                putchar(Int32(character))
            case let .integer(integer):
                fastPrint(FastString(integer))
            case let .twine(twine):
                fastPrint(twine)
            }
        }
    }
    
    @usableFromInline
    internal let lhs, rhs: Node
    
    @inlinable
    public init() {
        self.lhs = .empty
        self.rhs = .empty
    }
    
    @inlinable
    public init(_ string: FastString) {
        self.lhs = .string(string)
        self.rhs = .empty
    }
    
    @inlinable
    public init(_ character: CChar) {
        self.lhs = .character(character)
        self.rhs = .empty
    }
    
    @inlinable
    public init(_ integer: Int) {
        self.lhs = .integer(integer)
        self.rhs = .empty
    }
    
    @inlinable
    public init(_ stringA: FastString, _ stringB: FastString) {
        self.lhs = .string(stringA)
        self.rhs = .string(stringB)
    }
    
    @inlinable
    public init(_ stringA: FastString, _ characterB: CChar) {
        self.lhs = .string(stringA)
        self.rhs = .character(characterB)
    }
    
    @inlinable
    public init(_ stringA: FastString, _ integerB: Int) {
        self.lhs = .string(stringA)
        self.rhs = .integer(integerB)
    }
    
    @inlinable
    public init(_ stringA: FastString, _ twineB: Twine) {
        switch (twineB.lhs, twineB.rhs) {
        case (.empty, _):
            self.init(stringA)
        case let (newRHS, .empty):
            self.init(lhs: .string(stringA), rhs: newRHS)
        case let (lhs, rhs):
            self.init(lhs: .twine(lhs: .string(stringA), rhs: lhs), rhs: rhs)
        }
    }
    
    @inlinable
    public init(_ characterA: CChar, _ stringB: FastString) {
        self.lhs = .character(characterA)
        self.rhs = .string(stringB)
    }
    
    @inlinable
    public init(_ characterA: CChar, _ characterB: CChar) {
        self.lhs = .character(characterA)
        self.rhs = .character(characterB)
    }
    
    @inlinable
    public init(_ characterA: CChar, _ integerB: Int) {
        self.lhs = .character(characterA)
        self.rhs = .integer(integerB)
    }
    
    @inlinable
    public init(_ characterA: CChar, _ twineB: Twine) {
        switch (twineB.lhs, twineB.rhs) {
        case (.empty, _):
            self.init(characterA)
        case let (newRHS, .empty):
            self.init(lhs: .character(characterA), rhs: newRHS)
        case let (lhs, rhs):
            self.init(lhs: .twine(lhs: .character(characterA), rhs: lhs), rhs: rhs)
        }
    }
    
    @inlinable
    public init(_ integerA: Int, _ stringB: FastString) {
        self.lhs = .integer(integerA)
        self.rhs = .string(stringB)
    }
    
    @inlinable
    public init(_ integerA: Int, _ characterB: CChar) {
        self.lhs = .integer(integerA)
        self.rhs = .character(characterB)
    }
    
    @inlinable
    public init(_ integerA: Int, _ integerB: Int) {
        self.lhs = .integer(integerA)
        self.rhs = .integer(integerB)
    }
    
    @inlinable
    public init(_ integerA: Int, _ twineB: Twine) {
        switch (twineB.lhs, twineB.rhs) {
        case (.empty, _):
            self.init(integerA)
        case let (newRHS, .empty):
            self.init(lhs: .integer(integerA), rhs: newRHS)
        case let (lhs, rhs):
            self.init(lhs: .twine(lhs: .integer(integerA), rhs: lhs), rhs: rhs)
        }
    }
    
    @inlinable
    public init(_ twineA: Twine, _ stringB: FastString) {
        switch (twineA.lhs, twineA.rhs) {
        case (.empty, _):
            self.init(stringB)
        case let (newLHS, .empty):
            self.init(lhs: newLHS, rhs: .string(stringB))
        default:
            self.init(lhs: .twine(twineA), rhs: .string(stringB))
        }
    }
    
    @inlinable
    public init(_ twineA: Twine, _ characterB: CChar) {
        switch (twineA.lhs, twineA.rhs) {
        case (.empty, _):
            self.init(characterB)
        case let (newLHS, .empty):
            self.init(lhs: newLHS, rhs: .character(characterB))
        default:
            self.init(lhs: .twine(twineA), rhs: .character(characterB))
        }
    }
    
    @inlinable
    public init(_ twineA: Twine, _ integerB: Int) {
        switch (twineA.lhs, twineA.rhs) {
        case (.empty, _):
            self.init(integerB)
        case let (newLHS, .empty):
            self.init(lhs: newLHS, rhs: .integer(integerB))
        default:
            self.init(lhs: .twine(twineA), rhs: .integer(integerB))
        }
    }
    
    @inlinable
    public init(_ twineA: Twine, _ twineB: Twine) {
        switch (twineA.lhs, twineA.rhs, twineB.lhs, twineB.rhs) {
        case (.empty, _, .empty, _):
            self.init()
        case let (newLHS, .empty, .empty, _):
            self.init(lhs: newLHS, rhs: .empty)
        case let (newLHS, newRHS, .empty, _):
            self.init(lhs: newLHS, rhs: newRHS)
        case let (.empty, _, newLHS, .empty):
            self.init(lhs: newLHS, rhs: .empty)
        case let (.empty, _, newLHS, newRHS):
            self.init(lhs: newLHS, rhs: newRHS)
        case let (newLHS, .empty, newRHS, .empty):
            self.init(lhs: newLHS, rhs: newRHS)
        case let (newLHS1, newLHS2, newRHS, .empty):
            self.init(lhs: .twine(lhs: newLHS1, rhs: newLHS2), rhs: newRHS)
        case let (newLHS1, .empty, newLHS2, newRHS):
            self.init(lhs: .twine(lhs: newLHS1, rhs: newLHS2), rhs: newRHS)
        default:
            self.init(lhs: .twine(twineA), rhs: .twine(twineB))
        }
    }
    
    @usableFromInline
    internal init(lhs: Node, rhs: Node) {
        self.lhs = lhs
        self.rhs = rhs
    }
}


@inlinable
public func fastPrint(_ twine: Twine) {
    twine.lhs.print()
    twine.rhs.print()
}


public func +(lhs: FastString, rhs: FastString) -> Twine {
    .init(lhs, rhs)
}

public func +(lhs: FastString, rhs: Twine) -> Twine {
    .init(lhs, rhs)
}

public func +(lhs: Twine, rhs: FastString) -> Twine {
    .init(lhs, rhs)
}

public func +(lhs: Twine, rhs: Twine) -> Twine {
    .init(lhs, rhs)
}

public func +=(lhs: inout Twine, rhs: FastString) {
    lhs = .init(lhs, rhs)
}

public func +=(lhs: inout Twine, rhs: Twine) {
    lhs = .init(lhs, rhs)
}
