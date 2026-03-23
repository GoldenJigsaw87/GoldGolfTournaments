//
//  CardBuilder.swift
//  Gold Golf Turnoments
//
//  Created by Mark Jensen on 3/6/26.
//

import SwiftUI

struct CardBuilderView: View {

    @State private var holes = 18
    @State private var players = 2
    @State private var courseName = ""

    var body: some View {

        VStack(spacing: 20) {

            Text("Card Builder")
                .font(.title)

            TextField("Course Name", text: $courseName)
                .textFieldStyle(.roundedBorder)

            Stepper("Holes: \(holes)", value: $holes, in: 1...18)

            Stepper("Players: \(players)", value: $players, in: 1...4)

            NavigationLink("Start Scorecard") {
                ScorecardView()
            }

            Spacer()
        }
        .padding()
    }
}
