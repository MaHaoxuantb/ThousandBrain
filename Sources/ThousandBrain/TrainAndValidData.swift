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
                [.Input: [-0.06, -0.50, -0.56], .Output: [0.5]],
                [.Input: [0.82, -0.04, 0.14], .Output: [1.0]],
                [.Input: [0.06, 0.76, -0.02], .Output: [1.0]],
                [.Input: [0.16, 0.02, 0.86], .Output: [1.0]],

                [.Input: [0.88, 0.74, 0.10], .Output: [0.5]],
                [.Input: [0.92, 0.00, 0.78], .Output: [0.5]],
                [.Input: [-0.02, 0.82, 0.84], .Output: [0.5]],
                [.Input: [0.72, 0.68, 0.76], .Output: [1.0]],

                [.Input: [0.20, 0.32, 0.40], .Output: [0.5]],
                [.Input: [0.56, 0.38, 0.28], .Output: [1.0]],
                [.Input: [0.58, 0.62, 0.24], .Output: [0.5]],
                [.Input: [0.60, 0.64, 0.66], .Output: [1.0]],
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
