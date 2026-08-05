import Foundation


struct TrainValidateDataSet {
    var DataSetID: UUID
    var DataSets: [[NeuronType: [Float32]]]
}

//MARK: - DataSets
protocol DataSetProtocol {
    var ID: UUID { get set }
    var NumberOfInputs: Int { get set }
    var NumberOfOutputs: Int { get set }
    var TrainData: TrainValidateDataSet { get set }
    var ValidationData: TrainValidateDataSet { get set }
}

struct ThreeInputBooleanClassificationDataset: DataSetProtocol {
    var ID: UUID
    var NumberOfInputs: Int
    var NumberOfOutputs: Int
    var TrainData: TrainValidateDataSet
    var ValidationData: TrainValidateDataSet
    
    init() {
        self.ID = UUID()
        self.NumberOfInputs = 3
        self.NumberOfOutputs = 1
        self.TrainData = TrainValidateDataSet(
            DataSetID: UUID(),
            DataSets: [
                [.Input: [1.0, 0.0, 0.0], .Output: [1.0]],
                [.Input: [0.0, 1.0, 0.0], .Output: [1.0]],
                [.Input: [0.0, 0.0, 1.0], .Output: [1.0]],
                [.Input: [1.0, 1.0, 0.0], .Output: [0.0]],
                [.Input: [1.0, 0.0, 1.0], .Output: [0.0]],
                [.Input: [0.0, 1.0, 1.0], .Output: [0.0]],
                [.Input: [1.0, 1.0, 1.0], .Output: [1.0]],
            ]
        )
        self.ValidationData = TrainValidateDataSet(
            DataSetID: UUID(),
            DataSets: [
                // One active input -> true
                [.Input: [0.05, 0.10, 0.90], .Output: [1.0]],
                [.Input: [0.85, 0.10, 0.05], .Output: [1.0]],
                [.Input: [0.10, 0.90, 0.15], .Output: [1.0]],

                // Three active inputs -> true
                [.Input: [0.85, 0.80, 0.90], .Output: [1.0]],

                // Two active inputs -> false
                [.Input: [0.90, 0.80, 0.10], .Output: [0.0]],
                [.Input: [0.90, 0.10, 0.85], .Output: [0.0]],
                [.Input: [0.10, 0.85, 0.90], .Output: [0.0]],

                // Near decision boundaries
                [.Input: [0.40, 0.45, 0.05], .Output: [0.0]],
                [.Input: [0.45, 0.05, 0.50], .Output: [0.0]],
                [.Input: [0.05, 0.50, 0.45], .Output: [0.0]],

                [.Input: [0.75, 0.10, 0.20], .Output: [1.0]],
                [.Input: [0.20, 0.75, 0.10], .Output: [1.0]],
            ]
        )
    }
}

struct EmptyDataSet: DataSetProtocol {
    var ID: UUID
    var NumberOfInputs: Int
    var NumberOfOutputs: Int
    var TrainData: TrainValidateDataSet
    var ValidationData: TrainValidateDataSet
    
    init() {
        self.ID = UUID()
        self.NumberOfInputs = 0
        self.NumberOfOutputs = 0
        self.TrainData = TrainValidateDataSet(
            DataSetID: UUID(),
            DataSets: [
            ]
        )
        self.ValidationData = TrainValidateDataSet(
            DataSetID: UUID(),
            DataSets: [
            ]
        )
    }
}



// Data for LossFunctionCalibration
/// Run multiple times with rand.brain
class LossFunctionCalibrationData {
    var DataID: UUID
    var NumberOfInputs: Int
    var NumberOfOutputs: Int
    var DataSet: [[NeuronType: [Float32]]]
    
    init() {
        self.DataID = UUID()
        self.NumberOfInputs = 3
        self.NumberOfOutputs = 1
        self.DataSet = [
            [.Input: [1.0, 0.0, 0.0], .Output: [1.0]],
            [.Input: [0.0, 1.0, 0.0], .Output: [1.0]],
            [.Input: [0.0, 0.0, 1.0], .Output: [1.0]],
            [.Input: [1.0, 1.0, 0.0], .Output: [0.0]],
            [.Input: [1.0, 0.0, 1.0], .Output: [0.0]],
            [.Input: [0.0, 1.0, 1.0], .Output: [0.0]],
            [.Input: [1.0, 1.0, 1.0], .Output: [1.0]],
        ]
    }
}
