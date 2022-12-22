import Algorithms
import Collections
import Helpers
import Foundation
import Numerics
import SwiftGraph

let fileContents = try! String(contentsOf: URL(filePath: "Sources/Day20/Resources/day20.txt"), encoding: .utf8)


let lines = fileContents.split(separator: "\n")

var numbers = lines.map { Int($0)! }

func solution(numbers: [Int], iterations: Int) -> Int {
    var numbers = Array(numbers.enumerated())
    for _ in 0..<iterations {
        for i in 0..<numbers.count {
            let indexBefore = numbers.firstIndex { $0.offset == i }!
            let indexAfter = (((indexBefore + numbers[indexBefore].element) % (numbers.count - 1)) + (numbers.count - 1)) % (numbers.count - 1)
            numbers.insert(numbers.remove(at: indexBefore), at: indexAfter)
        }
    }

    let zeroIndex = numbers.firstIndex { $0.element == 0 }!

    return numbers[(zeroIndex + 1000) % numbers.count].element + numbers[(zeroIndex + 2000) % numbers.count].element + numbers[(zeroIndex + 3000) % numbers.count].element
}

print(solution(numbers: numbers, iterations: 1))
print(solution(numbers: numbers.map { $0 * 811589153 }, iterations: 10))
