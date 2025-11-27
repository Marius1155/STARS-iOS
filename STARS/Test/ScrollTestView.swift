//
//  ScrollTestView.swift
//  STARS
//
//  Created by Marius Gabriel Budai on 25.08.2025.
//

import SwiftUI

struct ScrollTestView: View {
    @State private var things: [Int] = []
    @State private var smallestNumber: Int = -1
    var body: some View {
        ScrollView {
            LazyVStack {
                ProgressView()
                    .onAppear {
                        var newThings: [Int] = []
                        for i in stride(from: smallestNumber, through: smallestNumber-40, by: -1) {
                            newThings.append(i)
                        }
                        smallestNumber -= 40
                        things.insert(contentsOf: newThings, at: 0)
                    }
                
                ForEach(Array(things.enumerated()), id: \.offset) { index, thing in
                    Text("\(thing) with index \(index)")
                }
                
                ProgressView()
                    .onAppear {
                        var newThings: [Int] = []
                        for i in 1 ..< 40 {
                            newThings.append(i)
                        }
                        things += newThings
                    }
            }
        }
        .onAppear {
            things = Array.init(repeating: 0, count: 40)
        }
    }
}

#Preview {
    ScrollTestView()
}
