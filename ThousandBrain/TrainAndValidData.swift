import Foundation


//MARK: - Train Data
class TrainData {
    var DataID: UUID
    var TrainDataSets: [[NeuronType: Float32]]
    
    init() {
        self.DataID = UUID()
        self.TrainDataSets = [
            [.Input1: 0.5, .Input2: 0.5, .Output1: 0.5],
            [.Input1: 0.5, .Input2: 1.0, .Output1: 1.0],
            [.Input1: 1.0, .Input2: 0.5, .Output1: 1.0],
            [.Input1: 1.0, .Input2: 1.0, .Output1: 0.5],
            [.Input1: 0.5, .Input2: 0.5, .Output1: 0.5],
            [.Input1: 0.5, .Input2: 1.0, .Output1: 1.0],
            [.Input1: 1.0, .Input2: 0.5, .Output1: 1.0],
            [.Input1: 1.0, .Input2: 1.0, .Output1: 0.5],
            [.Input1: 0.5, .Input2: 0.5, .Output1: 0.5],
            [.Input1: 0.5, .Input2: 1.0, .Output1: 1.0],
            [.Input1: 1.0, .Input2: 0.5, .Output1: 1.0],
            [.Input1: 1.0, .Input2: 1.0, .Output1: 0.5],
        ]
    }
}


//MARK: - Validify data
class ValidationData {
    var DataID: UUID
    var TrainDataSets: [[NeuronType: Float32]]
    
    init() {
        self.DataID = UUID()
        self.TrainDataSets = [
            [.Input1: 0.5, .Input2: 0.5, .Output1: 0.5],
            [.Input1: 0.5, .Input2: 1.0, .Output1: 1.0],
            [.Input1: 1.0, .Input2: 0.5, .Output1: 1.0],
            [.Input1: 1.0, .Input2: 1.0, .Output1: 0.5],
            [.Input1: 0.45, .Input2: 0.56, .Output1: 0.5],
            [.Input1: 0.49, .Input2: 0.92, .Output1: 1.0],
            [.Input1: 1.0, .Input2: 0.56, .Output1: 1.0],
            [.Input1: 0.99, .Input2: 0.89, .Output1: 0.5],
            [.Input1: 0.60, .Input2: 0.65, .Output1: 0.5], // false XOR false
            [.Input1: 0.70, .Input2: 0.80, .Output1: 1.0], // false XOR true
            [.Input1: 0.40, .Input2: 0.75, .Output1: 0.5], // false XOR false, because 0.75 is not > 0.75
            [.Input1: 0.75, .Input2: 0.40, .Output1: 0.5]  // false XOR false
        ]
    }
}
