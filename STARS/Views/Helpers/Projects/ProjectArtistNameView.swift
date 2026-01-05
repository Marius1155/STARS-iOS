import SwiftUI
import STARSAPI

struct ProjectArtistNameView: View {
    let artists: [(id: String, name: String, position: Int)]
    var linkToArtists: Bool = false

    var body: some View {
        HStack(spacing: 0) {
            if linkToArtists {
                ForEach(artists.sorted { $0.position < $1.position }, id: \.id) { artist in
                    NavigationLink {
                        ArtistDetailView(artistID: artist.id)
                    } label: {
                        Text(artist.name)
                    }
                    
                    if artist.position < artists.count - 2 {
                        Text(", ")
                    }
                    
                    else if artist.position == artists.count - 2 {
                        Text(" & ")
                    }
                }
            } else {
                ForEach(artists.sorted { $0.position < $1.position }, id: \.id) { artist in
                    Text(artist.name)
                    
                    if artist.position < artists.count - 2 {
                        Text(", ")
                    }
                    
                    else if artist.position == artists.count - 2 {
                        Text(" & ")
                    }
                }
                .lineLimit(1)
                .truncationMode(.tail)
                .font(.caption)
            }
        }
    }
}

#Preview {
    ProjectArtistNameView(artists: [(id: "1", name: "Charli xcx", position: 1)])
}
