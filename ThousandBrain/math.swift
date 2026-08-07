//
//  math.swift
//  ThousandBrain
//
//  Created by Thomas B on 8/7/26.
//
//  Might involve codes written by AI
//

import Foundation

// MARK: - Input Data

/// One observed integer value and the number of times it occurred.
public struct FrequencyObservation: Sendable {
    public let value: Int32
    public let frequency: Int32

    public init(value: Int32, frequency: Int32) {
        self.value = value
        self.frequency = frequency
    }
}

// MARK: - Frequency Density

/// A histogram-style bin derived from frequency observations.
public struct FrequencyDensityBin: Sendable {
    /// Original observed value, treated as the bin center.
    public let value: Float64

    /// Number of observations at this value.
    public let frequency: Float64

    /// Frequency divided by total frequency.
    public let relativeFrequency: Float64

    /// Estimated lower boundary of the bin.
    public let lowerBoundary: Float64

    /// Estimated upper boundary of the bin.
    public let upperBoundary: Float64

    /// upperBoundary - lowerBoundary
    public let binWidth: Float64

    /// frequency / binWidth
    public let frequencyDensity: Float64

    /// relativeFrequency / binWidth
    ///
    /// Unlike raw frequency density, these probability densities
    /// approximately integrate to 1.
    public let probabilityDensity: Float64
}

public enum FrequencyDataError: Error, CustomStringConvertible {
    case emptyData
    case negativeFrequency(value: Int32, frequency: Int32)
    case noPositiveFrequencies
    case invalidBinWidth(value: Float64, width: Float64)
    case insufficientDistinctValues
    case optimizationFailed

    public var description: String {
        switch self {
        case .emptyData:
            return "The frequency dataset is empty."

        case let .negativeFrequency(value, frequency):
            return "Value \(value) has an invalid negative frequency: \(frequency)."

        case .noPositiveFrequencies:
            return "The dataset contains no positive frequencies."

        case let .invalidBinWidth(value, width):
            return "The estimated bin width at value \(value) is invalid: \(width)."

        case .insufficientDistinctValues:
            return "At least two distinct values with positive frequencies are required."

        case .optimizationFailed:
            return "The logistic fitting process produced non-finite parameters."
        }
    }
}

/// Utilities for combining and converting frequency data.
public enum FrequencyDensityConverter {

    /// Combines duplicate values, removes zero-frequency rows, and sorts by value.
    public static func normalize(
        _ data: [(Int32, Int32)]
    ) throws -> [FrequencyObservation] {
        guard !data.isEmpty else {
            throw FrequencyDataError.emptyData
        }

        var combined: [Int32: Int64] = [:]

        for (value, frequency) in data {
            guard frequency >= 0 else {
                throw FrequencyDataError.negativeFrequency(
                    value: value,
                    frequency: frequency
                )
            }

            combined[value, default: 0] += Int64(frequency)
        }

        let normalized = combined
            .filter { $0.value > 0 }
            .sorted { $0.key < $1.key }
            .map { value, frequency in
                FrequencyObservation(
                    value: value,
                    frequency: Int32(
                        min(frequency, Int64(Int32.max))
                    )
                )
            }

        guard !normalized.isEmpty else {
            throw FrequencyDataError.noPositiveFrequencies
        }

        return normalized
    }

