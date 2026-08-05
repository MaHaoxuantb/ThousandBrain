//
//  main.swift
//  ThousandBrain
//
//  Created by Thomas B on Jul 7, 26.
//

//
//  The Overall Purpose:
//  I want to create something unsupervised, that is free from over abstraction from our studies from neurons. It should be able to do evolution it self.
//

//
// Stage1 GOAL:
// Make a usable classification model using ThousandBrainTheory (XOR test)
//
// Stage2 GOAL:
// Use a visial interpretation thing and make the "Brain" control foco point.
//
//
// Leak:
// \frac{dV}{dt} = -\frac{V - V_{\text{rest}}}{\tau} + \text{input}
//

import Foundation
import Dispatch

//MARK: -Core

class Core {
    let CoreCals = CoreCalculations()
    let TestConfig = Config()

    //MARK: -Init function
    func InitializeBrain(Brain: BRAIN, BrainConfig: BRAIN.BrainConfig) {
        Brain.Groups = (1...TestConfig.NumberOfGroupsInABrain).map { _ in
            Group()
        }

        for ThisGroup in Brain.Groups {
            // Create neurons and log their UUID
            ThisGroup.Neurons = (1...TestConfig.NumberOfNeuronsInAGroup).map { _ in
                Neuron()
            }

            var InitNeuronsIDs: [UUID] = []
            for Neuron in ThisGroup.Neurons {
                InitNeuronsIDs.append(Neuron.id)
            }

            // Create all connected axons with random strength (except self-connected ones)
            for Neuron in ThisGroup.Neurons {
                let IDOfItself = Neuron.id
                for ID in InitNeuronsIDs {
                    if ID != IDOfItself {
                        Neuron.LowerAxons.append(Axon(ConnectedNeuronID: ID))
                    }
                }
            }

            // Randomly choose input output neuron, how to choose actually doesn't matter
            for OneNeuronType in [NeuronType.Input, NeuronType.Output] {
                var TotalNumberInThisType: Int = -1
                if OneNeuronType == .Input {
                    TotalNumberInThisType = BrainConfig.NumberOfInputs
                } else if OneNeuronType == .Output {
                    TotalNumberInThisType = BrainConfig.NumberOfOutputs
                }
                for SequenceNumber in 0...TotalNumberInThisType-1 {
                    var ThereIsOneThisNeuronType: Bool = false
                    while !ThereIsOneThisNeuronType {
                        for OneNeuron in ThisGroup.Neurons {
                            if OneNeuron.NeuronType == .Normal {
                                let RandomNumber: Float = Float.random(in: 0.0...1.0)
                                if RandomNumber < 1.0 / Float(TestConfig.NumberOfNeuronsInAGroup) {
                                    OneNeuron.NeuronType = OneNeuronType
                                    // Lower Leakage for Output Neurons
                                    if OneNeuronType == .Output {
                                        OneNeuron.MembraneTimeConstant = 100
                                    }
                                    OneNeuron.InputOutputSequenceNumber = SequenceNumber
                                }
                                if CalculateTotalNumberOfSpecificNeuronType(Neurons: ThisGroup.Neurons, Type: OneNeuronType, SequenceNumber: SequenceNumber) > 0
                                {
                                    ThereIsOneThisNeuronType = true
                                    break
                                }
                            }
                        }
                    }
                }
            }
            
            // Give correct initialization to TotalFiringByOutputNeuronsInObservationPhase
            ThisGroup.TotalFiringByOutputNeuronsInObservationPhase = Array(repeating: 0, count: BrainConfig.NumberOfOutputs)
        }

        func CalculateTotalNumberOfSpecificNeuronType(Neurons: [Neuron], Type: NeuronType, SequenceNumber: Int)
            -> Int
        {
            var Num: Int = 0
            for OneNeuron in Neurons {
                if (OneNeuron.NeuronType == Type) && (OneNeuron.InputOutputSequenceNumber == SequenceNumber) {
                    Num += 1
                }
            }
            return Num
        }
    }

