//
//  FriendsList.swift
//  Gold Golf Turnoments
//
//  Created by Mark Jensen on 3/6/26.
//

import SwiftUI

struct FriendsList: View {
    @State private var friends: [User_DEP] = []
    
    var body: some View {
        List(friends) { friend in
            Text(friend.username)
        }
        .onAppear {
            APIService.shared.getFriends(userID: "USER_ID_HERE") { fetched in
                DispatchQueue.main.async {
                    self.friends = fetched
                }
            }
        }
    }
}
