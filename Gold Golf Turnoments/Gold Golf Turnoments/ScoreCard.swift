//
//  ScoreCard.swift
//  Gold Golf Turnoments
//
//  Created by Mark Jensen on 2/3/26.
//

import SwiftUI

struct ScorecardView: View {

    @State private var scores: [HoleScore] = (1...18).map {
        HoleScore(hole: $0, par: 4, playerScores: [0,0])
    }

    var body: some View {

        VStack {

            Text("Course Name")
                .font(.title)

            ScrollView {

                VStack {

                    HStack {
                        Text("Hole").frame(width: 40)
                        Text("Par").frame(width: 40)
                        Text("P1").frame(width: 110)
                        Text("P2").frame(width: 110)
                    }
                    .font(.headline)

                    Divider()

                    ForEach($scores) { $hole in

                        HStack {
                            Text("\(hole.hole)")
                                .frame(width: 40)

                            Text("\(hole.par)")
                                .frame(width: 40)

                            Stepper("", value: $hole.playerScores[0], in: 0...15)
                                .frame(width: 80)

                            Text("\(hole.playerScores[0])")
                                .frame(width: 30)

                            Stepper("", value: $hole.playerScores[1], in: 0...15)
                                .frame(width: 80)

                            Text("\(hole.playerScores[1])")
                                .frame(width: 30)
                        

                        }
                        .padding(.vertical,5)
                    }

                }
                .padding()
            }
        }
    }
}