    //MARK: -One Single Iteration for a group
    func OneSingleIteration(
        Group: Group, CurrentInnerIteration: Int64, InObservationPhase: Bool, TotalNumberOfAPFired: Int64, TotalEnergyLeft: Float32
    ) -> (Int64, Float32) {
        var NewTotalNumberOfAPFired: Int64 = TotalNumberOfAPFired
        var NewTotalEnergyLeft: Float32 = TotalEnergyLeft

        // First is process the outcomming APs: BodyPotential -> IncommingPotential
        for OneNeuron in Group.Neurons {
            // Handle graded potential changes into action potential
            if (OneNeuron.BodyVoltage > OneNeuron.APThreshold)
                && (OneNeuron.NeuronState == .Normal)
            {
                OneNeuron.NeuronState = .Cumulating
                OneNeuron.LastAPTime = CurrentInnerIteration
                NewTotalNumberOfAPFired += 1
                if InObservationPhase {
                    if OneNeuron.NeuronType == NeuronType.Output {
                        Group.TotalFiringByOutputNeuronsInObservationPhase[OneNeuron.InputOutputSequenceNumber] += 1
                    }
                }
            }
            if OneNeuron.NeuronState == .Cumulating {
                let ActiveTime = CurrentInnerIteration - OneNeuron.LastAPTime
                if ActiveTime >= OneNeuron.ActiveDischargeInputSimulateCurve.count {
                    OneNeuron.NeuronState = .Normal
//                    OneNeuron.BodyVoltage = TestConfig.RestingPotential  // DEBUG ONLY
                } else {
                    /// This is using extra input to simulate excitment of the neurons
                    /// But only when there is excess energy to do so
                    if TotalEnergyLeft > 0.001 { /// To avoid extremely small TotalEnergyLeft numbers that could cause problems
                        let VoltageIncrement: Float32 = OneNeuron.ActiveDischargeInputSimulateCurve[Int(exactly: ActiveTime)!] * (TotalEnergyLeft / TestConfig.TotalBrainEnergy)
                        OneNeuron.BodyVoltage += VoltageIncrement
                        NewTotalEnergyLeft -= VoltageIncrement
                    }
                }
            }
            // Handle InputNeuron firing
            if OneNeuron.NeuronType == .Input {
                // Times 2 is to regulate, even the frequency is 1.0 should fire with intervals
                if Float32.random(in: 0.0...1.0)*2 < OneNeuron.InputFiringPossibility {
                    OneNeuron.BodyVoltage += OneNeuron.HighestInputFiring
                }
            }
            // So we need to get the total leak first, for each neuron
            let TotalLeak = CoreCals.LeakRateCal(
                N: OneNeuron, CurrentInnerIteration: CurrentInnerIteration)
            // Then we need to get the total connection strength
            var TotalLowerAxonConnectionStrength: Float32 = 0.0001
            var ListOfLowerNeuronIDs: [UUID] = []
            var ListOfLowerConnectionStrengths: [Float32] = []
            for OneLowerAxon in OneNeuron.LowerAxons {
                let ThisLowerConnectionStrength: Float32 = OneLowerAxon.ConnectionStrength
                TotalLowerAxonConnectionStrength += ThisLowerConnectionStrength
                ListOfLowerNeuronIDs.append(OneLowerAxon.ConnectedNeuronID)
                ListOfLowerConnectionStrengths.append(ThisLowerConnectionStrength)
            }
            if TotalLowerAxonConnectionStrength > 0 {
                for OneLowerAxon in OneNeuron.LowerAxons {
                    OneLowerAxon.TotalVoltagePassed += (OneLowerAxon.ConnectionStrength / TotalLowerAxonConnectionStrength) * TotalLeak     // Increment by this amount
                }

                // We need the voltage given to each fellows and give it to them
                for ThisGivenNeuron in Group.Neurons {
                    if let ListIndex = ListOfLowerNeuronIDs.firstIndex(of: ThisGivenNeuron.id) {
                        ThisGivenNeuron.IncomingPotential +=
                            (ListOfLowerConnectionStrengths[ListIndex]
                                / TotalLowerAxonConnectionStrength) * TotalLeak
                    }
                }
            } else {
                if TestConfig.DEBUG {
                    print("Error Occured and I don't want to tell you what error it is.")
                }
            }
            // And Minus for this neuron
            OneNeuron.BodyVoltage -= TotalLeak
        }

        return (NewTotalNumberOfAPFired, NewTotalEnergyLeft)
    }

    //MARK: -One Inner Iteration
    func OneInnerIteration(B: BRAIN, CurrentInnerIteration: Int64, TotalEnergyLeft: Float32, InObservationPhase: Bool) -> Float32 {
        var TotalNumberOfAPFired: Int64 = 0
        var NewTotalEnergyLeft: Float32 = TotalEnergyLeft
        parallelForEach(B.Groups, workerCount: TestConfig.UseCores) { Group in
            (TotalNumberOfAPFired, NewTotalEnergyLeft) = self.OneSingleIteration(
                Group: Group,
                CurrentInnerIteration: CurrentInnerIteration,
                InObservationPhase: InObservationPhase,
                TotalNumberOfAPFired: TotalNumberOfAPFired,
                TotalEnergyLeft: TotalEnergyLeft
            )
            // Move incoming potential to body potential
            for Neuron in Group.Neurons {
                Neuron.BodyVoltage += Neuron.IncomingPotential
                Neuron.IncomingPotential = 0.0
            }
        }
        return NewTotalEnergyLeft
    }

