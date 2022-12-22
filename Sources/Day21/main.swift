import Foundation

enum Operation: Substring {
    case addition = "+"
    case subtraction = "-"
    case multiplication = "*"
    case division = "/"

    func callAsFunction(_ lhs: Int, _ rhs: Int) -> Int {
        switch self {
        case .addition: return lhs + rhs
        case .subtraction: return lhs - rhs
        case .multiplication: return lhs * rhs
        case .division: return lhs / rhs
        }
    }
}

enum MonkeyJob {
    case singleNumber(Int)
    case operation(Substring, Substring, Operation)
}

enum Part2Result {
    case normal(Int)
    case humn((Int) -> Int)
}

let fileContents = try! String(contentsOf: URL(filePath: "Sources/Day21/Resources/day21.txt"), encoding: .utf8)

let lines = fileContents.split(separator: "\n")

let monkeys: [Substring: MonkeyJob] = .init(uniqueKeysWithValues: lines.map { $0.split(separator: " ") }.map { parts in
    (parts[0].dropLast(), parts.count == 4 ? .operation(parts[1], parts[3], .init(rawValue: parts[2])!) : .singleNumber(Int(parts[1])!))
})

// Part 1
func part1(_ name: Substring) -> Int {
    switch monkeys[name]! {
    case let .singleNumber(number):
        return number
    case let .operation(leftName, rightName, operation):
        return operation(part1(leftName), part1(rightName))
    }
}

print(part1("root"))

//Part 2
func part2(_ name: Substring) -> Part2Result {
    if name == "humn" {
        return .humn({ $0 })
    }

    switch monkeys[name]! {
    case let .singleNumber(number):
        return .normal(number)
    case let .operation(leftName, rightName, operation):
        let leftResult = part2(leftName)
        let rightResult = part2(rightName)

        let newFunction: (Int) -> Int
        switch (leftResult, rightResult) {
        case let (.normal(leftNumber), .normal(rightNumber)):
            return .normal(operation(leftNumber, rightNumber))
        case let (.normal(number), .humn(function)):
            switch operation {
            case .addition: newFunction = { function($0 - number) }
            case .subtraction: newFunction = { function(number - $0) }
            case .multiplication: newFunction = { function($0 / number) }
            case .division: newFunction = { function(number / $0) }
            }
        case let (.humn(function), .normal(number)):
            switch operation {
            case .addition: newFunction = { function($0 - number) }
            case .subtraction: newFunction = { function($0 + number) }
            case .multiplication: newFunction = { function($0 / number) }
            case .division: newFunction = { function($0 * number) }
            }
        default:
            fatalError()
        }
        return .humn(newFunction)
    }
}

guard case let .operation(leftName, rightName, _) = monkeys["root"] else { fatalError() }

let result: Int
switch (part2(leftName), part2(rightName)) {
case let (.normal(number), .humn(function)):
    result = function(number)
case let (.humn(function), .normal(number)):
    result = function(number)
default:
    fatalError()
}

print(result)