    /// Converts frequency observations into frequency-density bins.
    ///
    /// For neighboring centers x[i] and x[i+1], the boundary is placed at:
    ///
    ///     (x[i] + x[i+1]) / 2
    ///
    /// For regularly spaced integer data, this normally produces bin width 1.
    public static func convert(
        _ rawData: [(Int32, Int32)],
        singleValueBinWidth: Float64 = 1.0
    ) throws -> [FrequencyDensityBin] {
        let observations = try normalize(rawData)

        let totalFrequency = observations.reduce(0.0) {
            $0 + Float64($1.frequency)
        }

        guard totalFrequency > 0 else {
            throw FrequencyDataError.noPositiveFrequencies
        }

        if observations.count == 1 {
            let observation = observations[0]

            guard singleValueBinWidth > 0,
                  singleValueBinWidth.isFinite else {
                throw FrequencyDataError.invalidBinWidth(
                    value: Float64(observation.value),
                    width: singleValueBinWidth
                )
            }

            let value = Float64(observation.value)
            let frequency = Float64(observation.frequency)
            let relativeFrequency = frequency / totalFrequency

            return [
                FrequencyDensityBin(
                    value: value,
                    frequency: frequency,
                    relativeFrequency: relativeFrequency,
                    lowerBoundary: value - singleValueBinWidth / 2.0,
                    upperBoundary: value + singleValueBinWidth / 2.0,
                    binWidth: singleValueBinWidth,
                    frequencyDensity: frequency / singleValueBinWidth,
                    probabilityDensity: relativeFrequency / singleValueBinWidth
                )
            ]
        }

        let values = observations.map { Float64($0.value) }

        // Boundaries between adjacent values.
        let middleBoundaries: [Float64] = zip(
            values.dropLast(),
            values.dropFirst()
        ).map { left, right in
            (left + right) / 2.0
        }

        var bins: [FrequencyDensityBin] = []
        bins.reserveCapacity(observations.count)

        for index in observations.indices {
            let value = values[index]
            let frequency = Float64(observations[index].frequency)

            let lowerBoundary: Float64
            let upperBoundary: Float64

            if index == 0 {
                let firstGap = values[1] - values[0]
                lowerBoundary = value - firstGap / 2.0
            } else {
                lowerBoundary = middleBoundaries[index - 1]
            }

            if index == observations.count - 1 {
                let lastGap =
                    values[index] - values[index - 1]

                upperBoundary = value + lastGap / 2.0
            } else {
                upperBoundary = middleBoundaries[index]
            }

            let binWidth = upperBoundary - lowerBoundary

            guard binWidth > 0, binWidth.isFinite else {
                throw FrequencyDataError.invalidBinWidth(
                    value: value,
                    width: binWidth
                )
            }

            let relativeFrequency = frequency / totalFrequency

            bins.append(
                FrequencyDensityBin(
                    value: value,
                    frequency: frequency,
                    relativeFrequency: relativeFrequency,
                    lowerBoundary: lowerBoundary,
                    upperBoundary: upperBoundary,
                    binWidth: binWidth,
                    frequencyDensity: frequency / binWidth,
                    probabilityDensity: relativeFrequency / binWidth
                )
            )
        }

        return bins
    }
}

// MARK: - Logistic Distribution

public struct LogisticDistribution: Sendable {
    /// Location parameter μ.
    public let mean: Float64

    /// Scale parameter s. This must always be positive.
    public let span: Float64

    public init(mean: Float64, span: Float64) {
        precondition(
            span > 0 && span.isFinite,
            "Logistic span must be positive and finite."
        )

        self.mean = mean
        self.span = span
    }

    /// Logistic cumulative distribution function.
    ///
    ///     F(x) = 1 / (1 + exp(-(x - mean) / span))
    public func cdf(at x: Float64) -> Float64 {
        let z = (x - mean) / span

        // Numerically stable sigmoid calculation.
        if z >= 0 {
            return 1.0 / (1.0 + exp(-z))
        } else {
            let exponential = exp(z)
            return exponential / (1.0 + exponential)
        }
    }

    /// Logistic probability density function.
    ///
    ///     f(x) = F(x) * (1 - F(x)) / span
    public func pdf(at x: Float64) -> Float64 {
        let cumulativeProbability = cdf(at: x)

        return cumulativeProbability
            * (1.0 - cumulativeProbability)
            / span
    }
}

// MARK: - Fit Result

public struct LogisticFitResult: Sendable {
    public let distribution: LogisticDistribution

    /// Final weighted average negative log-likelihood.
    public let loss: Float64

    /// Number of optimizer iterations actually performed.
    public let iterations: Int

    /// Whether the optimizer stopped because parameter changes became small.
    public let converged: Bool
}

// MARK: - Logistic Curve Fitter

public enum LogisticCurveFitter {

