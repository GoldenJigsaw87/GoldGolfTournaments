//
//  CurrentHole.swift
//  Gold Golf Turnoments
//
//  Created by Mark Jensen on 3/6/26.
//

import SwiftUI
import Foundation

struct HoleScore: Identifiable {
    let id = UUID()
    var hole: Int
    var par: Int
    var playerScores: [Int]
}
struct CurrentHole: View {
    var body: some View {
        Text("Current hole")
    }
}

#Preview {
    CurrentHole()
}