    func parallelForEach<Element>(
        _ elements: [Element],
        workerCount: Int,
        operation: @escaping (Element) -> Void
    ) {
        precondition(workerCount > 0)

        guard !elements.isEmpty else {
            return
        }

        let count = min(workerCount, elements.count)
        let queue = DispatchQueue.global(qos: .userInitiated)
        let group = DispatchGroup()
        let indexLock = NSLock()

        var nextIndex = 0

        for _ in 0..<count {
            group.enter()
            queue.async {
                defer {
                    group.leave()
                }
                while true {
                    let object: Element?
                    indexLock.lock()
                    if nextIndex < elements.count {
                        object = elements[nextIndex]
                        nextIndex += 1
                    } else {
                        object = nil
                    }
                    indexLock.unlock()
                    guard let object else {
                        return
                    }
                    operation(object)
                }
            }
        }
        group.wait()
    }
}

//MARK: -Core Calculations
class CoreCalculations {
    let TestConfig = Config()
    // Core Leak function
    func LeakRateCal(N: Neuron, CurrentInnerIteration: Int64) -> Float32 {
        var leak: Float32 = 0.0
        leak = TestConfig.LeakRateMultiplier * ((N.BodyVoltage - TestConfig.RestingPotential) / N.MembraneTimeConstant)
        if leak < 0.0 { leak = 0.0 }
        return leak
    }
    
    // Wrong Index
    func WrongIndexCal(G: Group, CorrectAnswers: [Float32]) -> Float32 {
        var TotalWrongIndex: Float32 = 0.0
        let TotalNumberOfOutputs: Int = G.TotalFiringByOutputNeuronsInObservationPhase.count
        if TotalNumberOfOutputs != CorrectAnswers.count { // Should be the same
            print("Error code 102384985")
            return 1.0
        }
        for Num in 0...TotalNumberOfOutputs-1 {
            // Statistics used in the formulae
            let MeanFiring: Float32 = TestConfig.MeanFiring
            let FiringSpan: Float32 = TestConfig.FiringSpan
            let FiringScenario: Float32 = 1.0 / (1.0 + exp(-(Float32(G.TotalFiringByOutputNeuronsInObservationPhase[Num]) - MeanFiring)/FiringSpan))
            TotalWrongIndex += abs(CorrectAnswers[Num] - FiringScenario)
        }
        return TotalWrongIndex/Float32(TotalNumberOfOutputs)
    }
}

//MARK: -Core Learning

class CoreLearning {
    let TestConfig = Config()
    // Total Random
    func LearnWithRandomnesss(G: Group, WrongIndex: Float32) {
        for N in G.Neurons {
            for A in N.LowerAxons {
                let OrginalConnectionStrength: Float32 = A.ConnectionStrength
                while true {
                    A.ConnectionStrength = Float32.random(in: 0.000001...0.999999) // Avoid boundaries
                    if (A.ConnectionStrength > OrginalConnectionStrength*WrongIndex * Float((1+TestConfig.RandomLearningValidRange)))
                        && (A.ConnectionStrength > OrginalConnectionStrength*WrongIndex * Float((1-TestConfig.RandomLearningValidRange)))
                        && (0.0 < A.ConnectionStrength)
                        && (A.ConnectionStrength < 1.0){
                        break
                    }
                }
            }
        }
    }

    // Inhibition for wrong groups' current connections, Prohibition for correct ones.
    func InhibitionLearning(G: Group, WrongIndex: Float32) {
        // for Higher WrongIndex
        for N in G.Neurons {
            for A in N.LowerAxons {
                let OriginalValue = A.ConnectionStrength
                while true {
                    if WrongIndex > 0.25 { // Got it wrong
                        A.ConnectionStrength = OriginalValue - WrongIndex * Float32.random(in: -0.299999...0.999999)
                    } else { // Correct
                        A.ConnectionStrength = OriginalValue + WrongIndex * Float32.random(in: -0.299999...0.999999)
                    }
                    if (0 < A.ConnectionStrength && A.ConnectionStrength < 1) { break }
                }
            }
        }
    }
}

//MARK: -Core Run

