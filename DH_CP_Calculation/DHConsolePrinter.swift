//
//  DHConsolePrinter.swift
//  DH_CP_Calculation
//
//  Created by Dimitri Haas on 16.06.18.
//  Copyright © 2018 Dimitri Haas. All rights reserved.
//

import Foundation

class DHConsolePrinter {
    let calculator = DHCalculator()
    
    /**
     Printing all cp values between 66.6% and 100% perfection
     - pokemon: Your Pokemon represented by a String. Don't forget to include it to the database.
     - atLvl: Insert the level of your Pokemon. Should be a number between 1 and 40.
     */
    public func printCPRangeOf(_ pokemon: String, atLvl level: Int) {
        guard let list = calculator.calculateCPRangeOf(pokemon, atLvl: level) else {
            return
        }
        var ivString: String
        var ivAStr: String
        var ivDStr: String
        var ivSStr: String
        var perfection: Double
        
        print("– \(pokemon) Lv.\(level) –")
        
        for (iv,cp) in list {
            ivString = iv
            ivAStr = String(ivString.removeFirst())
            ivSStr = String(ivString.removeLast())
            ivDStr = ivString
            perfection = Double(round(10*(Double(calculator.digitSum(Int(ivAStr+ivDStr+ivSStr)!)+30)*100/45))/10)
            print("CP: \(cp) | IV: A1\(ivAStr), D1\(ivDStr), S1\(ivSStr) | \(perfection)%")
        }
    }
    
    /**
     Printing all cp values at lvl x and lvl x+5 between 66.6% and 100% perfection
     - pokemon: Your Pokemon represented by a String. Don't forget to include it to the database.
     - atLvl: Insert the level of your Pokemon. Should be a number between 0 and 40.
     */
    public func printCPRangeOfRaid(_ pokemon: String, atLvl level: Int) {
        guard let list = calculator.calculateCPRangeOfRaid(pokemon, atLvl: level) else {
            return
        }
        
        var ivString: String
        var ivAStr: String
        var ivDStr: String
        var ivSStr: String
        var perfection: Double
        
        print("– \(pokemon) Lv.\(level) –")
        
        for (iv,cp) in list {
            ivString = iv
            ivAStr = String(ivString.removeFirst())
            ivSStr = String(ivString.removeLast())
            ivDStr = ivString
            perfection = Double(round(10*(Double(calculator.digitSum(Int(ivAStr+ivDStr+ivSStr)!)+30)*100/45))/10)
            print("Lv20CP: \(cp.0) | Lv25CP: \(cp.1)  | IV: A1\(ivAStr), D1\(ivDStr), S1\(ivSStr) | \(perfection)%")
        }
    }
    
    // TODO: Alle anderen CP-Confis, die eine Wahrscheinlichkeit von >5% haben ebenfalls 100er zu sein,
    //       herausfiltern und separat mit Wahrscheinlichkeiten präsentieren
    // TODO: Einen CP-String für ALLE 100er Confis ausgeben sowie für >5% einen weiteren String
    
    // Calculate all 100 IV configurations of a pokemon and its unique 100 IV values
    func printCPDataForCommunityDay(_ pokemon: String) {
        var only100 = [Int]()
        var allIVs = [Int]()
        
        // Berechne alle möglichen IV Konfigurationen außer die 100er
        for level in 1...35 {
            for ivA in 0...15 {
                for ivD in 0...15 {
                    for ivS in 0...15 where ivA != 15 || ivD != 15 || ivS != 15 {
                        allIVs.append(calculator.calculateCPOf(pokemon, atLvl: level, withIVs: (Double(ivA), Double(ivD), Double(ivS))) ?? 0)
                    }
                }
            }
        }
        
        // Berechne alle 100IV-Konfigurationen
        for i in 1...35 {
            only100.append(calculator.calculateCPOf(pokemon, atLvl: i, withIVs: (15,15,15)) ?? 0)
        }
        
        print(pokemon.uppercased())
        // No weather boost
        print("NO WEATHER BOOST")
        let only100NWB = only100.prefix(30)
        
        print("All 100 IV configurations: \n" + "\(only100NWB)")
        
        let filtered = only100NWB.filter { !allIVs.prefix(30*(16*16*16-1)).contains($0) }
        print("All unique 100 IV configurations: \n" + "\(filtered)\n")
        
        // With weather boost
        print("WITH WEATHER BOOST")
        let only100WB = only100.suffix(30)
        
        print("All 100 IV configurations: \n" + "\(only100WB)")
        
        only100 = only100WB.filter { !allIVs.suffix(30*(16*16*16-1)).contains($0) }
        print("All unique 100 IV configurations: \n" + "\(only100)")
    }
    
}
