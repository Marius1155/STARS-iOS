//
//  ContributeView.swift
//  STARS
//
//  Created by Marius Gabriel Budăi on 27.08.2024.
//

import SwiftUI

struct ContributeView: View {
    @EnvironmentObject var dataManager: DataManager
    
    var body: some View {
        Text("Contribute")
    }
}

#Preview {
    ContributeView()
        .environmentObject(DataManager())
}
