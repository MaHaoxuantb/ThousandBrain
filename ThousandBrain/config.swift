import Foundation

// CONFIG
class Config {
    let DEBUG: Bool = true
    let RestingPotential: Float32 = -70.0
    let LeakRateMultiplier: Float = 1.0  // This is due to discrete time, we have to have a multiplier to deal with this
    let NumberOfGroupsInABrain: Int = 20
    let NumberOfNeuronsInAGroup: Int = 20
    let StopHeatThreshold: Float32 = -60.0  // The threshold for stopping, for average neuron in a group
    let TotalEnergy: Float32 = 10000.0 // Total mV could be used by the whole brain
}
