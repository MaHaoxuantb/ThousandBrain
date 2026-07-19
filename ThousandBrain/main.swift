//
//  main.swift
//  ThousandBrain
//
//  Created by Thomas B on Jul 7, 26.
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

let TestConfig = Config()

//MARK: -Core

class Core {
    let CoreCals = CoreCalculations()
    
    
    // Init function
    func InitializeBrain(Brain: BRAIN) {
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
            
            // Randomly choose input1, input2 and output1 neuron
            for OneNeuronType in NeuronType.allCases {
                var ThereIsOneThisNeuronType: Bool = false
                while !ThereIsOneThisNeuronType {
                    for OneNeuron in ThisGroup.Neurons {
                        if OneNeuron.NeuronType == .Normal {
                            let RandomNumber: Float = Float.random(in: 0.0...1.0)
                            if RandomNumber < 1.0 / Float(TestConfig.NumberOfNeuronsInAGroup) {
                                OneNeuron.NeuronType = OneNeuronType
                                // Lower Leakage for Output Neurons
                                if OneNeuronType == .Output1 {
                                    OneNeuron.MembraneTimeConstant = 100
                                }
                            }
                            if CalculateTotalNumberOfSpecificNeuronType(Neurons: ThisGroup.Neurons, Type: OneNeuronType) > 0
                            {
                                ThereIsOneThisNeuronType = true
                                break
                            }
                        }
                    }
                }
            }
        }