    /// Fits a logistic probability distribution to grouped frequency data.
    ///
    /// Frequencies are used directly as likelihood weights. The data is not
    /// expanded into repeated samples.
    public static func fit(
        _ rawData: [(Int32, Int32)],
        maximumIterations: Int = 20_000,
        learningRate: Float64 = 0.03,
        tolerance: Float64 = 1e-10
    ) throws -> LogisticFitResult {
        let observations = try FrequencyDensityConverter.normalize(rawData)

        guard observations.count >= 2 else {
            throw FrequencyDataError.insufficientDistinctValues
        }

        let totalWeight = observations.reduce(0.0) {
            $0 + Float64($1.frequency)
        }

        // Weighted sample mean.
        let initialMean = observations.reduce(0.0) {
            $0 + Float64($1.value) * Float64($1.frequency)
        } / totalWeight

        // Weighted population variance.
        let initialVariance = observations.reduce(0.0) {
            let difference = Float64($1.value) - initialMean

            return $0
                + Float64($1.frequency)
                * difference
                * difference
        } / totalWeight

        guard initialVariance > 0,
              initialVariance.isFinite else {
            throw FrequencyDataError.insufficientDistinctValues
        }

        /*
         Logistic distribution variance:

             variance = π²s² / 3

         Therefore:

             s = sqrt(3 * variance) / π
         */
        let initialSpan =
            sqrt(3.0 * initialVariance) / Float64.pi

        var mean = initialMean

        // Optimize log(span) instead of span so span cannot become negative.
        var logSpan = log(max(initialSpan, 1e-12))

        // Adam optimizer state.
        var meanFirstMoment = 0.0
        var meanSecondMoment = 0.0

        var spanFirstMoment = 0.0
        var spanSecondMoment = 0.0

        let beta1 = 0.9
        let beta2 = 0.999
        let epsilon = 1e-8

        var previousMean = mean
        var previousLogSpan = logSpan
        var finalLoss = Float64.infinity
        var converged = false
        var completedIterations = 0

        for iteration in 1...maximumIterations {
            let span = exp(logSpan)

            var meanGradient = 0.0
            var logSpanGradient = 0.0
            var weightedLoss = 0.0

            for observation in observations {
                let x = Float64(observation.value)
                let weight = Float64(observation.frequency)

                let z = (x - mean) / span
                let tanhHalfZ = tanh(z / 2.0)

                /*
                 Negative log PDF:

                     -log(f(x))
                     = log(4s) + 2 log(cosh(z / 2))
                 */
                let pointLoss =
                    logSpan
                    + log(4.0)
                    + 2.0 * stableLogCosh(z / 2.0)

                weightedLoss += weight * pointLoss

                /*
                 Derivative with respect to mean:

                     -tanh(z / 2) / span
                 */
                meanGradient += weight * (-tanhHalfZ / span)

                /*
                 Derivative with respect to log(span):

                     1 - z * tanh(z / 2)
                 */
                logSpanGradient += weight * (
                    1.0 - z * tanhHalfZ
                )
            }

            // Use average loss and gradients, so scale does not depend on
            // the total number of samples.
            finalLoss = weightedLoss / totalWeight
            meanGradient /= totalWeight
            logSpanGradient /= totalWeight

            guard finalLoss.isFinite,
                  meanGradient.isFinite,
                  logSpanGradient.isFinite else {
                throw FrequencyDataError.optimizationFailed
            }

            // Update Adam moments.
            meanFirstMoment =
                beta1 * meanFirstMoment
                + (1.0 - beta1) * meanGradient

            meanSecondMoment =
                beta2 * meanSecondMoment
                + (1.0 - beta2)
                * meanGradient
                * meanGradient

            spanFirstMoment =
                beta1 * spanFirstMoment
                + (1.0 - beta1) * logSpanGradient

            spanSecondMoment =
                beta2 * spanSecondMoment
                + (1.0 - beta2)
                * logSpanGradient
                * logSpanGradient

            // Bias correction.
            let beta1Correction = 1.0 - pow(beta1, Float64(iteration))
            let beta2Correction = 1.0 - pow(beta2, Float64(iteration))

            let correctedMeanFirst =
                meanFirstMoment / beta1Correction

            let correctedMeanSecond =
                meanSecondMoment / beta2Correction

            let correctedSpanFirst =
                spanFirstMoment / beta1Correction

            let correctedSpanSecond =
                spanSecondMoment / beta2Correction

            previousMean = mean
            previousLogSpan = logSpan

            mean -= learningRate
                * correctedMeanFirst
                / (sqrt(correctedMeanSecond) + epsilon)

            logSpan -= learningRate
                * correctedSpanFirst
                / (sqrt(correctedSpanSecond) + epsilon)

            // Prevent numerical overflow or near-zero spans.
            logSpan = min(max(logSpan, -30.0), 30.0)

            completedIterations = iteration

            let meanChange = abs(mean - previousMean)
            let spanChange = abs(logSpan - previousLogSpan)

            if meanChange < tolerance && spanChange < tolerance {
                converged = true
                break
            }
        }

        let finalSpan = exp(logSpan)

        guard mean.isFinite,
              finalSpan.isFinite,
              finalSpan > 0 else {
            throw FrequencyDataError.optimizationFailed
        }

        return LogisticFitResult(
            distribution: LogisticDistribution(
                mean: mean,
                span: finalSpan
            ),
            loss: finalLoss,
            iterations: completedIterations,
            converged: converged
        )
    }

    /// Returns fitted PDF values at each converted bin center.
    public static func fittedCurve(
        from bins: [FrequencyDensityBin],
        using distribution: LogisticDistribution
    ) -> [(x: Float64, observedDensity: Float64, fittedDensity: Float64)] {
        bins.map { bin in
            (
                x: bin.value,
                observedDensity: bin.probabilityDensity,
                fittedDensity: distribution.pdf(at: bin.value)
            )
        }
    }

    private static func stableLogCosh(_ x: Float64) -> Float64 {
        let absoluteX = abs(x)

        return absoluteX
            + log1p(exp(-2.0 * absoluteX))
            - log(2.0)
    }
}
