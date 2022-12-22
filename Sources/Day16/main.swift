import Algorithms
import Collections
import Helpers
import Foundation
import Numerics
import SwiftGraph

let fileContents = try! String(contentsOf: URL(filePath: "Sources/Day16/Resources/day16.txt"), encoding: .utf8)


struct Valve: Equatable, Hashable, Codable {
    let name: String
    let flowRate: Int
}


let lines = fileContents.split(separator: "\n")

let regex = /Valve ([A-Z]+) has flow rate=([0-9]+); tunnels? leads? to valves? ([A-Z]+(?:, [A-Z]+)*)/

let valves = lines.map { line in
    let match = line.firstMatch(of: regex)!
    let name = String(match.1)
    let flowRate = Int(match.2)!
    let tunnels = match.3.split(separator: ", ").map(String.init)
    return (Valve(name: name, flowRate: flowRate), tunnels)
}

let startIndex = valves.firstIndex { $0.0.name == "AA" }!

let adjacencyList = valves.map { _, tunnels in
    tunnels.compactMap { tunnel in valves.firstIndex { $0.0.name == tunnel } }
}

struct RecursionState: Hashable {
    let currentValve: Int
    let openedValves: Set<Int>
    let minutesLeft: Int
    let totalMinutes: Int
    let numberOfOthers: Int
}


func recursion(state: RecursionState, cache: inout [RecursionState: Int]) -> Int {
    if let cached = cache[state] {
        return cached
    }

    let result: Int
    if state.minutesLeft == 0 {
        result = state.numberOfOthers > 0 ? recursion(state: .init(currentValve: startIndex, openedValves: state.openedValves, minutesLeft: state.totalMinutes, totalMinutes: state.totalMinutes, numberOfOthers: state.numberOfOthers - 1), cache: &cache) : 0
    } else {
        var maxFlowRate = 0
        if !state.openedValves.contains(state.currentValve) {
            maxFlowRate = (state.minutesLeft - 1) * valves[state.currentValve].0.flowRate + recursion(state: .init(currentValve: state.currentValve, openedValves: state.openedValves.union([state.currentValve]), minutesLeft: state.minutesLeft - 1, totalMinutes: state.totalMinutes, numberOfOthers: state.numberOfOthers), cache: &cache)
        }

        for nextValve in adjacencyList[state.currentValve] {
            maxFlowRate = max(maxFlowRate, recursion(state: .init(currentValve: nextValve, openedValves: state.openedValves, minutesLeft: state.minutesLeft - 1, totalMinutes: state.totalMinutes, numberOfOthers: state.numberOfOthers), cache: &cache))
        }

        result = maxFlowRate
    }

    cache[state] = result
    return result
}

var cache: [RecursionState: Int] = [:]
print(recursion(state: .init(currentValve: startIndex, openedValves: Set(valves.enumerated().filter { $0.1.0.flowRate == 0 }.map(\.offset)), minutesLeft: 30, totalMinutes: 30, numberOfOthers: 0), cache: &cache))
print(recursion(state: .init(currentValve: startIndex, openedValves: Set(valves.enumerated().filter { $0.1.0.flowRate == 0 }.map(\.offset)), minutesLeft: 26, totalMinutes: 26, numberOfOthers: 1), cache: &cache))