        func CalculateTotalNumberOfSpecificNeuronType(Neurons: [Neuron], Type: NeuronType)
            -> Int
        {
            var Num: Int = 0
            for OneNeuron in Neurons {
                if OneNeuron.NeuronType == Type {
                    Num += 1
                }
            }
            return Num
        }
    }

    // One Single Iteration for a group
    func OneSingleIteration(
        Group: Group, CurrentInnerIteration: Int64, TotalNumberOfAPFired: inout Int64, TotalEnergyLeft: inout Float32
    ) {
        // First is process the outcomming APs: BodyPotential -> IncommingPotential
        for OneNeuron in Group.Neurons {
            // Handle graded potential changes into active potential
            if (OneNeuron.BodyVoltage > OneNeuron.APThreshold)
                && (OneNeuron.NeuronState == .Normal)
            {
                OneNeuron.NeuronState = .Cumulating
                OneNeuron.LastAPTime = CurrentInnerIteration
                TotalNumberOfAPFired += 1
            }
            if OneNeuron.NeuronState == .Cumulating {
                let ActiveTime = CurrentInnerIteration - OneNeuron.LastAPTime
                if ActiveTime >= OneNeuron.ActiveDischargeInputSimulateCurve.count {
                    OneNeuron.NeuronState = .Normal
//                    OneNeuron.BodyVoltage = TestConfig.RestingPotential  // DEBUG ONLY
                } else {
                    // This is using extra input to simulate excitment of the neurons
                    // But only when there is excess energy to do so
                    if TotalEnergyLeft > 0.001 { // To avoid extremely small TotalEnergyLeft numbers that could cause problems
                        let VoltageIncrement: Float32 = OneNeuron.ActiveDischargeInputSimulateCurve[Int(exactly: ActiveTime)!] * (TotalEnergyLeft / TestConfig.TotalEnergyLeft)
                        OneNeuron.BodyVoltage += VoltageIncrement
                        TotalEnergyLeft -= VoltageIncrement
                    }
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

        // Next, Move the incoming potential to the body potential
//        for OneNeuron in Group.Neurons {
//            OneNeuron.BodyVoltage += OneNeuron.IncomingPotential
//            OneNeuron.BodyVoltage = 0.0
//        }
    }

    // One Inner Iteration
    func OneInnerIteration(B: BRAIN, CurrentInnerIteration: Int64, TotalEnergyLeft: inout Float32) -> Bool {
        var AllGroupsFinished: Bool = true
        var TotalHeat: Float64 = 0.0
        var TotalNumberOfAPFired: Int64 = 0
        var TotalNumberOfUnfinishedGroups: Int = 0
        for Group in B.Groups {
            if !Group.Finished {
                AllGroupsFinished = false
                OneSingleIteration(
                    Group: Group,
                    CurrentInnerIteration: CurrentInnerIteration,
                    TotalNumberOfAPFired: &TotalNumberOfAPFired,
                    TotalEnergyLeft: &TotalEnergyLeft
                )
                // Move incoming potential to body potential
                for Neuron in Group.Neurons {
                    Neuron.BodyVoltage += Neuron.IncomingPotential
                    Neuron.IncomingPotential = 0.0
                }
                CoreCals.HeatCal(G: Group)
                TotalHeat += Float64(Group.Heat)
                TotalNumberOfUnfinishedGroups += 1
            }
        }
        B.TotalHeat = TotalHeat
        if TestConfig.DEBUG {
            print(
                "Total AP Fired: ", TotalNumberOfAPFired, ", Total Number of unfinished groups: ",
                TotalNumberOfUnfinishedGroups)
        }
        return AllGroupsFinished
    }
}

//MARK: -Core Calculations
class CoreCalculations {
    // Core Leak function
    func LeakRateCal(N: Neuron, CurrentInnerIteration: Int64) -> Float32 {
        var leak: Float32 = 0.0
        leak = TestConfig.LeakRateMultiplier * ((N.BodyVoltage - TestConfig.RestingPotential) / N.MembraneTimeConstant)
        if leak < 0.0 { leak = 0.0 }
        return leak
    }
    // Core Heat function
    // Used to check the total energy of a group, that could be used to check if the iterations stops
    func HeatCal(G: Group) {
        // TotalEnergy
        var TotalEnergy: Float32 = 0.0
        for Neuron in G.Neurons {
            if Neuron.NeuronType != .Output1 {  // Output is used for incrementing, not doing this
                TotalEnergy += Neuron.BodyVoltage
            }
        }
        // Threshold
        var ReachedThreshold: Bool = false
        let Threshold: Float32 =
            TestConfig.StopHeatThreshold * Float32(TestConfig.NumberOfNeuronsInAGroup)
        if TotalEnergy < Threshold {
            ReachedThreshold = true
        }
        G.Finished = ReachedThreshold
        G.Heat = TotalEnergy
        
        
        // DEBUG ONLY
        for N in G.Neurons {
            if N.NeuronType == .Output1 {
                if N.BodyVoltage > -70.0 {
                    G.Finished = true
                }
            }
        }
    }
    // Wrong Index
    func WrongIndexCal(N: Neuron, CorrectAnswer: Float32) -> Float32 {
        let NeuronActivationIndex = 1.0 / (1.0 + exp((-0.1) * (N.BodyVoltage - (0.5*(TestConfig.RestingPotential + TestConfig.ActivatedOnPotential)))))
        let NeuronActivationIndexNew = 0.5 + 0.5 * NeuronActivationIndex        // maps activation to 0.5...1.0
        
        // DEBUG ONLY
        if abs(CorrectAnswer - NeuronActivationIndexNew)*2 <= 0 || abs(CorrectAnswer - NeuronActivationIndexNew)*2 >= 1 {
            print("WrongIndexCal out of range.")
        }
        
        return abs(CorrectAnswer - NeuronActivationIndexNew)*2
    }
}

//MARK: -Core Learning

class CoreLearning {
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
        if WrongIndex > 0.25 {
            for N in G.Neurons {
                for A in N.LowerAxons {
                    A.ConnectionStrength -= A.ConnectionStrength * WrongIndex
                    if A.ConnectionStrength <= 0 {
                        print("This strength went less than zero, with WrongIndex of: ", WrongIndex, "and the connection strength of (now):", A.ConnectionStrength)
                    }
                }
            }
        } else {    // for Lower WrongIndex
            for N in G.Neurons {
                for A in N.LowerAxons {
                    while true {
                        A.ConnectionStrength += A.ConnectionStrength * (1 - WrongIndex)
                        if (A.ConnectionStrength < 1) { break }
                    }
                }
            }
        }
    }
}

//MARK: -Core Run

class CoreRun {
    let C = Core()
    let SG = SafeGuard()
    
    func InitializeInputs(B: BRAIN, TrainDataSet: [NeuronType: Float32]) {
        for G in B.Groups {
            for N in G.Neurons {
                var Activation: Float32 = 0.5
                if (N.NeuronType != .Normal) && (N.NeuronType != .Output1) {
                    Activation = 1 - TrainDataSet[N.NeuronType]!
                }
                N.BodyVoltage = TestConfig.RestingPotential * Activation
            }
        }
    }
    
    func RunInnerIterations(B: BRAIN) -> Int64 {
        // Start Iteration
        var CurrentInnerIteration: Int64 = 0
        var AllGroupsFinished: Bool = false
        var TotalEnergyLeft: Float32 = TestConfig.TotalEnergyLeft
        while !AllGroupsFinished {
            CurrentInnerIteration += 1
            AllGroupsFinished = C.OneInnerIteration(
                B: B,
                CurrentInnerIteration: CurrentInnerIteration,
                TotalEnergyLeft: &TotalEnergyLeft
            )
            if TestConfig.DEBUG {
                print("Finished Iteration: ", CurrentInnerIteration, "Brain Total Heat: ", B.TotalHeat)
            }
            if CurrentInnerIteration >= TestConfig.MaxInnerIterations {
                print("Break from Inner Iterations reached Maximum")
                break
            }
            if SG.ConnectionStrength(B: B) {
                print("SafeGuard Error. At inner iteration: ", CurrentInnerIteration)
            }
        }
        return CurrentInnerIteration
    }
    
    func CleanTheBrain(B: BRAIN) {
        for G in B.Groups {
            G.Finished = false
            G.Heat = 0.0
            for N in G.Neurons {
                N.BodyVoltage = 0.0
                N.IncomingPotential = 0.0
                N.NeuronState = .Normal
                N.LastAPTime = 0
            }
        }
        B.TotalHeat = 0.0
    }
}

//MARK: -Exec

class TrainAndValidate {
    
    let CR = CoreRun()
    let CL = CoreLearning()
    let CoreCals = CoreCalculations()
    
    func Train(B: BRAIN) {
        // Outer Iterations
        let TD = TrainData()
        var CurrentOuterIteration: Int64 = 0
        for TrainDataSet in TD.TrainDataSets {
            // Initialize the Input Neurons
            CR.InitializeInputs(B: B, TrainDataSet: TrainDataSet)
            
            // Inner Iteration to get the result
            let InnerIterationsUsed = CR.RunInnerIterations(B: B)
            
            // Punish all groups that get the thing wrong accordingly
            // Just Random the connections for all groups
            for G in B.Groups {
                // First check how right the group is
                var WrongIndex: Float32 = 0.0
                let CorrectAnswer: Float32 = TrainDataSet[.Output1]!
                for N in G.Neurons {
                    if N.NeuronType == .Output1 {
                        WrongIndex = CoreCals.WrongIndexCal(N: N, CorrectAnswer: CorrectAnswer)
                    }
                }
                // Randomnize Accordingly
                CL.InhibitionLearning(G: G, WrongIndex: WrongIndex)
            }
            
            CR.CleanTheBrain(B: B)
            CurrentOuterIteration += 1
            print("Finished Outer Iteration: ", CurrentOuterIteration, " ,Inner Iterations Used: ", InnerIterationsUsed)
            
            // Testing for the neuron connection strength problem
            //        for G in B.Groups {
            //            for N in G.Neurons {
            //                for A in N.LowerAxons {
            //                    if A.ConnectionStrength <= 0.0 {
            //                        print("Something Went wrong")
            //                    }
            //                }
            //            }
            //        }
        }
    }
    
    
    //MARK: - Validify
    func Validify(B: BRAIN) {
        // Outer Iterations
        let VD = ValidationData()
        var CurrentOuterIteration: Int64 = 0
        for TrainDataSet in VD.TrainDataSets {
            // Initialize the Input Neurons
            CR.InitializeInputs(B: B, TrainDataSet: TrainDataSet)
            
            // Inner Iteration to get the result
            let InnerIterationsUsed = CR.RunInnerIterations(B: B)
            
            // Check If Correct
            var IndividualWrongIndexs: [Float32] = []
            var NumOfGroupsGotThisRight: Int = 0
            for Type in NeuronType.allCases {
                if String(describing: Type).hasPrefix("Ou") { // Start with OU is output
                    let CorrectAnswer: Float32 = TrainDataSet[Type]!
                    for G in B.Groups {
                        // First check how right the group is
                        for N in G.Neurons {
                            if N.NeuronType == .Output1 {
                                let ThisWrongIndex = CoreCals.WrongIndexCal(N: N, CorrectAnswer: CorrectAnswer)
                                IndividualWrongIndexs.append(ThisWrongIndex)
                                if ThisWrongIndex < 0.25 {
                                    NumOfGroupsGotThisRight += 1
                                }
                            }
                        }
                    }
                }
            }
            
            print("Individual Group WrongIndexes: ", IndividualWrongIndexs)
            
            let AverageWrongIndex = IndividualWrongIndexs.reduce(0, +) / Float32(IndividualWrongIndexs.count)
            let MaxWrongIndex = IndividualWrongIndexs.max() ?? 1.0
            
            if Float(NumOfGroupsGotThisRight) > (0.5 * Float(IndividualWrongIndexs.count)) {
                print("Passed Validation, AverageWrongIndex:", AverageWrongIndex, "MaxWrongIndex:", MaxWrongIndex)
            } else {
                print("Failed Validation, AverageWrongIndex:", AverageWrongIndex, "MaxWrongIndex:", MaxWrongIndex)
            }
            
            CR.CleanTheBrain(B: B)
            CurrentOuterIteration += 1
            print("Finished Validate Outer Iteration: ", CurrentOuterIteration, " ,Inner Iterations Used: ", InnerIterationsUsed)
        }
    }
}

func runTheFuckingCode() {
    let C = Core()
    let TV = TrainAndValidate()
    
    let Brain = BRAIN()
    
    C.InitializeBrain(Brain: Brain)
    print("Brain initialize completed.")
    
    for _ in 0...1000 {
        TV.Train(B: Brain)
    }
    
    TV.Validify(B: Brain)
    
    print("Finished Running.")
}

runTheFuckingCode()
