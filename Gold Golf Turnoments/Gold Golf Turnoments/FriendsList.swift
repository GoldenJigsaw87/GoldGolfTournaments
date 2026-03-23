//
//  FriendsList.swift
//  Gold Golf Turnoments
//
//  Created by Mark Jensen on 3/6/26.
//

import SwiftUI

struct FriendsView: View {

    var friends = [
        ("Tommy", 86, "+2"),
        ("Jake", 74, "-1"),
        ("Ryan", 92, "+6")
    ]

    var body: some View {

        VStack {

            Text("Friends")
                .font(.largeTitle)

            List {

                HStack {
                    Text("Name")
                    Spacer()
                    Text("Holes Played")
                    Spacer()
                    Text("Under/Over")
                }

                ForEach(friends, id:\.0) { friend in

                    HStack {
                        Text(friend.0)
                        Spacer()
                        Text("\(friend.1)")
                        Spacer()
                        Text(friend.2)
                    }
                }
            }
        }
    }
}