class CoreRun {
    let C = Core()
    let SG = SafeGuard()
    let TestConfig = Config()

    func RunInnerIterations(B: BRAIN) {
        // Start Iteration
        var CurrentInnerIteration: Int64 = 0
//        var AllGroupsFinished: Bool = false
        var TotalEnergyLeft: Float32 = TestConfig.TotalBrainEnergy
        var InObservationPhase: Bool = false
        // Count based now
        while (CurrentInnerIteration <= (TestConfig.WorkPhaseDuration + TestConfig.OvservationPhaseDuration)) {
            CurrentInnerIteration += 1
            if CurrentInnerIteration > TestConfig.WorkPhaseDuration{
                InObservationPhase = true
            }
            TotalEnergyLeft = C.OneInnerIteration(
                B: B,
                CurrentInnerIteration: CurrentInnerIteration,
                TotalEnergyLeft: TotalEnergyLeft,
                InObservationPhase: InObservationPhase
            )
            if !SG.ConnectionStrength(B: B)! {
                print("SafeGuard Error. At inner iteration: ", CurrentInnerIteration)
            }
        }
    }
    
    func GetTheBrainReadyForInputs(B: BRAIN, Inputs: [Float32]) {
        for G in B.Groups {
            for N in G.Neurons {
                if N.NeuronType == .Input {
                    N.InputFiringPossibility = Inputs[N.InputOutputSequenceNumber]
                }
            }
        }
    }

    func CleanTheBrain(B: BRAIN) {
        for G in B.Groups {
            G.TotalFiringByOutputNeuronsInObservationPhase = [0]
            for N in G.Neurons {
                N.BodyVoltage = TestConfig.RestingPotential
                N.IncomingPotential = 0.0
                N.NeuronState = .Normal
                N.LastAPTime = 0
            }
        }
//        B.TotalHeat = 0.0
    }
}

//MARK: -Exec

class TrainValidateCalibrate {
    let CR = CoreRun()
    let CL = CoreLearning()
    let SG = SafeGuard()
    let CoreCals = CoreCalculations()

    func TrainOrValidate(B: BRAIN, IsValidation: Bool, RunDataSet: TrainValidateDataSet) {
        // Outer Iterations
        var CurrentOuterIteration: Int64 = 0
        for OneDataSet in RunDataSet.DataSets {
            // Init the inputs
            CR.GetTheBrainReadyForInputs(B: B, Inputs: OneDataSet[.Input]!)
            // Inner Iteration to get the result
            CR.RunInnerIterations(B: B)
            
            // Used only when validating
            /// Put here to avoid Swift syntax check problem
            var IndividualWrongIndexs: [Float32] = []
            var NumOfGroupsGotThisRight: Int = 0
            
            // Punish all groups that get the thing wrong accordingly
            // Just Random the connections for all groups
//            SG.ConnectionStrength(B: B) /// SafeGuard it first
            for G in B.Groups {
                // First check how right the group is
                var WrongIndex: Float32 = 0.0
                let CorrectAnswers: [Float32] = OneDataSet[.Output]!
                WrongIndex = CoreCals.WrongIndexCal(G: G, CorrectAnswers: CorrectAnswers)
                if !IsValidation { /// In training
                    // Randomnize Accordingly
                    CL.InhibitionLearning(G: G, WrongIndex: WrongIndex)
                } else { /// In validation
                    IndividualWrongIndexs.append(WrongIndex)
                    if WrongIndex <= 0.50 {
                        NumOfGroupsGotThisRight += 1
                    }
                }
            }
            
            if IsValidation {
                print("Individual Group WrongIndexes: ", IndividualWrongIndexs)

                let AverageWrongIndex = IndividualWrongIndexs.reduce(0, +) / Float32(IndividualWrongIndexs.count)
                let MaxWrongIndex = IndividualWrongIndexs.max() ?? 1.0

                if Float(NumOfGroupsGotThisRight) > (0.5 * Float(IndividualWrongIndexs.count)) {
                    print("Passed Validation, AverageWrongIndex:", AverageWrongIndex, "MaxWrongIndex:", MaxWrongIndex)
                } else {
                    print("Failed Validation, AverageWrongIndex:", AverageWrongIndex, "MaxWrongIndex:", MaxWrongIndex)
                }
            }

            CR.CleanTheBrain(B: B)
            CurrentOuterIteration += 1
            print("Finished Outer Iteration: ", CurrentOuterIteration)
        }
    }
    
