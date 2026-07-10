import Foundation

//MARK: -Object Structures
class Axon {
    var id: UUID
    var ConnectionStrength: Float32
    var ConnectedNeuronID: UUID
    var TotalVoltagePassed: Float32

    init(ConnectedNeuronID: UUID) {
        self.id = UUID()
        self.ConnectionStrength = Float32.random(in: 0.0...1.0)
        self.ConnectedNeuronID = ConnectedNeuronID
        self.TotalVoltagePassed = 0.0
    }
}

class Neuron {
    var id: UUID
    var NeuronType: NeuronType
    var LowerAxons: [Axon]
    var IncomingPotential: Float32
    var BodyVoltage: Float32
    var MembraneTimeConstant: Float32
    var APThreshold: Float32  // Action potential threshold
    var NeuronState: NeuronState
    var ActiveDischargeTimePoint: Int8
    var ActiveDischargeInputSimulateCurve: [Float32]  // Use extra input to simulate the active discharge (AP)
    var LastAPTime: Int64

    init() {
        self.id = UUID()
        self.NeuronType = .Normal
        self.LowerAxons = []
        self.IncomingPotential = 0.0
        self.BodyVoltage = TestConfig.RestingPotential  // mV, starting at resting potential
        self.MembraneTimeConstant = Float32.random(in: 10.0...50.0)  // ms
        self.APThreshold = Float32.random(in: 10.0...20.0)
        self.NeuronState = .Normal
        self.ActiveDischargeTimePoint = 0
        self.ActiveDischargeInputSimulateCurve = [30, 20, 5, 0, 0, 0, 0]
        self.LastAPTime = 0
    }

    enum NeuronState: Hashable {
        case Normal
        case Cumulating
    }
}

enum NeuronType: Hashable, CaseIterable {
    case Normal
    case Input1
    case Input2
    case Input3
    case Output1
}

class Group {
    var id: UUID
    var Neurons: [Neuron]
    var Finished: Bool
    var Heat: Float32

    init() {
        self.id = UUID()
        self.Neurons = []
        self.Finished = false
        self.Heat = 0.0
    }
}

// class Section {
//     id: UUID = UUID()
//     Groups: [Group]
// }

class BRAIN {
    var id: UUID = UUID()
    var Groups: [Group] = []
    var TotalHeat: Float64

    init() {
        self.id = UUID()
        self.Groups = []
        self.TotalHeat = 0.0
    }
}
