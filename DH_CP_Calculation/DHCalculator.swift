import Cocoa

public class DHCalculator {
    
    public init() {}
    
    // LATEX PARAMETER
    private var defineColorCounter = 1
    private var rowColorCounter = 1
    private let version = "v2.2"
    private let realName = "dhaas"
    private let redditName = "u/profmori4rty"
    
    // create database and include some Pokemon with base values
    let pokemonDataBase: [String:(baseAtk: Double, baseDef: Double, baseSta: Double)] = [
        "Groudon":(270,251,182),
        "Kyogre":(270,251,182),
        "Raikou":(241,210,180),
        "Lugia":(193,323,212),
        "Ho-Oh":(239,274,193),
        "Feebas":(29,102,40),
        "Metagross":(257,247,160),
        "Salamence":(277,168,190),
        "Aggron":(198,314,140),
        "Armaldo":(222,183,150),
        "Flygon":(205,168,160),
        "Rayquaza":(284,170,191),
        "Latios":(268,228,160),
        "Latias":(228,268,160),
        "Regice":(179,356,160),
        "Regirock":(179,356,160),
        "Registeel":(143,285,160),
        "Tyranitar":(251,212,200),
        "Lunatone":(178,163,180),
        "Charmander":(116,96,78),
        "Larvitar":(115,93,100),
        "Alolan Exeggutor":(230, 158, 190),
        "Articuno":(192,249,180),
        "Aerodactyl":(221,164,160),
        "Squirtle":(94,122,88),
        "Snorlax":(190,190,320),
        "Eevee":(104,121,110)
    ]
    
    let cpMultiplier = [
        0.09400000, 0.16639787, 0.21573247, 0.25572005, 0.29024988,
        0.32108760, 0.34921268, 0.37523559, 0.39956728, 0.42250001,
        0.44310755, 0.46279839, 0.48168495, 0.49985844, 0.51739395,
        0.53435433, 0.55079269, 0.56675452, 0.58227891, 0.59740001,
        0.61215729, 0.62656713, 0.64065295, 0.65443563, 0.66793400,
        0.68116492, 0.69414365, 0.70688421, 0.71939909, 0.73170000,
        0.73776948, 0.74378943, 0.74976104, 0.75568551, 0.76156384,
        0.76739717, 0.77318650, 0.77893275, 0.78463697, 0.79030001
    ]
    
    // just a helper function to calculate a digit sum
    func digitSum(_ n : Int) -> Int {
        return sequence(state: n) { (n: inout Int) -> Int? in
            defer { n /= 10 }
            return n > 0 ? n % 10 : nil
            }.reduce(0, +)
    }
    
    func fetchBaseValuesOf(_ pokemon: String) -> (baseAtk: Double, baseDef: Double, baseSta: Double)? {
        guard let baseValues = pokemonDataBase[pokemon] else {
            print("Pokemon with name '\(pokemon)' not found!")
            print("You can add missing Pokemon by adding them to 'pokemonDataBase' in the 'CPCalculator.swift' file.")
            print("Check the 'Sources' folder in the Project Navigator.")
            return nil
        }
        return (baseValues.baseAtk, baseValues.baseDef, baseValues.baseSta)
    }
    
    func fetchCPMultiplierForLevel(_ level: Int) -> Double {
        if level < 1 || level > 40 {
            print("Invalid Pokemon level. Choose a level between 0 and 40.")
            return cpMultiplier[0]
        }
        return cpMultiplier[level-1]
    }
    
    // single value calculation for certain level and ivs
    func calculateCPOf(_ pokemon: String, atLvl level: Int, withIVs IVs: (ivA: Double, ivD: Double, ivS: Double)) -> Double? {
        guard let baseValues = fetchBaseValuesOf(pokemon) else {
            return nil
        }
        
        let totalCPMultplier = fetchCPMultiplierForLevel(level)
        
        let attack  = (baseValues.baseAtk+IVs.ivA)*totalCPMultplier
        let defense = (baseValues.baseDef+IVs.ivD)*totalCPMultplier
        let stamina = (baseValues.baseSta+IVs.ivS)*totalCPMultplier
        
        let cp = max(10, sqrt(stamina)*attack*sqrt(defense)/10)
        
        return cp
    }
    