    func CalibrationProcessOnce(B: BRAIN, RunDataSet: [[NeuronType: [Float32]]]) -> [Int32] {
        var CurrentOuterIteration: Int64 = 0
        var TotalFiringByOutputNeuronsInObservationPhaseData: [Int32] = []
        for OneDataSet in RunDataSet {
            CR.GetTheBrainReadyForInputs(B: B, Inputs: OneDataSet[.Input]!)
            CR.RunInnerIterations(B: B)  /// Inner Iteration to get the result
            for G in B.Groups {
                for DataPoint in G.TotalFiringByOutputNeuronsInObservationPhase {
                    TotalFiringByOutputNeuronsInObservationPhaseData.append(DataPoint)
                }
            }
            CR.CleanTheBrain(B: B)
            CurrentOuterIteration += 1
            print("[Calibration] Finished Outer Iteration: ", CurrentOuterIteration)
        }
        return TotalFiringByOutputNeuronsInObservationPhaseData
    }
    
    func PlotCalibrationData(TotalFiringByOutputNeuronsInObservationPhaseData: [Int32]) {
        let MinDataPoint: Int = Int(TotalFiringByOutputNeuronsInObservationPhaseData.min()!)
        let MaxDataPoint: Int = Int(TotalFiringByOutputNeuronsInObservationPhaseData.max()!)
        var ChartData: [(Int32, Int32)] = Array(
            repeating: (Int32(0),Int32(0)),
            count: MaxDataPoint - MinDataPoint 
        )
        for ChartDataCounter in 0...ChartData.count-1 {
            ChartData[ChartDataCounter].0 = Int32(MinDataPoint + ChartDataCounter)
        }
        for SourceDataPoint in TotalFiringByOutputNeuronsInObservationPhaseData {
            for ChartDataPointCounter in 0...ChartData.count-1 {
                if ChartData[ChartDataPointCounter].0 == SourceDataPoint {
                    ChartData[ChartDataPointCounter].1 += 1
                }
            }
        }
        let BCV = BarChartViewer()
        BCV.OpenBarChart(title: "test", data: ChartData)
    }
}


//MARK: -runTheFuckingCode
func runTheFuckingCode() {
    print("©2026 ThomasB. Project Neuro, ThousandBrain.")
    
    let C = Core()
    let TVC = TrainValidateCalibrate()
    let TestConfig = Config()

    let Brain = BRAIN()
    
    // Calibration for the loss function (not loss function exactly)
    if TestConfig.StatisticalCalibration {
        let RunData = LossFunctionCalibrationData()
        var TotalFiringByOutputNeuronsInObservationPhaseData: [Int32] = []
        for _ in 1...5 {
            C.InitializeBrain(Brain: Brain, BrainConfig: BRAIN.BrainConfig(NumberOfInputs: RunData.NumberOfInputs, NumberOfOutputs: RunData.NumberOfOutputs))
            let TempTFBONIOPDData = TVC.CalibrationProcessOnce(B: Brain, RunDataSet: RunData.DataSet)
            for DataPoint in TempTFBONIOPDData {
                TotalFiringByOutputNeuronsInObservationPhaseData.append(DataPoint)
            }
        }
        let DataAverage: Float
            = Float(TotalFiringByOutputNeuronsInObservationPhaseData.reduce(0, +)) / Float(TotalFiringByOutputNeuronsInObservationPhaseData.count)
        let DataRange: Int32
            = TotalFiringByOutputNeuronsInObservationPhaseData.max()! - TotalFiringByOutputNeuronsInObservationPhaseData.min()!
        print("[Calibration data summary] Average: ", DataAverage, ", Range: ", DataRange)
        print("[Calibration data]: ", TotalFiringByOutputNeuronsInObservationPhaseData)
        if TestConfig.ShowGraphForCalibration {
            TVC.PlotCalibrationData(TotalFiringByOutputNeuronsInObservationPhaseData: TotalFiringByOutputNeuronsInObservationPhaseData)
        }
    }
    
    // Normal Run
    let RunData = ThreeInputBooleanClassificationDataset()

    C.InitializeBrain(Brain: Brain, BrainConfig: BRAIN.BrainConfig(NumberOfInputs: RunData.NumberOfInputs, NumberOfOutputs: RunData.NumberOfOutputs))
    print("Brain initialization completed.")

    for _ in 1...20 {
        TVC.TrainOrValidate(B: Brain, IsValidation: false, RunDataSet: RunData.TrainData)
    }

    TVC.TrainOrValidate(B: Brain, IsValidation: true, RunDataSet: RunData.ValidationData)

    print("Finished Running.")
}

runTheFuckingCode()
