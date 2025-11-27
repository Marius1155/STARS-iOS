import SwiftUI
import STARSAPI

struct ProjectArtistNameView: View {
    var artistsIDs: [String]
    var linkToArtists = false
    @State private var artistsNames: [String]

    init(artistsIDs: [String], linkToArtists: Bool = false) {
        self.artistsIDs = artistsIDs
        self.linkToArtists = linkToArtists
        _artistsNames = State(initialValue: Array(repeating: "", count: artistsIDs.count))
    }

    var body: some View {
        HStack(spacing: 0) {
            if linkToArtists {
                ForEach(Array(artistsIDs.enumerated()), id: \.offset) { index, id in
                    NavigationLink {
                        ArtistDetailView(artistID: id)
                    } label: {
                        Text(artistsNames[index])
                    }
                    
                    if index < artistsIDs.count - 2 {
                        Text(", ")
                    }
                    
                    else if index == artistsIDs.count - 2 {
                        Text(" & ")
                    }
                }
            } else {
                ForEach(Array(artistsIDs.enumerated()), id: \.offset) { index, id in
                    Text(artistsNames[index])
                    
                    if index < artistsIDs.count - 2 {
                        Text(", ")
                    }
                    
                    else if index == artistsIDs.count - 2 {
                        Text(" & ")
                    }
                }
                .lineLimit(1)
                .truncationMode(.tail)
                .font(.caption)
            }
        }
        .onAppear {
            for (index, id) in artistsIDs.enumerated() {
                fetchArtistName(artistID: id) { name in
                    DispatchQueue.main.async {
                        if index < artistsNames.count {
                            artistsNames[index] = name
                        }
                    }
                }
            }
        }
    }
    
    private func fetchArtistName(artistID: String, completion: @escaping (String) -> Void) {
        Network.shared.apollo.fetch(query: STARSAPI.GetArtistNameQuery(id: String(artistID))) { result in
            switch result {
            case .success(let graphQLResult):
                if let fetched = graphQLResult.data?.artists.edges.first?.node {
                    completion(fetched.name)
                }
            case .failure(let error):
                print("Error loading project: \(error)")
                completion("Error")
            }
        }
    }
}

#Preview {
    ProjectArtistNameView(artistsIDs: ["1", "2"], linkToArtists: true)
}
