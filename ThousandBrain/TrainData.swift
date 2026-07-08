import Foundation

//MARK: -Train Data
class TrainData {
    var DataID: UUID
    var DataPoints: [OneDataPoint]

    init() {
        self.DataID = UUID()
        self.DataPoints = [
            OneDataPoint(I1: 0.5, I2: 0.5, O1: 0.5),
            OneDataPoint(I1: 0.5, I2: 1.0, O1: 1.0),
            OneDataPoint(I1: 1.0, I2: 0.5, O1: 1.0),
            OneDataPoint(I1: 1.0, I2: 1.0, O1: 0.5),
            OneDataPoint(I1: 0.5, I2: 0.5, O1: 0.5),
            OneDataPoint(I1: 0.5, I2: 1.0, O1: 1.0),
            OneDataPoint(I1: 1.0, I2: 0.5, O1: 1.0),
            OneDataPoint(I1: 1.0, I2: 1.0, O1: 0.5),
            OneDataPoint(I1: 0.5, I2: 0.5, O1: 0.5),
            OneDataPoint(I1: 0.5, I2: 1.0, O1: 1.0),
            OneDataPoint(I1: 1.0, I2: 0.5, O1: 1.0),
            OneDataPoint(I1: 1.0, I2: 1.0, O1: 0.5),
        ]
    }

    struct OneDataPoint {
        var I1: Float32  // Input1
        var I2: Float32
        var O1: Float32  // Output1
    }
}
