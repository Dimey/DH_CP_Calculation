//
//  DHLatexTablePrinter.swift
//  DH_CP_Calculation
//
//  Created by Dimitri Haas on 16.06.18.
//  Copyright © 2018 Dimitri Haas. All rights reserved.
//

import Foundation

class DHLatexTablePrinter {
    let calculator = DHCalculator()
    
    // LATEX PARAMETER
    private var defineColorCounter = 1
    private var rowColorCounter = 1
    private let version = "v2.2"
    private let realName = "dhaas"
    private let redditName = "u/profmori4rty"
    
    func printCPTableFor(_ pokemon: [String],
                         atLvl level: [Int],
                         withValueCount: Int,
                         withColorTransition transition: [HSBColorTransition]) {
        
        let pokemonCount = pokemon.count
        let levelColumns = level.count
        let transitionCount = transition.count
        
        // MARK: CHECK VALIDITY OF PARAMETRES
        
        // TODO: Outsource validity check to an extra function
        
        // there should be the same amount of transitions as tables
        if pokemonCount != transitionCount {
            print("Error: Amount of Pokemon should be equal to amount of transitions.")
            return
        }
        
        // all tables have to fit one a4 paper
        if (pokemonCount < 1 && pokemonCount > 4)
            || (levelColumns < 1 && levelColumns > 10)
            || (withValueCount < 1 && withValueCount > 50)
            || levelColumns > Int(floor(Double(truncating: NSDecimalNumber(decimal: 20/pow(2, pokemonCount))))) {
            print("Error: Your tables will not fit a regular a4 format paper.\nChoose less or smaller tables.")
            return
        }
        
        // MARK: GET CALCULATED CP VALUES
        
        // calculate all cp values for every pokemon and level
        var cpValues: [String:[Int:[(key: String, value: Int)]]] = [:];
        for aPokemon in pokemon {
            var cpDataForOnePokemon: [Int:[(key: String, value: Int)]] = [:]
            for aLevel in level {
                cpDataForOnePokemon[aLevel] = calculator.calculateCPRangeOf(aPokemon, atLvl: aLevel)!
            }
            cpValues[aPokemon] = cpDataForOnePokemon
        }
        
        // MARK: HELP FUNCTIONS FOR PRINTING LATEX STATEMENTS
        
        func printHSBColorDefinitions(_ color1: (h: Double, s: Double, b: Double),
                                      to color2: (h: Double, s: Double, b: Double),
                                      withSteps steps: Double) {
            let singleStepForH = (color2.h-color1.h)/steps
            let singleStepForS = (color2.s-color1.s)/steps
            let singleStepForB = (color2.b-color1.b)/steps
            
            var newH: Double
            var newS: Double
            var newB: Double
            for i in 1...Int(steps)+1 {
                newH = ((color1.h + singleStepForH*Double(i-1))*1000).rounded()/1000
                if newH < 0 {
                    newH += 1
                }
                newS = ((color1.s + singleStepForS*Double(i-1))*1000).rounded()/1000
                newB = ((color1.b + singleStepForB*Double(i-1))*1000).rounded()/1000
                print("    \\xdefinecolor{color\(rowColorCounter)}{hsb}{\(newH),\(newS),\(newB)}")
                rowColorCounter += 1
            }
        }
        
        func printTableHeader(_ pokemon: String) {
            func getAmountOfCColumns() -> String {
                var string = "c"
                for _ in 1...levelColumns {
                    string.append("c")
                }
                return string
            }
            
            func getLevelHeader() -> String {
                var string = "Lv\(level[0])  "
                if levelColumns < 2 {
                    return string
                }
                for i in 1...levelColumns-1 {
                    string.append("&Lv\(level[i])  ")
                }
                return string
            }
            
            print("""
                \\begin{minipage}{\(((1.0/Double(pokemonCount))*100).rounded()/100)\\linewidth}
                \\includegraphics[height=3cm]{\(pokemon)}
                \\centering
                \\tcbox[left=0.5mm, right=0.5mm, top=1.5mm, bottom=0.5mm, boxsep=0mm, toptitle=1mm, bottomtitle=1mm,
                title=\(pokemon.uppercased()), fonttitle=\\large\\bfseries]{
                \\begin{tabular}{\(getAmountOfCColumns())S[table-format=3.1]}
                \\multicolumn{\(levelColumns)}{c}{\\textbf{CP}}    \\\\
                \\cmidrule(rl){1-\(levelColumns)}
                \(getLevelHeader())    &\\textbf{IVs}     &\\textbf{\\%} \\\\
                \\midrule
                """)
            
        }
        
        func printTableBody(_ pokemon: String) {
            var ivString: String
            var ivAStr: String
            var ivDStr: String
            var ivSStr: String
            var perfection: Double
            
            let values = cpValues[pokemon]!
            
            func getLevelColumns(_ i: Int) -> String {
                var string = ""
                for aLevel in level {
                    string.append("\(values[aLevel]![i].value)  &")
                }
                return string
            }
            
            for i in 0...withValueCount-1 {
                var ivString = values[level[0]]![i].key
                ivAStr = String(ivString.prefix(1))
                ivSStr = String(ivString.suffix(1))
                ivString.removeFirst()
                ivString.removeLast()
                ivDStr = ivString
                perfection = Double(round(10*(Double(calculator.digitSum(Int(ivAStr+ivDStr+ivSStr)!)+30)*100/45))/10)
                print("\\rowcolor{color\(defineColorCounter)}")
                defineColorCounter += 1
                print("\(getLevelColumns(i))1\(ivAStr) 1\(ivDStr) 1\(ivSStr) &\(perfection) \\\\")
            }
            
            // last entry of table are the worst stats at 66.7% perfection
            print("\\midrule")
            print("\\rowcolor{color\(defineColorCounter)}")
            defineColorCounter += 1
            print("\(getLevelColumns(values[level[0]]!.count-1))10 10 10 &66.7 \\\\")
        }
        
        func printTableEnd() {
            print("""
                \\end{tabular}}
                \\end{minipage}%
            """)
        }
        
        // MARK: PRINTING
        
        // initialize DHLatexConstructs object
        let latexConstructs = DHLatexConstructs(pokemon: pokemon, level: level)
        
        // print document header with pdf meta data
        print(latexConstructs.documentHeader)
        
        // print all color definitions for table rows
        for aTransition in transition {
            printHSBColorDefinitions(aTransition.color1, to: aTransition.color2, withSteps: Double(withValueCount))
        }
        print("\\begin{table}[!htb]")
        
        // print table by table
        for aPokemon in pokemon {
            printTableHeader(aPokemon)
            printTableBody(aPokemon)
            printTableEnd()
        }
        
        // print document end
        print("""
            \\centering
            \\scriptsize{\(version) \\\\ \(realName) \\\\ \(redditName)}
            \\end{table}
            \\end{document}
        """)
        
        /*
        print("""
            \\begin{table}[!htb]
            %\\caption*{Global caption}
            \\begin{minipage}{.5\\linewidth}
            \\includegraphics[height=3cm]{poke1}
            \\centering
            \\tcbox[left=0.5mm,right=0.5mm,top=1.5mm,bottom=0.5mm,boxsep=0mm,
            toptitle=1mm,bottomtitle=1mm,title=\(poke1.uppercased()),fonttitle=\\large\\bfseries]{
            \\begin{tabular}{cccS[table-format=3.1]}
            \\multicolumn{2}{c}{\\textbf{CP}}    \\\\
            \\cmidrule(rl){1-2}
            Lv\(level) &Lv\(level+5 > 40 ? 40 : level+5)    &\\textbf{IVs}     &\\textbf{\\%} \\\\
            \\midrule
            """)
        
        latex_printCPRangeOf(poke1, atLvl: level, withNumberOfValues: Double(withValueCount))
        print("""
            %\\bottomrule
            \\end{tabular}}
            \\end{minipage}%
            \\begin{minipage}{.5\\linewidth}
            \\centering
            \\includegraphics[height=3cm]{poke2}
            \\tcbox[left=0.5mm,right=0.5mm,top=1.5mm,bottom=0.5mm,boxsep=0mm,
            toptitle=1mm,bottomtitle=1mm,title=\(poke2.uppercased()),fonttitle=\\large\\bfseries]{
            \\begin{tabular}{cccS[table-format=3.1]}
            \\multicolumn{2}{c}{\\textbf{CP}}    \\\\
            \\cmidrule(rl){1-2}
            Lv\(level) &Lv\(level+5 > 40 ? 40 : level+5)    &\\textbf{IVs}     &\\textbf{\\%} \\\\
            \\midrule
            """)
        latex_printCPRangeOf(poke2, atLvl: level, withNumberOfValues: Double(withValueCount))
        print("""
            %\\bottomrule
            \\end{tabular}}
            \\end{minipage}
            \\centering
            \\scriptsize{\(version) \\\\ \(realName) \\\\ \(redditName)}
            \\end{table}
            \\end{document}
            """)
        */
        
    }
}
