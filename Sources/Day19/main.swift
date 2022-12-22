import Algorithms
import Collections
import Helpers
import Foundation
import Numerics
import SwiftGraph

let fileContents = try! String(contentsOf: URL(filePath: "Sources/Day19/Resources/day19.txt"), encoding: .utf8)


struct Blueprint {
    let index: Int
    let oreCost: Int
    let clayCost: Int
    let obsidianCost: (ore: Int, clay: Int)
    let geodeCost: (ore: Int, obsidian: Int)
}

let lines = fileContents.split(separator: "\n")

let blueprints = lines.map { line in
    let match = line.firstMatch(of: #/Blueprint ([0-9]+): Each ore robot costs ([0-9]+) ore. Each clay robot costs ([0-9]+) ore. Each obsidian robot costs ([0-9]+) ore and ([0-9]+) clay. Each geode robot costs ([0-9]+) ore and ([0-9]+) obsidian./#)!
    return Blueprint(index: Int(match.1)!, oreCost: Int(match.2)!, clayCost: Int(match.3)!, obsidianCost: (ore: Int(match.4)!, clay: Int(match.5)!), geodeCost: (ore: Int(match.6)!, obsidian: Int(match.7)!))
}


struct RecursionState: Hashable {
    let ore: Int
    let oreRobots: Int
    let clay: Int
    let clayRobots: Int
    let obsidian: Int
    let obsidianRobots: Int
    let geodes: Int
    let geodeRobots: Int
    let i: Int

    init() {
        self.ore = 0
        self.oreRobots = 1
        self.clay = 0
        self.clayRobots = 0
        self.obsidian = 0
        self.obsidianRobots = 0
        self.geodes = 0
        self.geodeRobots = 0
        self.i = 0
    }

    init(ore: Int, oreRobots: Int, clay: Int, clayRobots: Int, obsidian: Int, obsidianRobots: Int, geodes: Int, geodeRobots: Int, i: Int) {
        self.ore = ore
        self.oreRobots = oreRobots
        self.clay = clay
        self.clayRobots = clayRobots
        self.obsidian = obsidian
        self.obsidianRobots = obsidianRobots
        self.geodes = geodes
        self.geodeRobots = geodeRobots
        self.i = i
    }

    func nextIteration(blueprint: Blueprint, newOreRobots: Int, newClayRobots: Int, newObsidianRobots: Int, newGeodeRobots: Int) -> RecursionState {
        var ore = self.ore + self.oreRobots
        var clay = self.clay + self.clayRobots
        var obsidian = self.obsidian + self.obsidianRobots
        let geodes = self.geodes + self.geodeRobots

        let oreRobots = self.oreRobots + newOreRobots
        ore -= newOreRobots * blueprint.oreCost
        let clayRobots = self.clayRobots + newClayRobots
        ore -= newClayRobots * blueprint.clayCost
        let obsidianRobots = self.obsidianRobots + newObsidianRobots
        ore -= newObsidianRobots * blueprint.obsidianCost.ore
        clay -= newObsidianRobots * blueprint.obsidianCost.clay
        let geodeRobots = self.geodeRobots + newGeodeRobots
        ore -= newGeodeRobots * blueprint.geodeCost.ore
        obsidian -= newGeodeRobots * blueprint.geodeCost.obsidian

        return RecursionState(ore: ore, oreRobots: oreRobots, clay: clay, clayRobots: clayRobots, obsidian: obsidian, obsidianRobots: obsidianRobots, geodes: geodes, geodeRobots: geodeRobots, i: self.i + 1)
    }
}

struct Cache {
    var memo: [RecursionState: Int] = [:]
    var minScore: Int = 0
}

func recursion(_ blueprint: Blueprint, iterations: Int, state: RecursionState, cache: inout Cache) -> Int {
    if let cached = cache.memo[state] {
        return cached
    }

    if cache.memo.count > 50000000 {
        cache.memo.removeAll()
        print("Cache cleared for index \(blueprint.index)")
    }

    if state.i == iterations {
        cache.memo[state] = state.geodes
        return state.geodes
    }

    let iterationsLeft = iterations - state.i
    let score = state.geodes + (state.geodeRobots * iterationsLeft)

    if score + (state.geodeRobots + iterationsLeft / 2) * iterationsLeft < cache.minScore {
        cache.memo[state] = 0
        return 0
    }

    var maxGeodes = 0
    if state.ore >= blueprint.geodeCost.ore && state.obsidian >= blueprint.geodeCost.obsidian {
        let nextState = state.nextIteration(blueprint: blueprint, newOreRobots: 0, newClayRobots: 0, newObsidianRobots: 0, newGeodeRobots: 1)
        let geodes = recursion(blueprint, iterations: iterations, state: nextState, cache: &cache)
        if geodes > maxGeodes {
            maxGeodes = geodes
        }
    }

    if blueprint.geodeCost.obsidian > state.obsidianRobots && state.ore >= blueprint.obsidianCost.ore && state.clay >= blueprint.obsidianCost.clay {
        let nextState = state.nextIteration(blueprint: blueprint, newOreRobots: 0, newClayRobots: 0, newObsidianRobots: 1, newGeodeRobots: 0)
        let geodes = recursion(blueprint, iterations: iterations, state: nextState, cache: &cache)
        if geodes > maxGeodes {
            maxGeodes = geodes
        }
    }

    if blueprint.obsidianCost.clay > state.clayRobots && state.ore >= blueprint.clayCost {
        let nextState = state.nextIteration(blueprint: blueprint, newOreRobots: 0, newClayRobots: 1, newObsidianRobots: 0, newGeodeRobots: 0)
        let geodes = recursion(blueprint, iterations: iterations, state: nextState, cache: &cache)
        if geodes > maxGeodes {
            maxGeodes = geodes
        }
    }

    if max(blueprint.oreCost, blueprint.clayCost, blueprint.obsidianCost.ore, blueprint.geodeCost.ore) > state.oreRobots && state.ore >= blueprint.oreCost {
        let nextState = state.nextIteration(blueprint: blueprint, newOreRobots: 1, newClayRobots: 0, newObsidianRobots: 0, newGeodeRobots: 0)
        let geodes = recursion(blueprint, iterations: iterations, state: nextState, cache: &cache)
        if geodes > maxGeodes {
            maxGeodes = geodes
        }
    }

    let nextState = state.nextIteration(blueprint: blueprint, newOreRobots: 0, newClayRobots: 0, newObsidianRobots: 0, newGeodeRobots: 0)
    let geodes1 = recursion(blueprint, iterations: iterations, state: nextState, cache: &cache)
    if geodes1 > maxGeodes {
        maxGeodes = geodes1
    }

    cache.memo[state] = maxGeodes
    cache.minScore = max(cache.minScore, maxGeodes)
    return maxGeodes
}


// Part 1
await withTaskGroup(of: (Int, Blueprint).self) { group in
    for blueprint in blueprints {
        group.addTask {
            var cache = Cache()
            let result = recursion(blueprint, iterations: 24, state: .init(), cache: &cache)
            print("Result for index \(blueprint.index): \(result)")
            return (result, blueprint)
        }
    }

    print(await group.collect().reduce(0) { $0 + $1.0 * ($1.1.index) })
}

// Part 2
await withTaskGroup(of: Int.self) { group in
    for blueprint in blueprints.prefix(3) {
        group.addTask {
            var cache = Cache()
            let result = recursion(blueprint, iterations: 32, state: .init(), cache: &cache)
            print("Result for index \(blueprint.index): \(result)")
            return result
        }
    }

    print(await group.collect().reduce(1) { $0 * $1  })
}

