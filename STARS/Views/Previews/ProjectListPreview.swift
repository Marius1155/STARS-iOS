//
//  ProjectListPreview.swift
//  STARS
//
//  Created by Marius Gabriel Budai on 23.10.2025.
//

import SwiftUI
import STARSAPI
import SDWebImageSwiftUI

struct ProjectListPreview: View {
    let id: String
    let title: String
    let releaseDate: String
    let coverUrl: String
    let artistsNames: String
    let trackCount: Int
    let isSingle: Bool
    
    var body: some View {
        HStack {
            let url = formattedArtworkUrl(from: coverUrl, width: 300, height: 300)

            WebImage(url: URL(string: url))
                .resizable()
                .frame(width: 100, height: 100)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .shadow(radius: 2)
            
            VStack(alignment: .leading) {
                let combinedText = Text(Image(systemName: "opticaldisc.fill")) + Text(" \(title)")

                combinedText
                    .bold()
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                    .truncationMode(.tail)
                
                Text("\(artistsNames) • \((stringToDate(releaseDate) ?? Foundation.Date()).formatted(.dateTime.year()))")
                    .foregroundStyle(.gray)
                    .lineLimit(2)
                    .truncationMode(.tail)
            }
            .padding(.leading, 4)
            
            Spacer()
        }
        .padding(.horizontal)
    }
    
    func formattedArtworkUrl(from template: String, width: Int = 600, height: Int = 600) -> String {
        return template
            .replacingOccurrences(of: "{w}", with: "\(width)")
            .replacingOccurrences(of: "{h}", with: "\(height)")
    }
    
    func stringToDate(_ dateString: String) -> Foundation.Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.date(from: dateString)
    }
}

#Preview {
    ProjectListPreview(id: "1807308262", title: "PRINCESS OF POWER", releaseDate: "2025-06-06", coverUrl: "https://is1-ssl.mzstatic.com/image/thumb/Music221/v4/a5/c6/67/a5c667cc-c8ac-cec4-ef32-146488dbcede/4099964156188.jpg/{w}x{h}bb.jpg", artistsNames: "MARINA", trackCount: 13, isSingle: false)
}