    // calculate cps at lvl x in range 10/10/10 to 15/15/15, check possible returns (by cp, by perfection)
    func calculateCPRangeOf(_ pokemon: String, atLvl level: Int) -> [(key: String, value: Int)]? {
        var cpRange: [String : Double] = [:]
        
        for ivA in 10...15 {
            for ivD in 10...15 {
                for ivS in 10...15 {
                    guard let cp = calculateCPOf(pokemon, atLvl: level, withIVs: (Double(ivA), Double(ivD), Double(ivS))) else {
                        return nil
                    }
                    cpRange["\(ivA-10)\(ivD-10)\(ivS-10)"] = cp
                }
            }
        }
        // zuerst die ungerundeten CP sortieren und anschließend mit floor abrunden
        return cpRange.sorted(by: { $0.1 > $1.1 }).map { ($0.key,Int(floor($0.value))) }
        //return cpRange.sorted(by: { digitSum(Int($0.0)!) == digitSum(Int($1.0)!) ? $0.1 > $1.1 : digitSum(Int($0.0)!) > digitSum(Int($1.0)!) }) //sorted by IV%
    }
    
    // calculate cps at lvl x and lvl x+5 in range 10/10/10 to 15/15/15, check possible returns (by cp, by perfection)
    func calculateCPRangeOfRaid(_ pokemon: String, atLvl level: Int) -> [(key: String, value: (Int,Int))]? {
        //Format is [<IV-String>:(Lv20CP,Lv25CP)]
        var cpRange: [String : (Double,Double)] = [:]
        
        for ivA in 10...15 {
            for ivD in 10...15 {
                for ivS in 10...15 {
                    guard let lv20cp = calculateCPOf(pokemon, atLvl: level, withIVs: (Double(ivA), Double(ivD), Double(ivS))),
                        let lv25cp = calculateCPOf(pokemon, atLvl: level+5 > 40 ? 40 : level+5, withIVs: (Double(ivA), Double(ivD), Double(ivS))) else {
                        return nil
                    }
                    cpRange["\(ivA-10)\(ivD-10)\(ivS-10)"] = (lv20cp,lv25cp)
                }
            }
        }
        // zuerst die ungerundeten CP sortieren und anschließend mit floor abrunden
        return cpRange.sorted(by: { $0.1.0 > $1.1.0 }).map { ($0.key,(Int(floor($0.value.0)),Int(floor($0.value.1)))) } // sorted by CP
        //return cpRange.sorted(by: { digitSum(Int($0.0)!) == digitSum(Int($1.0)!) ? $0.1 > $1.1 : digitSum(Int($0.0)!) > digitSum(Int($1.0)!) }) //sorted by IV%
    }
    
