import Algorithms
import Collections
import Helpers
import Foundation
import Numerics
import SwiftGraph

struct Monkey {
    var items: [Int]
    let operation: (Int) -> Int
    let test, ifTrue, ifFalse: Int
    var inspectedCount = 0
}

let fileContents = try! String(contentsOf: URL(filePath: "Sources/Day11/Resources/day11.txt"), encoding: .utf8)

let regex = #/
(?-x:Monkey (\d):)\n
(?-x:  Starting items: (\d+(?:, \d+)*))\n
(?-x:  Operation: new = old (\*|\+) (\d+|old))\n
(?-x:  Test: divisible by (\d+))\n
(?-x:    If true: throw to monkey (\d))\n
(?-x:    If false: throw to monkey (\d))
/#

let monkeyData = try fileContents.matches(of: regex).map { match in
    let itemsString = "[\(match.2)]"
    let items = try JSONDecoder().decode([Int].self, from: itemsString.data(using: .utf8)!)

    let operation: (Int) -> Int
    do {
        let value = Int(match.4)
        switch (match.3, value) {
        case let ("+", value?):
            operation = { $0 + value }
        case let ("*", value?):
            operation = { $0 * value }
        case ("+", _):
            operation = { $0 + $0 }
        case ("*", _):
            operation = { $0 * $0 }
        default:
            fatalError()
        }
    }

    let test = Int(match.5)!
    let ifTrue = Int(match.6)!
    let ifFalse = Int(match.7)!

    return Monkey(items: items, operation: operation, test: test, ifTrue: ifTrue, ifFalse: ifFalse)
}

func monkeyBusiness(afterNumberOfRounds n: Int, shouldDivideByThree: Bool, withMonkeyData monkeyData: [Monkey]) -> Int {
    var monkeyData = monkeyData
    let modulus = monkeyData.map(\.test).reduce(1, *)

    for _ in 0..<n {
        for i in 0..<monkeyData.count {
            let monkey = monkeyData[i]
            let items = monkey.items
            monkeyData[i].items = []

            for item in items {
                let newWorryLevel = (monkey.operation(item) / (shouldDivideByThree ? 3 : 1)) % modulus
                if newWorryLevel % monkey.test == 0 {
                    monkeyData[monkey.ifTrue].items.append(newWorryLevel)
                } else {
                    monkeyData[monkey.ifFalse].items.append(newWorryLevel)
                }

                monkeyData[i].inspectedCount += 1
            }
        }
    }

    return monkeyData.map(\.inspectedCount).max(count: 2).reduce(1, *)
}

print(monkeyBusiness(afterNumberOfRounds: 20, shouldDivideByThree: true, withMonkeyData: monkeyData))
print(monkeyBusiness(afterNumberOfRounds: 10000, shouldDivideByThree: false, withMonkeyData: monkeyData))
