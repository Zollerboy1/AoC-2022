import Algorithms
import Collections
import Foundation
import Numerics
import SwiftGraph

let url = Bundle.module.url(forResource: "day1", withExtension: "txt")!
let fileContents = try! String(contentsOf: url, encoding: .utf8)


let lines = fileContents.split(separator: "\n", omittingEmptySubsequences: false)

let elves = lines.split(separator: "")

var max1 = 0, max2 = 0, max3 = 0
for elf in elves {
    let calories = elf.compactMap { Int($0) }.reduce(0, +)

    if calories > max1 {
        max3 = max2
        max2 = max1
        max1 = calories
    } else if calories > max2 {
        max3 = max2
        max2 = calories
    } else if calories > max3 {
        max3 = calories
    }
}

print(max1 + max2 + max3)
