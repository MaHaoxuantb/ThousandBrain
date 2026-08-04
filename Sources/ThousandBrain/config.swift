import Foundation

// CONFIG
class Config {
    // RUN
    let DEBUG: Bool = true
    let StatisticalCalibration: Bool = false
    /// RunTime
    let UseCores: Int = 10
    /// Brain
    let NumberOfGroupsInABrain: Int = 50
    let NumberOfNeuronsInAGroup: Int = 20
    
    // Bio
    /// Cell
    let RestingPotential: Float32 = -70.0
    let ActivatedOnPotential: Float32 = 20.0  // The maximium potential used in the lost fuction
    /// Manual
    let LeakRateMultiplier: Float = 1.0  // This is due to discrete time, we have to have a multiplier to deal with this
    let TotalBrainEnergy: Float32 = 1000000.0 // Total mV could be used by the whole brain
    
    // Durations
    let WorkPhaseDuration: Int = 40
    let OvservationPhaseDuration: Int = 100
    
    // Learn
    let RandomLearningValidRange = 0.25
    
    // RETIRED
//    let MaxInnerIterations = 1000
//    let StopHeatThreshold: Float32 = -50.0  // The threshold for stopping, for average neuron in a group
}
