import Foundation

// CONFIG
class Config {
    // RUN
    let DEBUG: Bool = true
    let StatisticalCalibration: Bool = false
    let ShowGraphForCalibration: Bool = true // Useable when (StatisticalCalibration == true)
    /// RunTime
    let UseThreads: Int = 10
    let EnableExtendedUsage: Bool = true /// Allow the use of things like SwiftUI&charts that could not run on a standard linux machine.
    /// Brain
    let NumberOfGroupsInABrain: Int = 25
    let NumberOfNeuronsInAGroup: Int = 25
    
    // Bio
    /// Cell
    let RestingPotential: Float32 = -70.0
    let ActivatedOnPotential: Float32 = 20.0  // The maximium potential used in the lost fuction
    /// Manual
    let LeakRateMultiplier: Float = 1.0  // This is due to discrete time, we have to have a multiplier to deal with this
    let TotalBrainEnergy: Float32 = 100000000.0 // Total mV could be used by the whole brain
    
    // Durations
    let WorkPhaseDuration: Int = 10
    let OvservationPhaseDuration: Int = 200
    
    // Learn
    let RandomLearningValidRange = 0.25
    
    // Cal&Statis
    let MeanFiring: Float32 = 21.1
    let FiringSpan: Float32 = 3
    
    // RETIRED
//    let MaxInnerIterations = 1000
//    let StopHeatThreshold: Float32 = -50.0  // The threshold for stopping, for average neuron in a group
}
