import Algorithms
import Collections
import Helpers
import Foundation
import Numerics
import SwiftGraph

let url = Bundle.module.url(forResource: "day5", withExtension: "txt")!
let fileContents = try! String(contentsOf: url, encoding: .utf8)


let lines = fileContents.split(separator: "\n")