    // print formatted rows for latex tables
    func latex_printCPRangeOf(_ pokemon: String, atLvl level: Int, withNumberOfValues valueCount: Double) {
        guard let list = calculateCPRangeOfRaid(pokemon, atLvl: level) else {
            return
        }
        
        var ivString: String
        var ivAStr: String
        var ivDStr: String
        var ivSStr: String
        var perfection: Double
        
        for (m,ivCP) in list.enumerated() where m<Int(valueCount-1) {
            ivString = ivCP.key
            ivAStr = String(ivString.prefix(1))
            ivSStr = String(ivString.suffix(1))
            ivString.removeFirst()
            ivString.removeLast()
            ivDStr = ivString
            perfection = Double(round(10*(Double(digitSum(Int(ivAStr+ivDStr+ivSStr)!)+30)*100/45))/10)
            print("\\rowcolor{color\(defineColorCounter)}")
            defineColorCounter += 1
            print("\(ivCP.value.0) &\(ivCP.value.1) &1\(ivAStr) 1\(ivDStr) 1\(ivSStr) &\(perfection) \\\\")
        }
        // last entry of table are the worst stats at 66.7% perfection
        print("\\midrule")
        print("\\rowcolor{color\(defineColorCounter)}")
        defineColorCounter += 1
        let lastEntry = list.last!
        ivString = lastEntry.key
        ivAStr = String(ivString.prefix(1))
        ivSStr = String(ivString.suffix(1))
        ivString.removeFirst()
        ivString.removeLast()
        ivDStr = ivString
        print("\(lastEntry.value.0) &\(lastEntry.value.1) &1\(ivAStr) 1\(ivDStr) 1\(ivSStr) &\(66.7) \\\\")
    }
    
    // TODO: RGB Color Counter is missing -> fix it
    func latex_printRGBColorTransitionFrom(_ color1: (r: Double, g: Double, b: Double),
                                           to color2: (r: Double, g: Double, b: Double),
                                           withSteps steps: Double) {
        let singleStepForR = (color2.r-color1.r)/steps
        let singleStepForG = (color2.g-color1.g)/steps
        let singleStepForB = (color2.b-color1.b)/steps
        
        var newR: Int
        var newG: Int
        var newB: Int
        for i in 1...Int(steps)+1 {
            newR = Int(round(color1.r + singleStepForR*Double(i-1)))
            newG = Int(round(color1.g + singleStepForG*Double(i-1)))
            newB = Int(round(color1.b + singleStepForB*Double(i-1)))
            print("\\definecolor{color\(i)}{RGB}{\(newR),\(newG),\(newB)}")
        }
    }
    
    func latex_printHSBColorTransitionFrom(_ color1: (h: Double, s: Double, b: Double),
                                           to color2: (h: Double, s: Double, b: Double),
                                           withSteps steps: Double) {
        let singleStepForH = (color2.h-color1.h)/steps
        let singleStepForS = (color2.s-color1.s)/steps
        let singleStepForB = (color2.b-color1.b)/steps
        
        var newH: Double
        var newS: Double
        var newB: Double
        for i in 1...Int(steps)+1 {
            newH = color1.h + singleStepForH*Double(i-1)
            if newH < 0 {
                newH += 1
            }
            newS = color1.s + singleStepForS*Double(i-1)
            newB = color1.b + singleStepForB*Double(i-1)
            print("\\xdefinecolor{color\(rowColorCounter)}{hsb}{\(newH),\(newS),\(newB)}")
            rowColorCounter += 1
        }
    }
    
    public func createLatexSingleCPTableFor(_ pokemon: String,
                                            atLvl level: Int,
                                            withValueCount: Int,
                                            withColorTransition transition: HSBColorTransition) {
        
        let latexConstructs = DHLatexConstructs(pokemon: [pokemon], level: [level])
        
        print(latexConstructs.documentHeader)
        latex_printHSBColorTransitionFrom(transition.color1, to: transition.color2, withSteps: Double(withValueCount-1))
        print(latexConstructs.singleTableHeader)
        
        latex_printCPRangeOf(pokemon, atLvl: level, withNumberOfValues: Double(withValueCount))
        print("""
            %\\bottomrule
            \\end{tabular}}
            \\centering
            \\scriptsize{\(version) \\\\ \(realName) \\\\ \(redditName)}
            \\end{table}
            \\end{document}
        """)
    }
    
