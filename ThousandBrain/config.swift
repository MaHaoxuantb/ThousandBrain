import Foundation

// CONFIG
class Config {
    let DEBUG: Bool = true
    let RestingPotential: Float32 = -70.0
    let ActivatedOnPotential: Float32 = 20.0  // The maximium potential used in the lost fuction
    let LeakRateMultiplier: Float = 1.0  // This is due to discrete time, we have to have a multiplier to deal with this
    let NumberOfGroupsInABrain: Int = 40
    let NumberOfNeuronsInAGroup: Int = 20
    let StopHeatThreshold: Float32 = -50.0  // The threshold for stopping, for average neuron in a group
    let TotalEnergyLeft: Float32 = 10000.0 // Total mV could be used by the whole brain
    let MaxInnerIterations = 10000;
}
