//
//  SafeGuard.swift
//  ThousandBrain
//
//  Created by Thomas B on 7/17/26.
//

import Darwin

class SafeGuard {
    func ConnectionStrength(B: BRAIN) -> Bool? {
        var TotallyValid: Bool? = true
        for G in B.Groups {
            for N in G.Neurons {
                for A in N.LowerAxons {
                    if A.ConnectionStrength <= 0 {
                        TotallyValid = false
                        print("SafeGuard: Invalid Connection Strength, lower than 0")
                        A.ConnectionStrength = 0.0001
//                        exit(0)
                    } else if A.ConnectionStrength > 1 {
                        TotallyValid = false
                        print("SafeGuard: Invalid Connection Strength, over 1")
                        A.ConnectionStrength = 0.9999
                    } else if !A.ConnectionStrength.isFinite {
                        assertionFailure("ConnectionStrength became non-finite")
                        A.ConnectionStrength = 0.5
                    }
                }
            }
        }
        return TotallyValid
    }
}