    public func createLatexDoubleCPTableFor(pokemon1 poke1: String,
                                            withTransition1 trans1: HSBColorTransition,
                                            pokemon2 poke2: String,
                                            withTransition2 trans2: HSBColorTransition,
                                            atLvl level: Int,
                                            withValueCount: Int) {
        
        let latexConstructs = DHLatexConstructs(pokemon: [poke1 + "+" + poke2], level: [level])
        
        print(latexConstructs.documentHeader)
        
        latex_printHSBColorTransitionFrom(trans1.color1, to: trans1.color2, withSteps: Double(withValueCount-1))
        latex_printHSBColorTransitionFrom(trans2.color1, to: trans2.color2, withSteps: Double(withValueCount-1))
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
    }
    
    public func createLatexTripleCPTableFor(pokemon1 poke1: String,
                                            withTransition1 trans1: HSBColorTransition,
                                            pokemon2 poke2: String,
                                            withTransition2 trans2: HSBColorTransition,
                                            pokemon3 poke3: String,
                                            withTransition3 trans3: HSBColorTransition,
                                            atLvl level: Int,
                                            withValueCount: Int) {
        
        print("""
            \\documentclass[10pt,a4paper]{article}
            \\usepackage[latin1]{inputenc}
            \\usepackage[german]{babel}
            \\usepackage[T1]{fontenc}
            \\usepackage{caption}
            
            \\pdfinfo{
            /Author (Dimitri Haas)
            /Title  (\(poke1)+\(poke2)+\(poke3) CP Table)
            }
            
            \\usepackage{booktabs}
            \\usepackage{colortbl}
            \\usepackage{siunitx}
            \\usepackage{tcolorbox}
            \\usepackage{geometry}
            \\geometry{
            left=1.5cm,
            right=1.5cm,
            }
            
            \\author{Dimitri Haas}
            \\title{\(poke1)+\(poke2)+\(poke3) CP Table}
            \\begin{document}
            \\pagenumbering{gobble}
            \\tcbset{fonttitle=\\bfseries,center title}
            """)
        
        latex_printHSBColorTransitionFrom(trans1.color1, to: trans1.color2, withSteps: Double(withValueCount-1))
        latex_printHSBColorTransitionFrom(trans2.color1, to: trans2.color2, withSteps: Double(withValueCount-1))
        latex_printHSBColorTransitionFrom(trans3.color1, to: trans3.color2, withSteps: Double(withValueCount-1))
        print("""
            \\begin{table}[!htb]
            %\\caption*{Global caption}
            \\begin{minipage}{.33\\linewidth}
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
            \\begin{minipage}{.33\\linewidth}
            \\centering
            \\includegraphics[height=3cm]{poke2.png}
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
            \\end{minipage}%
            \\begin{minipage}{.33\\linewidth}
            \\centering
            \\includegraphics[height=3cm]{poke3.png}
            \\tcbox[left=0.5mm,right=0.5mm,top=1.5mm,bottom=0.5mm,boxsep=0mm,
            toptitle=1mm,bottomtitle=1mm,title=\(poke3.uppercased()),fonttitle=\\large\\bfseries]{
            \\begin{tabular}{cccS[table-format=3.1]}
            \\multicolumn{2}{c}{\\textbf{CP}}    \\\\
            \\cmidrule(rl){1-2}
            Lv\(level) &Lv\(level+5 > 40 ? 40 : level+5)    &\\textbf{IVs}     &\\textbf{\\%} \\\\
            \\midrule
            """)
        latex_printCPRangeOf(poke3, atLvl: level, withNumberOfValues: Double(withValueCount))
        
        print("""
            %\\bottomrule
            \\end{tabular}}
            \\end{minipage}
            \\centering
            \\scriptsize{\(version) \\\\ \(realName) \\\\ \(redditName)}
            \\end{table}
            \\end{document}
        """)
    }
}

public struct HSBColorTransition {
    public init() {}
    public init(color1: (h: Double, s: Double, b: Double), color2: (h: Double, s: Double, b: Double)) {
        self.color1 = color1
        self.color2 = color2
    }
    var color1 = (0.0,0.0,0.0)
    var color2 = (0.0,0.0,0.0)
    var name = ""
}
