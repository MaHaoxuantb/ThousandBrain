import Foundation


//MARK: - Train Data
class TrainData {
    var DataID: UUID
    var TrainDataSets: [[NeuronType: Float32]]
    
    init() {
        self.DataID = UUID()
        self.TrainDataSets = [
            [.Input1: 0.0, .Input2: 0.5, .Output1: 0.5],
            [.Input1: 0.0, .Input2: 1.0, .Output1: 1.0],
            [.Input1: 1.0, .Input2: 0.5, .Output1: 1.0],
            [.Input1: 1.0, .Input2: 1.0, .Output1: 0.5],
        ]
    }
}


//MARK: - Validify data
class ValidifyData {
    var DataID: UUID
    var TrainDataSets: [[NeuronType: Float32]]
    
    init() {
        self.DataID = UUID()
        self.TrainDataSets = [
            [.Input1: 0.0, .Input2: 0.5, .Output1: 0.5],
            [.Input1: 0.0, .Input2: 1.0, .Output1: 1.0],
            [.Input1: 1.0, .Input2: 0.5, .Output1: 1.0],
            [.Input1: 1.0, .Input2: 1.0, .Output1: 0.5],
        ]
    }
}
