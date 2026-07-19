import Foundation


//MARK: - Train Data
class TrainData {
    var DataID: UUID
    var TrainDataSets: [[NeuronType: Float32]]
    
    init() {
        self.DataID = UUID()
        self.TrainDataSets = [
            [.Input1: 0.5, .Input2: 0.5, .Input3: 0.5, .Output1: 0.5],
            [.Input1: 0.5, .Input2: 0.5, .Input3: 0.5, .Output1: 0.5],
            [.Input1: 0.5, .Input2: 0.5, .Input3: 0.5, .Output1: 0.5],
            [.Input1: 0.5, .Input2: 0.5, .Input3: 0.5, .Output1: 0.5],
            [.Input1: 0.5, .Input2: 0.5, .Input3: 0.5, .Output1: 0.5],
            [.Input1: 0.5, .Input2: 0.5, .Input3: 0.5, .Output1: 0.5],
            [.Input1: 0.5, .Input2: 0.5, .Input3: 0.5, .Output1: 0.5],
            [.Input1: 0.5, .Input2: 0.5, .Input3: 0.5, .Output1: 0.5],
//
            [.Input1: 1.0, .Input2: 0.5, .Input3: 0.5, .Output1: 1.0],
            [.Input1: 0.5, .Input2: 1.0, .Input3: 0.5, .Output1: 1.0],
            [.Input1: 0.5, .Input2: 0.5, .Input3: 1.0, .Output1: 1.0],
            [.Input1: 1.0, .Input2: 1.0, .Input3: 0.5, .Output1: 0.5],
            [.Input1: 1.0, .Input2: 0.5, .Input3: 1.0, .Output1: 0.5],
            [.Input1: 0.5, .Input2: 1.0, .Input3: 1.0, .Output1: 0.5],
            [.Input1: 1.0, .Input2: 1.0, .Input3: 1.0, .Output1: 1.0],
//
            [.Input1: 1.0, .Input2: 0.5, .Input3: 0.5, .Output1: 1.0],
            [.Input1: 0.5, .Input2: 1.0, .Input3: 0.5, .Output1: 1.0],
            [.Input1: 0.5, .Input2: 0.5, .Input3: 1.0, .Output1: 1.0],
            [.Input1: 1.0, .Input2: 1.0, .Input3: 0.5, .Output1: 0.5],
            [.Input1: 1.0, .Input2: 0.5, .Input3: 1.0, .Output1: 0.5],
            [.Input1: 0.5, .Input2: 1.0, .Input3: 1.0, .Output1: 0.5],
            [.Input1: 1.0, .Input2: 1.0, .Input3: 1.0, .Output1: 1.0],
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
            [.Input1: 0.47, .Input2: 0.25, .Input3: 0.22, .Output1: 0.5],
            [.Input1: 0.91, .Input2: 0.48, .Input3: 0.57, .Output1: 1.0],
            [.Input1: 0.53, .Input2: 0.88, .Input3: 0.49, .Output1: 1.0],
            [.Input1: 0.58, .Input2: 0.51, .Input3: 0.93, .Output1: 1.0],

            [.Input1: 0.94, .Input2: 0.87, .Input3: 0.55, .Output1: 0.5],
            [.Input1: 0.96, .Input2: 0.50, .Input3: 0.89, .Output1: 0.5],
            [.Input1: 0.49, .Input2: 0.91, .Input3: 0.92, .Output1: 0.5],
            [.Input1: 0.86, .Input2: 0.84, .Input3: 0.88, .Output1: 1.0],

            [.Input1: 0.60, .Input2: 0.66, .Input3: 0.70, .Output1: 0.5],
            [.Input1: 0.78, .Input2: 0.69, .Input3: 0.64, .Output1: 1.0],
            [.Input1: 0.79, .Input2: 0.81, .Input3: 0.62, .Output1: 0.5],
            [.Input1: 0.80, .Input2: 0.82, .Input3: 0.83, .Output1: 1.0],
        ]
    }
}
