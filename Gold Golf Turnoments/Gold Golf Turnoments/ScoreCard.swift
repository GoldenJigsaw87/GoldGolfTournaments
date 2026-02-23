//
//  ScoreCard.swift
//  Gold Golf Turnoments
//
//  Created by Mark Jensen on 2/3/26.
//

struct ScorecardView: View {
    
    @ObservedObject var leaderboardVM: LeaderboardViewModel
    @StateObject var scoreVM: ScorecardViewModel
    
    init(leaderboardVM: LeaderboardViewModel, player: Player) {
        self.leaderboardVM = leaderboardVM
        _scoreVM = StateObject(
            wrappedValue: ScorecardViewModel(
                leaderboardVM: leaderboardVM,
                player: player
            )
        )
    }
    
    var body: some View {
        VStack(spacing: 20) {
            
            Text("Hole \(scoreVM.currentHole.number)")
                .font(.largeTitle)
            
            // PAR EDITOR
            Stepper(
                "Par: \(scoreVM.currentHole.par)",
                value: Binding(
                    get: { scoreVM.currentHole.par },
                    set: { scoreVM.updatePar(for: scoreVM.currentHoleIndex, par: $0) }
                ),
                in: 3...6
            )
            .padding()
            
            // STROKE INPUT
            Stepper("Strokes: \(scoreVM.currentStrokes)",
                    value: $scoreVM.currentStrokes,
                    in: 1...12)
                .padding()
            
            // Submit Score Button
            Button(action: scoreVM.submitScore) {
                Text(scoreVM.isLastHole ? "Finish Round" : "Save & Next Hole")
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .navigationTitle(scoreVM.player.name)
        .padding()
    }
}
