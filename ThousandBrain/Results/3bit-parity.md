3-bit parity validation passed with noisy validation data.


Brain initialize completed.
Finished Outer Iteration:  1  ,Inner Iterations Used:  24
Finished Outer Iteration:  2  ,Inner Iterations Used:  25
Finished Outer Iteration:  3  ,Inner Iterations Used:  25
Finished Outer Iteration:  4  ,Inner Iterations Used:  25
Finished Outer Iteration:  5  ,Inner Iterations Used:  26
Finished Outer Iteration:  6  ,Inner Iterations Used:  27
Finished Outer Iteration:  7  ,Inner Iterations Used:  27
Finished Outer Iteration:  8  ,Inner Iterations Used:  28
ThousandBrain.BRAIN
Passed Validation, with AverageWrongIndex:  0.1749932
Finished Validate Outer Iteration:  1  ,Inner Iterations Used:  24
Passed Validation, with AverageWrongIndex:  0.047047928
Finished Validate Outer Iteration:  2  ,Inner Iterations Used:  25
Passed Validation, with AverageWrongIndex:  0.044931434
Finished Validate Outer Iteration:  3  ,Inner Iterations Used:  25
Passed Validation, with AverageWrongIndex:  0.04774117
Finished Validate Outer Iteration:  4  ,Inner Iterations Used:  25
Passed Validation, with AverageWrongIndex:  0.17499928
Finished Validate Outer Iteration:  5  ,Inner Iterations Used:  26
Passed Validation, with AverageWrongIndex:  0.1749942
Finished Validate Outer Iteration:  6  ,Inner Iterations Used:  26
Passed Validation, with AverageWrongIndex:  0.17499879
Finished Validate Outer Iteration:  7  ,Inner Iterations Used:  26
Passed Validation, with AverageWrongIndex:  0.012064812
Finished Validate Outer Iteration:  8  ,Inner Iterations Used:  27
Passed Validation, with AverageWrongIndex:  0.1749931
Finished Validate Outer Iteration:  9  ,Inner Iterations Used:  25
Passed Validation, with AverageWrongIndex:  0.012442708
Finished Validate Outer Iteration:  10  ,Inner Iterations Used:  26
Passed Validation, with AverageWrongIndex:  0.17499247
Finished Validate Outer Iteration:  11  ,Inner Iterations Used:  26
Passed Validation, with AverageWrongIndex:  0.0117570935
Finished Validate Outer Iteration:  12  ,Inner Iterations Used:  27
Finished Running.
Program ended with exit code: 0



//MARK: - Train Data
class TrainData {
    var DataID: UUID
    var TrainDataSets: [[NeuronType: Float32]]
    
    init() {
        self.DataID = UUID()
        self.TrainDataSets = [
            [.Input1: 0.5, .Input2: 0.5, .Input3: 0.5, .Output1: 0.5],
            [.Input1: 1.0, .Input2: 0.5, .Input3: 0.5, .Output1: 1.0],
            [.Input1: 0.5, .Input2: 1.0, .Input3: 0.5, .Output1: 1.0],
            [.Input1: 0.5, .Input2: 0.5, .Input3: 1.0, .Output1: 1.0],
            [.Input1: 1.0, .Input2: 1.0, .Input3: 0.5, .Output1: 0.5],
            [.Input1: 1.0, .Input2: 0.5, .Input3: 1.0, .Output1: 0.5],
            [.Input1: 0.5, .Input2: 1.0, .Input3: 1.0, .Output1: 0.5],
            [.Input1: 1.0, .Input2: 1.0, .Input3: 1.0, .Output1: 1.0]
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
            [.Input1: 0.47, .Input2: 0.55, .Input3: 0.52, .Output1: 0.5],
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
            [.Input1: 0.80, .Input2: 0.82, .Input3: 0.83, .Output1: 1.0]
        ]
    }
}

