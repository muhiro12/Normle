//
//  MaskingSimilarity.swift
//
//
//  Created by Hiromu Nakano on 2025/11/23.
//

import Foundation

/// Calculates similarity between two masked texts to avoid redundant saves.
public enum MaskingSimilarity {
    /// Returns a normalized similarity score between 0.0 and 1.0 using Levenshtein distance.
    public static func similarityScore(
        between first: String,
        and second: String
    ) -> Double {
        let normalizedFirst = first.lowercased()
        let normalizedSecond = second.lowercased()

        guard normalizedFirst.isEmpty == false, normalizedSecond.isEmpty == false else {
            return normalizedFirst == normalizedSecond ? 1.0 : 0.0
        }

        let distance = Double(levenshteinDistance(normalizedFirst, normalizedSecond))
        let longestLength = Double(max(normalizedFirst.count, normalizedSecond.count))

        return max(0, 1.0 - distance / longestLength)
    }
}

private extension MaskingSimilarity {
    static func levenshteinDistance(
        _ first: String,
        _ second: String
    ) -> Int {
        let firstArray = Array(first)
        let secondArray = Array(second)

        let firstCount = firstArray.count
        let secondCount = secondArray.count

        var distances = Array(repeating: Array(repeating: 0, count: secondCount + 1), count: firstCount + 1)

        for index in 0...firstCount {
            distances[index][0] = index
        }

        for index in 0...secondCount {
            distances[0][index] = index
        }

        for firstIndex in 1...firstCount {
            for secondIndex in 1...secondCount {
                let cost = firstArray[firstIndex - 1] == secondArray[secondIndex - 1] ? 0 : 1
                distances[firstIndex][secondIndex] = min(
                    distances[firstIndex - 1][secondIndex] + 1,
                    distances[firstIndex][secondIndex - 1] + 1,
                    distances[firstIndex - 1][secondIndex - 1] + cost
                )
            }
        }

        return distances[firstCount][secondCount]
    }
}
