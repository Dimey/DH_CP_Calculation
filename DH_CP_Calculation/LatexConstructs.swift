//
//  LatexConstructs.swift
//  DH_CP_Calculation
//
//  Created by Dimitri Haas on 01.06.18.
//  Copyright © 2018 Dimitri Haas. All rights reserved.
//

import Foundation

struct LatexConstructs {
    var pokemon = ""
    var level = 1
    var documentHeader: String {
        get {
            return """
                \\documentclass[10pt,a4paper]{article}
                \\usepackage[latin1]{inputenc}
                \\usepackage[german]{babel}
                \\usepackage[T1]{fontenc}
                \\usepackage{caption}
            
                \\pdfinfo{
                /Author (Dimitri Haas)
                /Title  (\(pokemon) CP Table)
                }
            
                \\usepackage{booktabs}
                \\usepackage{colortbl}
                \\usepackage{siunitx}
                \\usepackage{tcolorbox}
                \\renewcommand{\\familydefault}{\\sfdefault}
            
                \\author{Dimitri Haas}
                \\title{\(pokemon) CP Table}
                \\begin{document}
                \\pagenumbering{gobble}
                \\tcbset{fonttitle=\\bfseries,center title}
            """
        }
    }
    var singleTableHeader: String {
        get {
           return """
            \\begin{table}
            \\centering
            \\includegraphics[height=3cm]{poke1}
            \\tcbox[left=0.5mm,right=0.5mm,top=1.5mm,bottom=0.5mm,boxsep=0mm,toptitle=1mm,bottomtitle=1mm,title=\(pokemon.uppercased()),fonttitle=\\large\\bfseries]{
            \\begin{tabular}{cccS[table-format=3.1]}
            \\multicolumn{2}{c}{\\textbf{CP}}    \\\\
            \\cmidrule(rl){1-2}
            Lv\(level) &Lv\(level+5 > 40 ? 40 : level+5)    &\\textbf{IVs}     &\\textbf{\\%} \\\\
            \\midrule
            """
        }
    }
    var doubleTableHeader: String {
        get {
            let poke1 = pokemon.components(separatedBy: "+")[0]
            let poke2 = pokemon.components(separatedBy: "+")[1]
            return """
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
            """
        }
    }
    
}
