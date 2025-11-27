//
//  DataManager.swift
//  STARS
//
//  Created by Marius Gabriel Budăi on 27.08.2024.
//

import Foundation
import Apollo
import Combine
import STARSAPI
import SwiftUI

extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if hexSanitized.count != 7 {
            return nil
        }
        
        if hexSanitized.first! != "#" {
            return nil
        }
            
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)

        let red = Double((rgb >> 16) & 0xFF) / 255.0
        let green = Double((rgb >> 8) & 0xFF) / 255.0
        let blue = Double(rgb & 0xFF) / 255.0

        self.init(red: red, green: green, blue: blue)
    }
}

@Observable
@MainActor
class DataManager {
    static let shared = DataManager()
    
    var shouldShowTabBar: Bool = true
    var accentColor: Color = .white
    
    private init() {} 
}
    
    /*@Published var project: GetProjectDetailQuery.Data.Project?

        func fetchProjectDetail(id: Int) {
            Network.shared.apollo.fetch(query: GetProjectDetailQuery(id: id)) { result in
                switch result {
                case .success(let graphQLResult):
                    DispatchQueue.main.async {
                        self.project = graphQLResult.data?.project
                    }
                case .failure(let error):
                    print("GraphQL error: \(error)")
                }
            }
        }*/
    
    /*
    func fetchProfileWithGivenUserID(userID: String, completion: @escaping (Profile?) -> Void) {
        let db = Firestore.firestore()
        let ref = db.collection("Profile").document(userID)
        
        ref.getDocument { snapshot, error in
            guard error == nil else {
                print(error!.localizedDescription)
                completion(nil)
                return
            }
            
            if let snapshot = snapshot, let data = snapshot.data() {
                let id = snapshot.documentID
                let birthdateTimestamp = data["birthdate"] as? Timestamp
                let birthdate: Date = birthdateTimestamp?.dateValue() ?? Date()
                let bannerPicture = data["bannerPicture"] as? String ?? ""
                let bio = data["bio"] as? String ?? ""
                let email = data["email"] as? String ?? ""
                let name = data["name"] as? String ?? ""
                let hasPremium = data["hasPremium"] as? Bool ?? false
                let isAdmin = data["isAdmin"] as? Bool ?? false
                let accentColorHex = data["accentColorHex"] as? String ?? ""
                let profilePicture = data["profilePicture"] as? String ?? ""
                let pronouns = data["pronouns"] as? String ?? ""
                let tag = data["tag"] as? String ?? ""
                let followingCount = data["followingCount"] as? Int ?? 0
                let followersCount = data["followersCount"] as? Int ?? 0
                let projectReviewsCount = data["projectReviewsCount"] as? Int ?? 0
                let projectCoverReviewsCount = data["projectCoverReviewsCount"] as? Int ?? 0
                let songReviewsCount = data["songReviewsCount"] as? Int ?? 0
                let musicVideoReviewsCount = data["musicVideoReviewsCount"] as? Int ?? 0
                let podcastReviewsCount = data["podcastReviewsCount"] as? Int ?? 0
                let podcastCoverReviewsCount = data["podcastCoverReviewsCount"] as? Int ?? 0
                let movieReviewsCount = data["movieReviewsCount"] as? Int ?? 0
                let movieCoverReviewsCount = data["movieCoverReviewsCount"] as? Int ?? 0
                let seriesReviewsCount = data["seriesReviewsCount"] as? Int ?? 0
                let seriesCoverReviewsCount = data["seriesCoverReviewsCount"] as? Int ?? 0
                let outfitReviewsCount = data["outfitReviewsCount"] as? Int ?? 0

                let profile = Profile(
                    id: id,
                    tag: tag,
                    hasPremium: hasPremium,
                    bannerPicture: bannerPicture,
                    profilePicture: profilePicture,
                    email: email,
                    name: name,
                    birthdate: birthdate,
                    bio: bio,
                    pronouns: pronouns,
                    isAdmin: isAdmin,
                    accentColorHex: accentColorHex,
                    followersCount: followersCount,
                    followers: [],
                    followingCount: followingCount,
                    following: [],
                    projectReviewsCount: projectReviewsCount,
                    projectCoverReviewsCount: projectCoverReviewsCount,
                    songReviewsCount: songReviewsCount,
                    musicVideoReviewsCount: musicVideoReviewsCount,
                    podcastReviewsCount: podcastReviewsCount,
                    podcastCoverReviewsCount: podcastCoverReviewsCount,
                    movieReviewsCount: movieReviewsCount,
                    movieCoverReviewsCount: movieCoverReviewsCount,
                    seriesReviewsCount: seriesReviewsCount,
                    seriesCoverReviewsCount: seriesCoverReviewsCount,
                    outfitReviewsCount: outfitReviewsCount,
                    projectReviews: [],
                    projectCoverReviews: [],
                    songReviews: [],
                    musicVideoReviews: [],
                    podcastReviews: [],
                    podcastCoverReviews: [],
                    movieReviews: [],
                    movieCoverReviews: [],
                    seriesReviews: [],
                    seriesCoverReviews: [],
                    outfitReviews: [])

                completion(profile)
            } else {
                completion(nil)
            }
        }
    }
    
    func fetchProfiles(startingWith text: String, lastDocument: DocumentSnapshot?, limit: Int = 50, completion: @escaping ([String], DocumentSnapshot?) -> Void) {
        let db = Firestore.firestore()
        
        var query = db.collection("Profile")
            .whereFilter(Filter.orFilter([
                Filter.andFilter([
                    Filter.whereField("name", isGreaterOrEqualTo: text),
                    Filter.whereField("name", isLessThan: text + "\u{f8ff}")
                ]),
                Filter.andFilter([
                    Filter.whereField("tag", isGreaterOrEqualTo: text),
                    Filter.whereField("tag", isLessThan: text + "\u{f8ff}")
                ])
            ]))
            .limit(to: limit)
        
        if let lastDocument = lastDocument {
            query = query.start(afterDocument: lastDocument)
        }
        
        query.getDocuments { snapshot, error in
            guard let documents = snapshot?.documents, error == nil else {
                print("Error fetching profiles: \(error?.localizedDescription ?? "Unknown error")")
                completion([], nil)
                return
            }
            
            var profileIDs: [String] = []
            var newLastDocument: DocumentSnapshot? = nil
            
            for document in documents {
                let data = document.data()
                let id = document.documentID
                profileIDs.append(id)
                newLastDocument = document
            }
            
            completion(profileIDs, newLastDocument)
        }
    }

    func fetchProfilesCarelesslyLikeYouDontHaveAWorryInTheWorldAndUsersToSatisfy(completion: @escaping ([String]) -> Void) {
        let db = Firestore.firestore()
        
        var query = db.collection("Profile")
        
        query.getDocuments(source: .default) { snapshot, error in
            guard let documents = snapshot?.documents, error == nil else {
                print("Error fetching profiles: \(error?.localizedDescription ?? "Unknown error")")
                print("girlll, likeee, smth is wrooong wrong")
                completion([])
                return
            }
            
            var profileIDs: [String] = []
            
            for document in documents {
                let data = document.data()
                let id = document.documentID
                profileIDs.append(id)
            }
            
            completion(profileIDs)
            print("you did THAT")
        }
    }
    
    func createNewProfile(userID: String, email: String, tag: String, pronouns: String, completion: @escaping ()-> Void) {
        let db = Firestore.firestore()
        let ref = db.collection("Profile").document(userID)
        let documentID = ref.documentID
        ref.setData(["tag": tag, "hasPremium": false, "bannerPicture": "", "profilePicture": "", "email": email, "name": "", "birthdate": Date(), "bio": "", "pronouns": pronouns, "isAdmin": false, "projectReviews": [], "projectCoverReviews": [], "songReviews": [], "musicVideoReviews": [], "podcastReviews": [], "movieReviews": [], "seriesReviews": [], "outfitReviews": []]) { error in
            if let error = error {
                print(error.localizedDescription)
            }
        }
        completion()
    }
    
    func fetchFeaturedProjects(completion: @escaping ([Project]) -> Void) {
        let db = Firestore.firestore()
        let ref = db.collection("Project").whereField("isFeatured", isEqualTo: true)
        ref.getDocuments { snapshot, error in
            guard error == nil else {
                print(error!.localizedDescription)
                completion([])
                return
            }
            
            var projects: [Project] = []
            if let snapshot = snapshot {
                for document in snapshot.documents {
                    let data = document.data()
                    let id = document.documentID
                    let title = data["title"] as? String ?? ""
                    let artist = data["artist"] as? [String] ?? []
                    let numberOfSongs = data["numberOfSongs"] as? Int ?? 0
                    let releaseDateTimestamp = data["releaseDate"] as? Timestamp
                    let releaseDate = releaseDateTimestamp?.dateValue() ?? Date()
                    let type = data["type"] as? Int ?? 0
                    let songs = data["songs"] as? [String] ?? []
                    let cover = data["cover"] as? [String] ?? []
                    let length = data["length"] as? Int ?? 0
                    let reviewsCount = data["reviewsCount"] as? Int ?? 0
                    let starAverage = data["starAverage"] as? Double ?? 0
                    let alternativeVersions = data["alternativeVersions"] as? [String] ?? []
                    let movies = data["movies"] as? [String] ?? []
                    let series = data["series"] as? [String] ?? []
                    let isFeatured = data["isFeatured"] as? Bool ?? false
                    
                    let project = Project(id: id, title: title, artist: artist, numberOfSongs: numberOfSongs, releaseDate: releaseDate, type: type, songs: songs, cover: cover, length: length, reviews: [], reviewsCount: reviewsCount, starAverage: starAverage, alternativeVersions: alternativeVersions, movies: movies, series: series, isFeatured: isFeatured)
                    
                    projects.append(project)
                }
            }
            completion(projects)
        }
    }
    
    func fetchProjectWithGivenID(projectID: String, completion: @escaping (Project?) -> Void) {
        let db = Firestore.firestore()
        let ref = db.collection("Project").document(projectID)
        ref.getDocument { snapshot, error in
            guard error == nil else {
                print(error!.localizedDescription)
                completion(nil)
                return
            }
          
            if let snapshot = snapshot {
                let data = snapshot.data() ?? [:]
                let id = snapshot.documentID
                let title = data["title"] as? String ?? ""
                let artist = data["artist"] as? [String] ?? []
                let numberOfSongs = data["numberOfSongs"] as? Int ?? 0
                let releaseDateTimestamp = data["releaseDate"] as? Timestamp
                let releaseDate = releaseDateTimestamp?.dateValue() ?? Date()
                let type = data["type"] as? Int ?? 0
                let songs = data["songs"] as? [String] ?? []
                let cover = data["cover"] as? [String] ?? []
                let length = data["length"] as? Int ?? 0
                let reviewsCount = data["reviewsCount"] as? Int ?? 0
                let starAverage = data["starAverage"] as? Double ?? 0
                let alternativeVersions = data["alternativeVersions"] as? [String] ?? []
                let movies = data["movies"] as? [String] ?? []
                let series = data["series"] as? [String] ?? []
                let isFeatured = data["isFeatured"] as? Bool ?? false
                
                let project = Project(id: id, title: title, artist: artist, numberOfSongs: numberOfSongs, releaseDate: releaseDate, type: type, songs: songs, cover: cover, length: length, reviews: [], reviewsCount: reviewsCount, starAverage: starAverage, alternativeVersions: alternativeVersions, movies: movies, series: series, isFeatured: isFeatured)
                
                completion(project)
            }
        }
    }
    
    func fetchAProjectsReviewsInfo(project: Project, completion: @escaping (Project) -> Void) {
        var newProject = project
        let db = Firestore.firestore()
        let ref = db.collection("Project").document(project.id!).getDocument { snapshot, error in
            guard error == nil else {
                print(error!.localizedDescription)
                completion(newProject)
                return
            }
            
            if let snapshot = snapshot {
                let data = snapshot.data() ?? [:]
                
                let reviewsCount = data["reviewsCount"] as? Int ?? 0
                let starAverage = data["starAverage"] as? Double ?? 0
                
                newProject.reviewsCount = reviewsCount
                newProject.starAverage = starAverage
                
            }
            completion(newProject)
        }
    }

    func fetchFeaturedMusicVideos(completion: @escaping ([MusicVideo]) -> Void) {
        let db = Firestore.firestore()
        let ref = db.collection("MusicVideo").whereField("isFeatured", isEqualTo: true)
        ref.getDocuments { snapshot, error in
            guard error == nil else {
                print(error!.localizedDescription)
                completion([])
                return
            }
            
            var musicVideos: [MusicVideo] = []
            if let snapshot = snapshot {
                for document in snapshot.documents {
                    let data = document.data()
                    let id = document.documentID
                    let songs = data["songs"] as? [String] ?? []
                    let releaseDateTimestamp = data["releaseDate"] as? Timestamp
                    let releaseDate = releaseDateTimestamp?.dateValue() ?? Date()
                    let youtube = data["youtube"] as? String ?? ""
                    let reviewsCount = data["reviewsCount"] as? Int ?? 0
                    let starAverage = data["starAverage"] as? Double ?? 0
                    let outfits = data["outfits"] as? [String] ?? []
                    let isFeatured = data["isFeatured"] as? Bool ?? false
                    
                    let musicVideo = MusicVideo(id: id, songs: songs, releaseDate: releaseDate, youtube: youtube, reviews: [], reviewsCount: reviewsCount, starAverage: starAverage, outfits: outfits, isFeatured: isFeatured)
                    
                    musicVideos.append(musicVideo)
                }
            }
            completion(musicVideos)
        }
    }

    func fetchFeaturedPodcasts(completion: @escaping ([Podcast]) -> Void) {
        let db = Firestore.firestore()
        let ref = db.collection("Podcast").whereField("isFeatured", isEqualTo: true)
        ref.getDocuments { snapshot, error in
            guard error == nil else {
                print(error!.localizedDescription)
                completion([])
                return
            }
            
            var podcasts: [Podcast] = []
            if let snapshot = snapshot {
                for document in snapshot.documents {
                    let data = document.data()
                    let id = document.documentID
                    let title = data["title"] as? String ?? ""
                    let by = data["by"] as? String ?? ""
                    let hosts = data["hosts"] as? [String] ?? []
                    let sinceTimestamp = data["since"] as? Timestamp
                    let since = sinceTimestamp?.dateValue() ?? Date()
                    let covers = data["covers"] as? [String] ?? []
                    let website = data["website"] as? String ?? ""
                    let reviewsCount = data["reviewsCount"] as? Int ?? 0
                    let starAverage = data["starAverage"] as? Double ?? 0
                    let sequels = data["sequels"] as? [String] ?? []
                    let isFeatured = data["isFeatured"] as? Bool ?? false
                    
                    let podcast = Podcast(id: id, title: title, by: by, hosts: hosts, since: since, covers: covers, website: website, reviews: [], reviewsCount: reviewsCount, starAverage: starAverage, sequels: sequels, isFeatured: isFeatured)
                    
                    podcasts.append(podcast)
                }
            }
            completion(podcasts)
        }
    }
    
    func fetchProjectCover(coverID: String, completion: @escaping (ProjectCover?) -> Void) {
        let db = Firestore.firestore()
        let ref = db.collection("ProjectCover").document(coverID).getDocument { snapshot, error in
            guard error == nil else {
                print(error!.localizedDescription)
                completion(nil)
                return
            }
            
            if let snapshot = snapshot {
                let data = snapshot.data() ?? [:]
                let id = snapshot.documentID
                let image = data["image"] as? String ?? ""
                let projects = data["projects"] as? [String] ?? []
                let reviews = data["reviews"] as? [String] ?? []
                let reviewsCount = data["reviewsCount"] as? Int ?? 0
                let starAverage = data["starAverage"] as? Double ?? 0
                let outfits = data["outfits"] as? [String] ?? []
                
                let projectCover = ProjectCover(id: id, image: image, projects: projects, reviews: reviews, reviewsCount: reviewsCount, starAverage: starAverage, outfits: outfits)
    
                completion(projectCover)
            }
        }
        
        completion(nil)
    }
    
    func fetchPodcastCover(coverID: String, completion: @escaping (PodcastCover?) -> Void) {
        let db = Firestore.firestore()
        let ref = db.collection("PodcastCover").document(coverID).getDocument { snapshot, error in
            guard error == nil else {
                print(error!.localizedDescription)
                completion(nil)
                return
            }
            
            if let snapshot = snapshot {
                let data = snapshot.data() ?? [:]
                let id = snapshot.documentID
                let image = data["image"] as? String ?? ""
                let projects = data["podcasts"] as? [String] ?? []
                let reviews = data["reviews"] as? [String] ?? []
                let reviewsCount = data["reviewsCount"] as? Int ?? 0
                let starAverage = data["starAverage"] as? Double ?? 0
                let outfits = data["outfits"] as? [String] ?? []
                
                let podcastCover = PodcastCover(id: id, image: image, podcasts: projects, reviews: reviews, reviewsCount: reviewsCount, starAverage: starAverage, outfits: outfits)
    
                completion(podcastCover)
            }
        }
        
        completion(nil)
    }
    
    func fetchArtists(withIDs artistIDs: [String], completion: @escaping ([Artist]) -> Void) {
        let db = Firestore.firestore()
        var fetchedArtists: [Artist] = []
        let group = DispatchGroup()
        
        for id in artistIDs {
            group.enter()
            let ref = db.collection("Artist").document(id)
            ref.getDocument { document, error in
                defer { group.leave() }
                
                guard let document = document, document.exists, error == nil else {
                    print(error?.localizedDescription ?? "Unknown error fetching artist with ID: \(id)")
                    return
                }
                
                let data = document.data() ?? [:]
                let birthdateTimestamp = data["birthdate"] as? Timestamp
                let birthdate: Date? = birthdateTimestamp?.dateValue()
                let wikipedia = data["description"] as? String ?? ""
                let name = data["name"] as? String ?? ""
                let picture = data["picture"] as? String ?? ""
                let projects = data["projects"] as? [String] ?? []
                let pronouns = data["pronouns"] as? String ?? ""
                let songs = data["songs"] as? [String] ?? []
                let movies = data["movies"] as? [String] ?? []
                let series = data["series"] as? [String] ?? []
                let podcasts = data["podcasts"] as? [String] ?? []
                let outfits = data["outfits"] as? [String] ?? []
                let isFeatured = data["isFeatured"] as? Bool ?? false
                
                let artist = Artist(
                    id: document.documentID,
                    name: name,
                    picture: picture,
                    wikipedia: wikipedia,
                    projects: projects,
                    songs: songs,
                    movies: movies,
                    series: series,
                    podcasts: podcasts,
                    outfits: outfits,
                    pronouns: pronouns,
                    birthdate: birthdate,
                    isFeatured: isFeatured
                )
                
                fetchedArtists.append(artist)
            }
        }
        
        group.notify(queue: .main) {
            completion(fetchedArtists)
        }
    }
    
    /// BATCHES !!!
    func fetchAProjectsReviews(projectID: String, completion: @escaping ([ProjectReview]) -> Void) {
        let db = Firestore.firestore()
        
        db.collection("ProjectReview")
            .whereField("project", isEqualTo: projectID)
            .whereField("isLatest", isEqualTo: true)
            .order(by: "date", descending: true)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching reviews: \(error.localizedDescription)")
                    completion([])
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    completion([])
                    return
                }
                
                let reviews: [ProjectReview] = documents.compactMap { document in
                    let data = document.data()
                    let id = document.documentID
                    let stars = data["stars"] as? Double ?? 0
                    let text = data["text"] as? String ?? ""
                    let subreviewsTopics = data["subreviewsTopics"] as? [String] ?? []
                    let subreviewsStars = data["subreviewsStars"] as? [Double] ?? []
                    let subreviewsTexts = data["subreviewsTexts"] as? [String] ?? []
                    let project = data["project"] as? String ?? ""
                    let user = data["user"] as? String ?? ""
                    let dateTimestamp = data["date"] as? Timestamp
                    let date = dateTimestamp?.dateValue() ?? Date()
                    let isLatest = data["isLatest"] as? Bool ?? false
                    
                    return ProjectReview(
                        id: id,
                        stars: stars,
                        text: text,
                        subreviewsStars: subreviewsStars,
                        subreviewsTopics: subreviewsTopics,
                        subreviewsTexts: subreviewsTexts,
                        project: project,
                        user: user,
                        date: date,
                        isLatest: isLatest
                    )
                }
                
                completion(reviews)
            }
    }
    
    func fetchProjectReviewWithGivenID(withID reviewID: String, completion: @escaping (ProjectReview?) -> Void) {
        let db = Firestore.firestore()
        
            let ref = db.collection("ProjectReview").document(reviewID)
            ref.getDocument { document, error in
                guard let document = document, document.exists, error == nil else {
                    print(error?.localizedDescription ?? "Unknown error fetching project review with ID: \(reviewID)")
                    completion(nil)
                    return
                }
                let data = document.data() ?? [:]
                let id = document.documentID
                let stars = data["stars"] as? Double ?? 0
                let text = data["text"] as? String ?? ""
                let subreviewsTopics = data["subreviewsTopics"] as? [String] ?? []
                let subreviewsStars = data["subreviewsStars"] as? [Double] ?? []
                let subreviewsTexts = data["subreviewsTexts"] as? [String] ?? []
                let project = data["project"] as? String ?? ""
                let user = data["user"] as? String ?? ""
                let dateTimestamp = data["date"] as? Timestamp
                let date = dateTimestamp?.dateValue() ?? Date()
                let isLatest = data["isLatest"] as? Bool ?? false
                
                let projectReview = ProjectReview(id: id, stars: stars, text: text, subreviewsStars: subreviewsStars, subreviewsTopics: subreviewsTopics, subreviewsTexts: subreviewsTexts, project: project, user: user, date: date, isLatest: isLatest)
                
                completion(projectReview)
            }
    }
    
    func fetchAProjectsSongs(withIDs songsIDs: [String], completion: @escaping ([Song]) -> Void) {
        let db = Firestore.firestore()
        var fetchedSongs: [Song] = []
        let group = DispatchGroup()
        
        for id in songsIDs {
            group.enter()
            let ref = db.collection("Song").document(id)
            ref.getDocument { document, error in
                defer { group.leave() }
                
                guard let document = document, document.exists, error == nil else {
                    print(error?.localizedDescription ?? "Unknown error fetching song with ID: \(id)")
                    return
                }
                let data = document.data() ?? [:]
                let id = document.documentID
                let title = data["title"] as? String ?? ""
                let artist = data["artist"] as? [String] ?? []
                let features = data["features"] as? [String] ?? []
                let lengthMinutes = data["lengthMinutes"] as? Int ?? 0
                let lengthSeconds = data["lengthSeconds"] as? Int ?? 0
                let releaseDateTimestamp = data["releaseDate"] as? Timestamp
                let releaseDate = releaseDateTimestamp?.dateValue() ?? Date()
                let projectsPartOf = data["projectsPartOf"] as? [String] ?? []
                let reviews = data["reviews"] as? [String] ?? []
                let reviewsCount = data["reviewsCount"] as? Int ?? 0
                let starAverage = data["starAverage"] as? Double ?? 0
                let alternativeVersions = data["alternativeVersions"] as? [String] ?? []
                let musicVideos = data["musicVideos"] as? [String] ?? []
                let movies = data["movies"] as? [String] ?? []
                let series = data["series"] as? [String] ?? []
                let isFeatured = data["isFeatured"] as? Bool ?? false
                
                let song = Song(id: id, title: title, artist: artist, features: features, lengthMinutes: lengthMinutes, lengthSeconds: lengthSeconds, releaseDate: releaseDate, projectsPartOf: projectsPartOf, reviews: reviews, reviewsCount: reviewsCount, starAverage: starAverage, alternativeVersions: alternativeVersions, musicVideos: musicVideos, movies: movies, series: series, isFeatured: isFeatured)
                
                fetchedSongs.append(song)
            }
        }
        
        group.notify(queue: .main) {
            completion(fetchedSongs)
        }
    }
    
    func fetchAProjectsMusicVideos(withIDs musicVideosIDs: [String], completion: @escaping ([MusicVideo]) -> Void) {
        let db = Firestore.firestore()
        var fetchedMusicVideos: [MusicVideo] = []
        let group = DispatchGroup()
        
        for id in musicVideosIDs {
            group.enter()
            let ref = db.collection("MusicVideo").document(id)
            ref.getDocument { document, error in
                defer { group.leave() }
                
                guard let document = document, document.exists, error == nil else {
                    print(error?.localizedDescription ?? "Unknown error fetching music video with ID: \(id)")
                    return
                }
                let data = document.data() ?? [:]
                let id = document.documentID
                let songs = data["songs"] as? [String] ?? []
                let releaseDateTimestamp = data["releaseDate"] as? Timestamp
                let releaseDate = releaseDateTimestamp?.dateValue() ?? Date()
                let youtube = data["youtube"] as? String ?? ""
                let reviews = data["reviews"] as? [String] ?? []
                let reviewsCount = data["reviewsCount"] as? Int ?? 0
                let starAverage = data["starAverage"] as? Double ?? 0
                let outfits = data["outfits"] as? [String] ?? []
                let isFeatured = data["isFeatured"] as? Bool ?? false
                
                let musicVideo = MusicVideo(id: id, songs: songs, releaseDate: releaseDate, youtube: youtube, reviews: reviews, reviewsCount: reviewsCount, starAverage: starAverage, outfits: outfits, isFeatured: isFeatured)
                
                fetchedMusicVideos.append(musicVideo)
            }
        }
        
        group.notify(queue: .main) {
            completion(fetchedMusicVideos)
        }
    }
    
    func fetchAProjectsCovers(withIDs coversIDs: [String], completion: @escaping ([ProjectCover]) -> Void) {
        let db = Firestore.firestore()
        var fetchedCovers: [ProjectCover] = []
        let group = DispatchGroup()
        
        for id in coversIDs {
            group.enter()
            let ref = db.collection("ProjectCover").document(id)
            ref.getDocument { document, error in
                defer { group.leave() }
                
                guard let document = document, document.exists, error == nil else {
                    print(error?.localizedDescription ?? "Unknown error fetching music video with ID: \(id)")
                    return
                }
                let data = document.data() ?? [:]
                let id = document.documentID
                let image = data["image"] as? String ?? ""
                let projects = data["projects"] as? [String] ?? []
                let reviews = data["reviews"] as? [String] ?? []
                let reviewsCount = data["reviewsCount"] as? Int ?? 0
                let starAverage = data["starAverage"] as? Double ?? 0
                let outfits = data["outfits"] as? [String] ?? []
                
                let projectCover = ProjectCover(id: id, image: image, projects: projects, reviews: reviews, reviewsCount: reviewsCount, starAverage: starAverage, outfits: outfits)
                
                fetchedCovers.append(projectCover)
            }
        }
        
        group.notify(queue: .main) {
            completion(fetchedCovers)
        }
    }
    
    func fetchASongsReviews(withIDs reviewsIDs: [String], completion: @escaping ([SongReview]) -> Void) {
        let db = Firestore.firestore()
        var fetchedReviews: [SongReview] = []
        let group = DispatchGroup()
        
        for id in reviewsIDs {
            group.enter()
            let ref = db.collection("SongReview").document(id)
            ref.getDocument { document, error in
                defer { group.leave() }
                
                guard let document = document, document.exists, error == nil else {
                    print(error?.localizedDescription ?? "Unknown error fetching project review with ID: \(id)")
                    return
                }
                let data = document.data() ?? [:]
                let id = document.documentID
                let stars = data["stars"] as? Double ?? 0
                let text = data["text"] as? String ?? ""
                let subreviewsTopics = data["subreviewsTopics"] as? [String] ?? []
                let subreviewsStars = data["subreviewsStars"] as? [Double] ?? []
                let subreviewsTexts = data["subreviewsTexts"] as? [String] ?? []
                let song = data["song"] as? String ?? ""
                let user = data["user"] as? String ?? ""
                let dateTimestamp = data["date"] as? Timestamp
                let date = dateTimestamp?.dateValue() ?? Date()
                
                let songReview = SongReview(id: id, stars: stars, text: text, subreviewsStars: subreviewsStars, subreviewsTopics: subreviewsTopics, subreviewsTexts: subreviewsTexts, song: song, user: user, date: date)
                
                fetchedReviews.append(songReview)
            }
        }
        
        group.notify(queue: .main) {
            completion(fetchedReviews)
        }
    }
    /*
    func fetchProfiles() {
        profiles.removeAll()
        let db = Firestore.firestore()
        let ref = db.collection("Profile")
        ref.getDocuments { snapshot, error in
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            if let snapshot = snapshot {
                for document in snapshot.documents {
                    let data = document.data()
                    let id = document.documentID
                    let birthdateTimestamp = data["birthdate"] as? Timestamp? ?? nil
                    let birthdate: Date? = birthdateTimestamp?.dateValue()
                    let bannerPicture = data["bannerPicture"] as? String ?? ""
                    let bio = data["bio"] as? String ?? ""
                    let email = data["email"] as? String ?? ""
                    let firstName = data["firstName"] as? String ?? ""
                    let hasPremium = data["hasPremium"] as? Bool ?? false
                    let isAdmin = data["isAdmin"] as? Bool ?? false
                    let lastName = data["lastName"] as? String ?? ""
                    let movieReviews = data["movieReviews"] as? [String] ?? []
                    let musicVideoReviews = data["musicVideoReviews"] as? [String] ?? []
                    let outfitReviews = data["outfitReviews"] as? [String] ?? []
                    let podcastReviews = data["podcastReviews"] as? [String] ?? []
                    let profilePicture = data["profilePicture"] as? String ?? ""
                    let projectCoverReviews = data["projectCoverReviews"] as? [String] ?? []
                    let projectReviews = data["projectReviews"] as? [String] ?? []
                    let pronouns = data["pronouns"] as? String ?? ""
                    let seriesReviews = data["seriesReviews"] as? [String] ?? []
                    let songReviews = data["songReviews"] as? [String] ?? []
                    let tag = data["tag"] as? String ?? ""
                    
                    let profile = Profile(id: id, tag: tag, hasPremium: hasPremium, bannerPicture: bannerPicture, profilePicture: profilePicture, email: email, firstName: firstName, lastName: lastName, birthdate: birthdate!, bio: bio, pronouns: pronouns, isAdmin: isAdmin, projectReviews: projectReviews, projectCoverReviews: projectCoverReviews, songReviews: songReviews, musicVideoReviews: musicVideoReviews, podcastReviews: podcastReviews, movieReviews: movieReviews, seriesReviews: seriesReviews, outfitReviews: outfitReviews)
                    
                    self.profiles.append(profile)
                }
            }
        }
    }
    
    func fetchArtists() {
        artists.removeAll()
        let db = Firestore.firestore()
        let ref = db.collection("Artist")
        ref.getDocuments { snapshot, error in
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            if let snapshot = snapshot {
                for document in snapshot.documents {
                    let data = document.data()
                    let id = document.documentID
                    let birthdateTimestamp = data["birthdate"] as? Timestamp? ?? nil
                    let birthdate: Date? = birthdateTimestamp?.dateValue()
                    let wikipedia = data["description"] as? String ?? ""
                    let name = data["name"] as? String ?? ""
                    let picture = data["picture"] as? String ?? ""
                    let projects = data["projects"] as? [String] ?? []
                    let pronouns = data["pronouns"] as? String ?? ""
                    let songs = data["songs"] as? [String] ?? []
                    let movies = data["movies"] as? [String] ?? []
                    let series = data["series"] as? [String] ?? []
                    let podcasts = data["podcasts"] as? [String] ?? []
                    let outfits = data["outfits"] as? [String] ?? []
                    let isFeatured = data["isFeatured"] as? Bool ?? false
                    
                    let artist = Artist(id: id, name: name, picture: picture, wikipedia: wikipedia, projects: projects, songs: songs, movies: movies, series: series, podcasts: podcasts, outfits: outfits, pronouns: pronouns, birthdate: birthdate, isFeatured: isFeatured)
                    
                    self.artists.append(artist)
                }
            }
        }
    }
    
    func fetchProjects() {
        projects.removeAll()
        let db = Firestore.firestore()
        let ref = db.collection("Project")
        ref.getDocuments { snapshot, error in
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            if let snapshot = snapshot {
                for document in snapshot.documents {
                    let data = document.data()
                    let id = document.documentID
                    let title = data["title"] as? String ?? ""
                    let artist = data["artist"] as? [String] ?? []
                    let numberOfSongs = data["numberOfSongs"] as? Int ?? 0
                    let releaseDateTimestamp = data["releaseDate"] as? Timestamp
                    let releaseDate = releaseDateTimestamp?.dateValue() ?? Date()
                    let type = data["type"] as? Int ?? 0
                    let songs = data["songs"] as? [String] ?? []
                    let cover = data["cover"] as? [String] ?? []
                    let length = data["length"] as? Int ?? 0
                    let reviews = data["reviews"] as? [String] ?? []
                    let alternativeVersions = data["alternativeVersions"] as? [String] ?? []
                    let isFeatured = data["isFeatured"] as? Bool ?? false
                    
                    let project = Project(id: id, title: title, artist: artist, numberOfSongs: numberOfSongs, releaseDate: releaseDate, type: type, songs: songs, cover: cover, length: length, reviews: reviews, alternativeVersions: alternativeVersions, isFeatured: isFeatured)
                    
                    self.projects.append(project)
                }
            }
        }
    }
    
    func fetchSongs() {
        songs.removeAll()
        let db = Firestore.firestore()
        let ref = db.collection("Song")
        ref.getDocuments { snapshot, error in
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            if let snapshot = snapshot {
                for document in snapshot.documents {
                    let data = document.data()
                    let id = document.documentID
                    let title = data["title"] as? String ?? ""
                    let artist = data["artist"] as? [String] ?? []
                    let features = data["features"] as? [String] ?? []
                    let lengthMinutes = data["lengthMinutes"] as? Int ?? 0
                    let lengthSeconds = data["lengthSeconds"] as? Int ?? 0
                    let releaseDateTimestamp = data["releaseDate"] as? Timestamp
                    let releaseDate = releaseDateTimestamp?.dateValue() ?? Date()
                    let projectsPartOf = data["projectsPartOf"] as? [String] ?? []
                    let reviews = data["reviews"] as? [String] ?? []
                    let alternativeVersions = data["alternativeVersions"] as? [String] ?? []
                    let musicVideos = data["musicVideos"] as? [String] ?? []
                    let isFeatured = data["isFeatured"] as? Bool ?? false
                    
                    let song = Song(id: id, title: title, artist: artist, features: features, lengthMinutes: lengthMinutes, lengthSeconds: lengthSeconds, releaseDate: releaseDate, projectsPartOf: projectsPartOf, reviews: reviews, alternativeVersions: alternativeVersions, musicVideos: musicVideos, isFeatured: isFeatured)
                    
                    self.songs.append(song)
                }
            }
        }
    }
    
    func fetchProjectReviews() {
        projectReviews.removeAll()
        let db = Firestore.firestore()
        let ref = db.collection("ProjectReview")
        ref.getDocuments { snapshot, error in
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            if let snapshot = snapshot {
                for document in snapshot.documents {
                    let data = document.data()
                    let id = document.documentID
                    let stars = data["stars"] as? Double ?? 0
                    let text = data["text"] as? String ?? ""
                    let subreviews = data["subreviews"] as? [String] ?? []
                    let project = data["project"] as? String ?? ""
                    let user = data["user"] as? String ?? ""
                    let dateTimestamp = data["date"] as? Timestamp
                    let date = dateTimestamp?.dateValue() ?? Date()
                    let projectReview = ProjectReview(id: id, stars: stars, text: text, subreviews: subreviews, project: project, user: user, date: date)
                    
                    self.projectReviews.append(projectReview)
                }
            }
        }
    }
    
    func fetchProjectSubreviews() {
        projectSubreviews.removeAll()
        let db = Firestore.firestore()
        let ref = db.collection("ProjectSubreview")
        ref.getDocuments { snapshot, error in
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            if let snapshot = snapshot {
                for document in snapshot.documents {
                    let data = document.data()
                    let id = document.documentID
                    let stars = data["stars"] as? Double ?? 0
                    let topic = data["topic"] as? String ?? ""
                    let text = data["text"] as? String ?? ""
                    let parentReview = data["parentReview"] as? String ?? ""
                    
                    let projectSubreview = ProjectSubreview(id: id, stars: stars, topic: topic, text: text, parentReview: parentReview)
                    
                    self.projectSubreviews.append(projectSubreview)
                }
            }
        }
    }
    
    func fetchProjectCovers() {
        projectCovers.removeAll()
        let db = Firestore.firestore()
        let ref = db.collection("ProjectCover")
        ref.getDocuments { snapshot, error in
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            if let snapshot = snapshot {
                for document in snapshot.documents {
                    let data = document.data()
                    let id = document.documentID
                    let image = data["image"] as? String ?? ""
                    let projects = data["projects"] as? [String] ?? []
                    
                    let projectCover = ProjectCover(id: id, image: image, projects: projects)
                    
                    self.projectCovers.append(projectCover)
                }
            }
        }
    }
    
    func fetchProjectCoverReviews() {
        projectCoverReviews.removeAll()
        let db = Firestore.firestore()
        let ref = db.collection("ProjectCoverReview")
        ref.getDocuments { snapshot, error in
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            if let snapshot = snapshot {
                for document in snapshot.documents {
                    let data = document.data()
                    let id = document.documentID
                    let stars = data["stars"] as? Double ?? 0
                    let cover = data["cover"] as? String ?? ""
                    let user = data["user"] as? String ?? ""
                    let dateTimestamp = data["date"] as? Timestamp
                    let date = dateTimestamp?.dateValue() ?? Date()
                    let projectCoverReview = ProjectCoverReview(id: id, stars: stars, cover: cover, user: user, date: date)
                    
                    self.projectCoverReviews.append(projectCoverReview)
                }
            }
        }
    }
    
    func fetchSongReviews() {
        songReviews.removeAll()
        let db = Firestore.firestore()
        let ref = db.collection("SongReview")
        ref.getDocuments { snapshot, error in
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            if let snapshot = snapshot {
                for document in snapshot.documents {
                    let data = document.data()
                    let id = document.documentID
                    let stars = data["stars"] as? Double ?? 0
                    let text = data["text"] as? String ?? ""
                    let subreviews = data["subreviews"] as? [String] ?? []
                    let song = data["song"] as? String ?? ""
                    let user = data["user"] as? String ?? ""
                    let dateTimestamp = data["date"] as? Timestamp
                    let date = dateTimestamp?.dateValue() ?? Date()
                    
                    let songReview = SongReview(id: id, stars: stars, text: text, subreviews: subreviews, song: song, user: user, date: date)
                    
                    self.songReviews.append(songReview)
                }
            }
        }
    }
    
    func fetchSongSubreviews() {
        songSubreviews.removeAll()
        let db = Firestore.firestore()
        let ref = db.collection("SongSubreview")
        ref.getDocuments { snapshot, error in
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            if let snapshot = snapshot {
                for document in snapshot.documents {
                    let data = document.data()
                    let id = document.documentID
                    let stars = data["stars"] as? Double ?? 0
                    let topic = data["topic"] as? String ?? ""
                    let text = data["text"] as? String ?? ""
                    let parentReview = data["parentReview"] as? String ?? ""
                    
                    let songSubreview = SongSubreview(id: id, stars: stars, topic: topic, text: text, parentReview: parentReview)
                    
                    self.songSubreviews.append(songSubreview)
                }
            }
        }
    }
    
    func fetchMovies() {
        movies.removeAll()
        let db = Firestore.firestore()
        let ref = db.collection("Movie")
        ref.getDocuments { snapshot, error in
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            if let snapshot = snapshot {
                for document in snapshot.documents {
                    let data = document.data()
                    let id = document.documentID
                    let title = data["title"] as? String ?? ""
                    let actors = data["actors"] as? [String] ?? []
                    let releaseDateTimestamp = data["releaseDate"] as? Timestamp
                    let releaseDate = releaseDateTimestamp?.dateValue() ?? Date()
                    let covers = data["covers"] as? [String] ?? []
                    let wikipedia = data["wikipedia"] as? String ?? ""
                    let trailer = data["trailer"] as? String ?? ""
                    let length = data["length"] as? Int ?? 0
                    let reviews = data["reviews"] as? [String] ?? []
                    let starAverage = data["starAverage"] as? Double ?? 0
                    let sequels = data["sequels"] as? [String] ?? []
                    let isFeatured = data["isFeatured"] as? Bool ?? false
                    let relatedSeries = data["relatedSeries"] as? [String] ?? []
                    let soundtrackProjects = data["soundtrackProjects"] as? [String] ?? []
                    let soundtrackSongs = data["soundtrackSongs"] as? [String] ?? []
                    let outfits = data["outfits"] as? [String] ?? []
                    
                    let movie = Movie(id: id, title: title, actors: actors, releaseDate: releaseDate, covers: covers, wikipedia: wikipedia, trailer: trailer, length: length, reviews: reviews, starAverage: starAverage, sequels: sequels, relatedSeries: relatedSeries, soundtrackProjects: soundtrackProjects, soundtrackSongs: soundtrackSongs, outfits: outfits, isFeatured: isFeatured)
                    
                    self.movies.append(movie)
                }
            }
        }
    }
    
    func fetchMovieReviews() {
        movieReviews.removeAll()
        let db = Firestore.firestore()
        let ref = db.collection("MovieReview")
        ref.getDocuments { snapshot, error in
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            if let snapshot = snapshot {
                for document in snapshot.documents {
                    let data = document.data()
                    let id = document.documentID
                    let stars = data["stars"] as? Double ?? 0
                    let text = data["text"] as? String ?? ""
                    let subreviews = data["subreviews"] as? [String] ?? []
                    let movie = data["movie"] as? String ?? ""
                    let user = data["user"] as? String ?? ""
                    let dateTimestamp = data["date"] as? Timestamp
                    let date = dateTimestamp?.dateValue() ?? Date()
                    
                    let movieReview = MovieReview(id: id, stars: stars, text: text, subreviews: subreviews, movie: movie, user: user, date: date)
                    
                    self.movieReviews.append(movieReview)
                }
            }
        }
    }
    
    func fetchMovieSubreviews() {
        movieSubreviews.removeAll()
        let db = Firestore.firestore()
        let ref = db.collection("MovieSubreview")
        ref.getDocuments { snapshot, error in
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            if let snapshot = snapshot {
                for document in snapshot.documents {
                    let data = document.data()
                    let id = document.documentID
                    let stars = data["stars"] as? Double ?? 0
                    let topic = data["topic"] as? String ?? ""
                    let text = data["text"] as? String ?? ""
                    let parentReview = data["parentReview"] as? String ?? ""
                    
                    let movieSubreview = MovieSubreview(id: id, stars: stars, topic: topic, text: text, parentReview: parentReview)
                    
                    self.movieSubreviews.append(movieSubreview)
                }
            }
        }
    }
    
    func fetchTVSeries() {
        tvSeries.removeAll()
        let db = Firestore.firestore()
        let ref = db.collection("TVSeries")
        ref.getDocuments { snapshot, error in
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            if let snapshot = snapshot {
                for document in snapshot.documents {
                    let data = document.data()
                    let id = document.documentID
                    let title = data["title"] as? String ?? ""
                    let actors = data["actors"] as? [String] ?? []
                    let releaseDateTimestamp = data["releaseDate"] as? Timestamp
                    let releaseDate = releaseDateTimestamp?.dateValue() ?? Date()
                    let cover = data["cover"] as? String ?? ""
                    let wikipedia = data["wikipedia"] as? String ?? ""
                    let trailer = data["trailer"] as? String ?? ""
                    let seasons = data["seasons"] as? Int ?? 0
                    let episodes = data["episodes"] as? Int ?? 0
                    let reviews = data["reviews"] as? [String] ?? []
                    let sequels = data["sequels"] as? [String] ?? []
                    let isFeatured = data["isFeatured"] as? Bool ?? false
                    
                    let tvseries = TVSeries(id: id, title: title, actors: actors, releaseDate: releaseDate, cover: cover, wikipedia: wikipedia, trailer: trailer, seasons: seasons, episodes: episodes, reviews: reviews, sequels: sequels, isFeatured: isFeatured)
                    
                    self.tvSeries.append(tvseries)
                }
            }
        }
    }
    
    func fetchTVSeriesReviews() {
        tvSeriesReviews.removeAll()
        let db = Firestore.firestore()
        let ref = db.collection("TVSeriesReview")
        ref.getDocuments { snapshot, error in
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            if let snapshot = snapshot {
                for document in snapshot.documents {
                    let data = document.data()
                    let id = document.documentID
                    let stars = data["stars"] as? Double ?? 0
                    let text = data["text"] as? String ?? ""
                    let subreviews = data["subreviews"] as? [String] ?? []
                    let series = data["series"] as? String ?? ""
                    let user = data["user"] as? String ?? ""
                    let dateTimestamp = data["date"] as? Timestamp
                    let date = dateTimestamp?.dateValue() ?? Date()
                    
                    let tvseriesReview = TVSeriesReview(id: id, stars: stars, text: text, subreviews: subreviews, series: series, user: user, date: date)
                    
                    self.tvSeriesReviews.append(tvseriesReview)
                }
            }
        }
    }
    
    func fetchTVSeriesSubreviews() {
        tvSeriesSubreviews.removeAll()
        let db = Firestore.firestore()
        let ref = db.collection("TVSeriesSubreview")
        ref.getDocuments { snapshot, error in
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            if let snapshot = snapshot {
                for document in snapshot.documents {
                    let data = document.data()
                    let id = document.documentID
                    let stars = data["stars"] as? Double ?? 0
                    let topic = data["topic"] as? String ?? ""
                    let text = data["text"] as? String ?? ""
                    let parentReview = data["parentReview"] as? String ?? ""
                    
                    let tvseriesSubreview = TVSeriesSubreview(id: id, stars: stars, topic: topic, text: text, parentReview: parentReview)
                    
                    self.tvSeriesSubreviews.append(tvseriesSubreview)
                }
            }
        }
    }
    
    func fetchPodcasts() {
        podcasts.removeAll()
        let db = Firestore.firestore()
        let ref = db.collection("Podcast")
        ref.getDocuments { snapshot, error in
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            if let snapshot = snapshot {
                for document in snapshot.documents {
                    let data = document.data()
                    let id = document.documentID
                    let title = data["title"] as? String ?? ""
                    let by = data["by"] as? String ?? ""
                    let hosts = data["hosts"] as? [String] ?? []
                    let sinceTimestamp = data["since"] as? Timestamp
                    let since = sinceTimestamp?.dateValue() ?? Date()
                    let cover = data["cover"] as? String ?? ""
                    let website = data["website"] as? String ?? ""
                    let reviews = data["reviews"] as? [String] ?? []
                    let sequels = data["sequels"] as? [String] ?? []
                    let isFeatured = data["isFeatured"] as? Bool ?? false
                    
                    let podcast = Podcast(id: id, title: title, by: by, hosts: hosts, since: since, cover: cover, website: website, reviews: reviews, sequels: sequels, isFeatured: isFeatured)
                    
                    self.podcasts.append(podcast)
                }
            }
        }
    }
    
    func fetchPodcastReviews() {
        podcastReviews.removeAll()
        let db = Firestore.firestore()
        let ref = db.collection("PodcastReview")
        ref.getDocuments { snapshot, error in
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            if let snapshot = snapshot {
                for document in snapshot.documents {
                    let data = document.data()
                    let id = document.documentID
                    let stars = data["stars"] as? Double ?? 0
                    let text = data["text"] as? String ?? ""
                    let subreviews = data["subreviews"] as? [String] ?? []
                    let podcast = data["podcast"] as? String ?? ""
                    let user = data["user"] as? String ?? ""
                    let dateTimestamp = data["date"] as? Timestamp
                    let date = dateTimestamp?.dateValue() ?? Date()
                    
                    let podcastReview = PodcastReview(id: id, stars: stars, text: text, subreviews: subreviews, podcast: podcast, user: user, date: date)
                    
                    self.podcastReviews.append(podcastReview)
                }
            }
        }
    }
    
    func fetchPodcastSubreviews() {
        podcastSubreviews.removeAll()
        let db = Firestore.firestore()
        let ref = db.collection("PodcastSubreview")
        ref.getDocuments { snapshot, error in
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            if let snapshot = snapshot {
                for document in snapshot.documents {
                    let data = document.data()
                    let id = document.documentID
                    let stars = data["stars"] as? Double ?? 0
                    let topic = data["topic"] as? String ?? ""
                    let text = data["text"] as? String ?? ""
                    let parentReview = data["parentReview"] as? String ?? ""
                    
                    let podcastSubreview = PodcastSubreview(id: id, stars: stars, topic: topic, text: text, parentReview: parentReview)
                    
                    self.podcastSubreviews.append(podcastSubreview)
                }
            }
        }
    }
    
    func fetchOutfits() {
        outfits.removeAll()
        let db = Firestore.firestore()
        let ref = db.collection("Outfit")
        ref.getDocuments { snapshot, error in
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            if let snapshot = snapshot {
                for document in snapshot.documents {
                    let data = document.data()
                    let id = document.documentID
                    let event = data["event"] as? String ?? ""
                    let person = data["person"] as? String ?? ""
                    let dateTimestamp = data["date"] as? Timestamp
                    let date = dateTimestamp?.dateValue() ?? Date()
                    let pictures = data["pictures"] as? [String] ?? []
                    let reviews = data["reviews"] as? [String] ?? []
                    let matches = data["matches"] as? [String] ?? []
                    let isFeatured = data["isFeatured"] as? Bool ?? false
                    
                    let outfit = Outfit(id: id, event: event, person: person, date: date, pictures: pictures, reviews: reviews, matches: matches, isFeatured: isFeatured)
                    
                    self.outfits.append(outfit)
                }
            }
        }
    }
    
    func fetchOutfitReviews() {
        outfitReviews.removeAll()
        let db = Firestore.firestore()
        let ref = db.collection("OutfitReview")
        ref.getDocuments { snapshot, error in
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            if let snapshot = snapshot {
                for document in snapshot.documents {
                    let data = document.data()
                    let id = document.documentID
                    let stars = data["stars"] as? Double ?? 0
                    let text = data["text"] as? String ?? ""
                    let subreviews = data["subreviews"] as? [String] ?? []
                    let outfit = data["outfit"] as? String ?? ""
                    let user = data["user"] as? String ?? ""
                    let dateTimestamp = data["date"] as? Timestamp
                    let date = dateTimestamp?.dateValue() ?? Date()
                    
                    let outfitReview = OutfitReview(id: id, stars: stars, text: text, subreviews: subreviews, outfit: outfit, user: user, date: date)
                    
                    self.outfitReviews.append(outfitReview)
                }
            }
        }
    }
    
    func fetchOutfitSubreviews() {
        outfitSubreviews.removeAll()
        let db = Firestore.firestore()
        let ref = db.collection("OutfitSubreview")
        ref.getDocuments { snapshot, error in
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            if let snapshot = snapshot {
                for document in snapshot.documents {
                    let data = document.data()
                    let id = document.documentID
                    let stars = data["stars"] as? Double ?? 0
                    let topic = data["topic"] as? String ?? ""
                    let text = data["text"] as? String ?? ""
                    let parentReview = data["parentReview"] as? String ?? ""
                    
                    let outfitSubreview = OutfitSubreview(id: id, stars: stars, topic: topic, text: text, parentReview: parentReview)
                    
                    self.outfitSubreviews.append(outfitSubreview)
                }
            }
        }
    }
    
    func fetchMusicVideos() {
        musicVideos.removeAll()
        let db = Firestore.firestore()
        let ref = db.collection("MusicVideo")
        ref.getDocuments { snapshot, error in
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            if let snapshot = snapshot {
                for document in snapshot.documents {
                    let data = document.data()
                    let id = document.documentID
                    let songs = data["songs"] as? [String] ?? []
                    let releaseDateTimestamp = data["releaseDate"] as? Timestamp
                    let releaseDate = releaseDateTimestamp?.dateValue() ?? Date()
                    let youtube = data["youtube"] as? String ?? ""
                    let reviews = data["reviews"] as? [String] ?? []
                    let isFeatured = data["isFeatured"] as? Bool ?? false
                    
                    let musicVideo = MusicVideo(id: id, songs: songs, releaseDate: releaseDate, youtube: youtube, reviews: reviews, isFeatured: isFeatured)
                    
                    self.musicVideos.append(musicVideo)
                }
            }
        }
    }
    
    func fetchMusicVideoReviews() {
        musicVideoReviews.removeAll()
        let db = Firestore.firestore()
        let ref = db.collection("MusicVideoReview")
        ref.getDocuments { snapshot, error in
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            if let snapshot = snapshot {
                for document in snapshot.documents {
                    let data = document.data()
                    let id = document.documentID
                    let stars = data["stars"] as? Double ?? 0
                    let text = data["text"] as? String ?? ""
                    let subreviews = data["subreviews"] as? [String] ?? []
                    let musicVideo = data["musicVideo"] as? String ?? ""
                    let user = data["user"] as? String ?? ""
                    let dateTimestamp = data["date"] as? Timestamp
                    let date = dateTimestamp?.dateValue() ?? Date()
                    
                    let musicVideoReview = MusicVideoReview(id: id, stars: stars, text: text, subreviews: subreviews, musicVideo: musicVideo, user: user, date: date)
                    
                    self.musicVideoReviews.append(musicVideoReview)
                }
            }
        }
    }
    
    func fetchMusicVideoSubreviews() {
        musicVideoSubreviews.removeAll()
        let db = Firestore.firestore()
        let ref = db.collection("MusicVideoSubreview")
        ref.getDocuments { snapshot, error in
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            if let snapshot = snapshot {
                for document in snapshot.documents {
                    let data = document.data()
                    let id = document.documentID
                    let stars = data["stars"] as? Double ?? 0
                    let topic = data["topic"] as? String ?? ""
                    let text = data["text"] as? String ?? ""
                    let parentReview = data["parentReview"] as? String ?? ""
                    
                    let musicVideoSubreview = MusicVideoSubreview(id: id, stars: stars, topic: topic, text: text, parentReview: parentReview)
                    
                    self.musicVideoSubreviews.append(musicVideoSubreview)
                }
            }
        }
    }
    */
    
    /*func addArtist(name: String, picture: String, wikipedia: String, pronouns: String, birthdate: Date? = nil) -> String{
        let db = Firestore.firestore()
        let ref = db.collection("Artist").document()
        let documentID = ref.documentID
        ref.setData(["name": name, "picture": picture, "wikipedia": wikipedia, "projects": [], "songs": [], "movies": [], "series": [], "podcasts": [], "outfits": [], "pronouns": pronouns, "birthdate": birthdate, "isFeatured": false]) { error in
            if let error = error {
                print(error.localizedDescription)
            }
        }
        
        return documentID
    }
    
    func addMusicVideo(youtube: String, releaseDate: Date, songs: [String], outfits: [String]) -> String {
        let db = Firestore.firestore()
        let ref = db.collection("MusicVideo").document()
        let documentID = ref.documentID
        ref.setData(["songs": songs, "releaseDate": releaseDate, "youtube": youtube, "reviews": [], "starAverage": 0, "outfits": outfits, "isFeatured": false]) { error in
            if let error = error {
                print(error.localizedDescription)
            }
        }
        
        return documentID
    }
    
    func addMovie(title: String, actors: [String], releaseDate: Date, covers: [String], wikipedia: String, trailer: String, length: Int, sequels: [String], relatedSeries: [String], soundtrackProjects: [String], soundtrackSongs: [String], outfits: [String]) -> String {
        let db = Firestore.firestore()
        let ref = db.collection("Movie").document()
        let documentID = ref.documentID
        ref.setData(["title": title, "actors": actors, "releaseDate": releaseDate, "covers": covers, "wikipedia": wikipedia, "trailer": trailer, "length": length, "reviews": [], "starAverage": 0, "sequels": sequels, "relatedSeries": relatedSeries, "soundtrackProjects": soundtrackProjects, "soundtrackSongs": soundtrackSongs, "outfits": outfits, "isFeatured": false]) { error in
            if let error = error {
                print(error.localizedDescription)
            }
        }
        
        return documentID
    }
    
    func addOutfit(event: String, person: String, date: Date, pictures: [String], matches: [String], projectCovers: [String], musicVideos: [String], podcastCovers: [String], movies: [String], movieCovers: [String], series: [String], seriesCovers: [String]) -> String {
        let db = Firestore.firestore()
        let ref = db.collection("Outfit").document()
        let documentID = ref.documentID
        ref.setData(["event": event, "person": person, "date": date, "pictures": pictures, "reviews": [], "starAverage": 0, "matches": matches, "projectCovers": podcastCovers, "musicVideos": musicVideos, "podcastCovers": podcastCovers, "movies": movies, "movieCovers": movieCovers, "series": series, "seriesCovers": seriesCovers, "isFeatured": false]) { error in
            if let error = error {
                print(error.localizedDescription)
            }
        }
        
        return documentID
    }
    
    func addPodcast(title: String, by: String, hosts: [String], since: Date, covers: [String], website: String, sequels: [String]) -> String {
        let db = Firestore.firestore()
        let ref = db.collection("Podcast").document()
        let documentID = ref.documentID
        ref.setData(["title": title, "by": by, "hosts": hosts, "since": since, "covers": covers, "website": website, "reviews": [], "starAverage": 0, "sequels": sequels, "isFeatured": false]) { error in
            if let error = error {
                print(error.localizedDescription)
            }
        }
        
        return documentID
    }
    
    func addTVSeries(title: String, actors: [String], releaseDate: Date, covers: [String], wikipedia: String, trailer: String, seasons: Int, episodes: Int, sequels: [String], relatedMovies: [String], soundtrackProjects: [String], soundtrackSongs: [String], outfits: [String]) -> String {
        let db = Firestore.firestore()
        let ref = db.collection("TVSeries").document()
        let documentID = ref.documentID
        ref.setData(["title": title, "actors": actors, "releaseDate": releaseDate, "covers": covers, "wikipedia": wikipedia, "trailer": trailer, "seasons": seasons, "episodes": episodes, "reviews": [], "starAverage": 0, "sequels": sequels, "relatedMovies": relatedMovies, "soundtrackProjects": soundtrackProjects, "soundtrackSongs": soundtrackSongs, "outfits": outfits, "isFeatured": false]) { error in
            if let error = error {
                print(error.localizedDescription)
            }
        }
        
        return documentID
    }
    
    func addProjectCover(image: String, projects: [String], outfits: [String]) -> String {
        let db = Firestore.firestore()
        let ref = db.collection("PojectCover").document()
        let documentID = ref.documentID
        ref.setData(["image": image, "projects": projects, "reviews": [], "starAverage": 0, "outfits": outfits]) { error in
            if let error = error {
                print(error.localizedDescription)
            }
        }
        
        return documentID
    }
    
    func addProject(title: String, artist: [String], numberOfSongs: Int, releaseDate: Date, type: Int, songs: [String], cover: [String], length: Int, alternativeVersions: [String], movies: [String], series: [String]) -> String{
        let db = Firestore.firestore()
        let ref = db.collection("Project").document()
        let documentID = ref.documentID
        ref.setData(["title": title, "artist": artist, "numberOfSongs": numberOfSongs, "releaseDate": releaseDate, "type": type, "songs": songs, "cover": cover, "length": length, "reviews": [], "starAverage": 0, "alternativeVersions": alternativeVersions, "movies": movies, "series": series, "isFeatured": false]) { error in
            if let error = error {
                print(error.localizedDescription)
            }
        }
        
        return documentID
    }
    
    func addSong(title: String, artist: [String], features: [String], lengthMinutes: Int, lengthSeconds: Int, releaseDate: Date, alternativeVersions: [String], musicVideos: [String], movies: [String], series: [String]) -> String{
        let db = Firestore.firestore()
        let ref = db.collection("Song").document()
        let documentID = ref.documentID
        ref.setData(["title": title, "artist": artist, "features": features, "lengthMinutes": lengthMinutes, "lengthSeconds": lengthSeconds, "releaseDate": releaseDate,  "projectsPartOf": [], "reviews": [], "starAverage": 0, "alternativeVersions": alternativeVersions, "musicVideos": musicVideos, "movies": movies, "series": series, "isFeatured": false]) { error in
            if let error = error {
                print(error.localizedDescription)
            }
        }
        return documentID
    }
    
    func makeProjectPartOfTheProjectsListOfACover(projectID: String, coverID: String) {
        let db = Firestore.firestore()
        let ref = db.collection("ProjectCover").document(coverID)
        ref.updateData([
            "projects": FieldValue.arrayUnion([projectID])
        ]) { error in
            if let error = error {
                print("Error updating document: \(error)")
            } else {
                print("Document successfully updated")
            }
        }
        
        if let index = projectCovers.firstIndex(where: { $0.id == coverID }) {
            projectCovers[index].projects.append(projectID)
        } else {
            print("blablabla69")
        }
    }
    
    func makeProjectBelongToArtist(projectID: String, artistID: String) {
        let db = Firestore.firestore()
        let ref = db.collection("Artist").document(artistID)
        ref.updateData([
            "projects": FieldValue.arrayUnion([projectID])
        ]) { error in
            if let error = error {
                print("Error updating document: \(error)")
            } else {
                print("Document successfully updated")
            }
        }
        
        if let index = artists.firstIndex(where: { $0.id == artistID }) {
            artists[index].projects.append(projectID)
        } else {
            print("blablabla1")
        }
    }
    
    func makeSongBelongToArtist(songID: String, artistID: String) {
        let db = Firestore.firestore()
        let ref = db.collection("Artist").document(artistID)
        ref.updateData([
            "songs": FieldValue.arrayUnion([songID])
        ]) { error in
            if let error = error {
                print("Error updating document: \(error)")
            } else {
                print("Document successfully updated")
            }
        }
        
        if let index = artists.firstIndex(where: { $0.id == artistID }) {
            artists[index].songs.append(songID)
        } else {
            print("blablabla3")
        }
    }
    
    func makeProjectAlternativeVersionOfAnotherProject(project1ID: String, project2ID: String) {
        let db = Firestore.firestore()
        let ref = db.collection("Project").document(project2ID)
        ref.updateData([
            "alternativeVersions": FieldValue.arrayUnion([project1ID])
        ]) { error in
            if let error = error {
                print("Error updating document: \(error)")
            }
            else {
                print("Document successfully updated")
            }
        }
        
        if let index = projects.firstIndex(where: { $0.id == project2ID }) {
            projects[index].alternativeVersions.append(project1ID)
        } else {
            print("blablabla2")
        }
    }
    
    func makeSongAlternativeVersionOfAnotherSong(song1ID: String, song2ID: String) {
        let db = Firestore.firestore()
        let ref = db.collection("Song").document(song2ID)
        ref.updateData([
            "alternativeVersions": FieldValue.arrayUnion([song1ID])
        ]) { error in
            if let error = error {
                print("Error updating document: \(error)")
            }
            else {
                print("Document successfully updated")
            }
        }
        
        if let index = songs.firstIndex(where: { $0.id == song2ID }) {
            songs[index].alternativeVersions.append(song1ID)
        } else {
            print("blablabla100idkbitch")
        }
    }
    
    func makeTVSeriesBePartOfArtistsTVSeriesList(tvSeriesID: String, artistID: String) {
        let db = Firestore.firestore()
        let ref = db.collection("Artist").document(artistID)
        ref.updateData([
            "series": FieldValue.arrayUnion([tvSeriesID])
        ]) { error in
            if let error = error {
                print("Error updating document: \(error)")
            } else {
                print("Document successfully updated")
            }
        }
        
        if let index = artists.firstIndex(where: { $0.id == artistID }) {
            artists[index].series.append(tvSeriesID)
        } else {
            print("TV Series to make artist actor in not found")
        }
    }
    
    func makeTVSeriesBeSequelOfAnotherTVSeries(tvSeriesID: String, sequelID: String) {
        let db = Firestore.firestore()
        let ref = db.collection("TVSeries").document(sequelID)
        ref.updateData([
            "sequels": FieldValue.arrayUnion([tvSeriesID])
        ]) { error in
            if let error = error {
                print("Error updating document: \(error)")
            }
            else {
                print("Document successfully updated")
            }
        }
        
        if let index = tvSeries.firstIndex(where: { $0.id == sequelID }) {
            tvSeries[index].sequels.append(tvSeriesID)
        } else {
            print("TV Series to be made sequel of another TV Series not found")
        }
    }
    
    func makeArtistBeHostOfAPodcast(podcastID: String, artistID: String) {
        let db = Firestore.firestore()
        let ref = db.collection("Artist").document(artistID)
        ref.updateData([
            "podcasts": FieldValue.arrayUnion([podcastID])
        ]) { error in
            if let error = error {
                print("Error updating document: \(error)")
            } else {
                print("Document successfully updated")
            }
        }
        
        if let index = artists.firstIndex(where: { $0.id == artistID }) {
            artists[index].podcasts.append(podcastID)
        } else {
            print("Podcast to make artist host of not found")
        }
    }
    
    func makePodcastSequelOfAnotherPodcast(podcastID: String, sequelID: String) {
        let db = Firestore.firestore()
        let ref = db.collection("Podcast").document(sequelID)
        ref.updateData([
            "sequels": FieldValue.arrayUnion([podcastID])
        ]) { error in
            if let error = error {
                print("Error updating document: \(error)")
            } else {
                print("Document successfully updated")
            }
        }
        
        if let index = movies.firstIndex(where: { $0.id == sequelID }) {
            podcasts[index].sequels.append(podcastID)
        } else {
            print("Sequel to add to movie not found")
        }
    }
    
    func makeMovieASequelOfAnotherMovie(movieID: String, sequelID: String) {
        let db = Firestore.firestore()
        let ref = db.collection("Movie").document(sequelID)
        ref.updateData([
            "sequels": FieldValue.arrayUnion([movieID])
        ]) { error in
            if let error = error {
                print("Error updating document: \(error)")
            } else {
                print("Document successfully updated")
            }
        }
        
        if let index = movies.firstIndex(where: { $0.id == sequelID }) {
            movies[index].sequels.append(movieID)
        } else {
            print("Sequel to add to movie not found")
        }
    }
    
    func makeMoviePartOfActorsMoviesList(actorID: String, movieID: String){
        let db = Firestore.firestore()
        let ref = db.collection("Artist").document(actorID)
        ref.updateData([
            "movies": FieldValue.arrayUnion([movieID])
        ]) { error in
            if let error = error {
                print("Error updating document: \(error)")
            } else {
                print("Document successfully updated")
            }
        }
        
        if let index = artists.firstIndex(where: { $0.id == actorID }) {
            artists[index].movies.append(movieID)
        } else {
            print("Movie to add to actor's list not found")
        }
    }
    
    func makeSongPartOfProject(songID: String, projectID: String){
        let db = Firestore.firestore()
        let ref = db.collection("Song").document(songID)
        ref.updateData([
            "projectsPartOf": FieldValue.arrayUnion([projectID])
        ]) { error in
            if let error = error {
                print("Error updating document: \(error)")
            } else {
                print("Document successfully updated")
            }
        }
    }
    
    func addSongReview(date: Date, song: String, stars: Double, text: String, subreviewsStars: [Double], subreviewsTopics: [String], subreviewsTexts: [String], user: String) -> String{
        let db = Firestore.firestore()
        let ref = db.collection("SongReview").document()
        let documentID = ref.documentID
        ref.setData(["date": date, "song": song, "stars": stars, "text": text, "user": user, "subreviewsStars": subreviewsStars, "subreviewsTopics": subreviewsTopics, "subreviewsTexts": subreviewsTexts]) { error in
            if let error = error {
                print(error.localizedDescription)
            }
        }
        return documentID
    }
    
    func makeReviewPartOfSong(review: String, song: String){
        let db = Firestore.firestore()
        let ref = db.collection("Song").document(song)
        ref.updateData([
            "reviews": FieldValue.arrayUnion([review])
        ]) { error in
            if let error = error {
                print("Error updating document: \(error)")
            } else {
                print("Document successfully updated")
            }
        }
    }
    
    func addProjectReview(date: Date, project: String, stars: Double, text: String, subreviewsStars: [Double], subreviewsTopics: [String], subreviewsTexts: [String], user: String, completion: @escaping (Bool, String?) -> Void) {
        let db = Firestore.firestore()
        
        // Step 1: Find the existing "latest" review for this user and project
        let query = db.collection("ProjectReview")
            .whereField("project", isEqualTo: project)
            .whereField("user", isEqualTo: user)
            .whereField("isLatest", isEqualTo: true)
            .limit(to: 1)
        
        query.getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching previous latest review: \(error.localizedDescription)")
                completion(false, nil)
                return
            }

            let batch = db.batch()

            // Step 2: If a previous latest review exists, mark it as not latest
            if let doc = snapshot?.documents.first {
                let previousLatestRef = doc.reference
                batch.updateData(["isLatest": false], forDocument: previousLatestRef)
            }

            // Step 3: Add the new review and mark it as latest
            let newRef = db.collection("ProjectReview").document()
            let newID = newRef.documentID

            let reviewData: [String: Any] = [
                "date": date,
                "project": project,
                "stars": stars,
                "text": text,
                "user": user,
                "subreviewsStars": subreviewsStars,
                "subreviewsTopics": subreviewsTopics,
                "subreviewsTexts": subreviewsTexts,
                "isLatest": true
            ]

            batch.setData(reviewData, forDocument: newRef)

            // Step 4: Commit the batch
            batch.commit { error in
                if let error = error {
                    print("Error committing batch: \(error.localizedDescription)")
                    completion(false, nil)
                } else {
                    completion(true, newID)
                }
            }
        }
    }
    
    func makeReviewPartOfProject(review: String, starcount: Double, oldStarAverage: Double, oldReviewsCount: Int, project: String, completion: @escaping (Bool) -> Void) {
        let newStarAverage: Double = (oldStarAverage * Double(oldReviewsCount) + starcount) / Double(oldReviewsCount + 1)
        
        let db = Firestore.firestore()
        let ref = db.collection("Project").document(project)
        
        ref.updateData([
            "reviews": FieldValue.arrayUnion([review]),
            "starAverage": newStarAverage,
            "reviewsCount": oldReviewsCount + 1
        ]) { error in
            if let error = error {
                completion(false) // Failed to update project
            } else {
                completion(true) // Successfully updated project
            }
        }
    }
    
    func deleteProjectReview(reviewID: String, projectID: String, completion: @escaping (Bool, String?) -> Void) {
        let db = Firestore.firestore()
        
        // Fetch the review first to get its star count
        db.collection("ProjectReview").document(reviewID).getDocument { reviewSnapshot, error in
            guard let reviewData = reviewSnapshot?.data(), let reviewStars = reviewData["stars"] as? Double else {
                completion(false, "Failed to fetch review data.")
                return
            }
            
            // Fetch the project to update reviewsCount and starAverage
            db.collection("Project").document(projectID).getDocument { projectSnapshot, error in
                guard let projectData = projectSnapshot?.data(),
                      let oldReviewsCount = projectData["reviewsCount"] as? Int,
                      let oldStarAverage = projectData["starAverage"] as? Double else {
                    completion(false, "Failed to fetch project data.")
                    return
                }
                
                // Ensure we don't divide by zero
                var newReviewsCount = oldReviewsCount - 1
                var newStarAverage: Double = 0.0
                
                if newReviewsCount > 0 {
                    let totalStars = oldStarAverage * Double(oldReviewsCount)
                    let newTotalStars = totalStars - reviewStars
                    newStarAverage = newTotalStars / Double(newReviewsCount)
                }
                
                // Remove review from Firestore
                db.collection("ProjectReview").document(reviewID).delete { error in
                    if let error = error {
                        completion(false, "Failed to delete review: \(error.localizedDescription)")
                        return
                    }
                    
                    // Update project in Firestore
                    db.collection("Project").document(projectID).updateData([
                        "reviews": FieldValue.arrayRemove([reviewID]),
                        "reviewsCount": newReviewsCount,
                        "starAverage": newStarAverage
                    ]) { error in
                        if let error = error {
                            completion(false, "Failed to update project: \(error.localizedDescription)")
                        } else {
                            completion(true, nil)
                        }
                    }
                }
            }
        }
    }
    
    func addMusicVideoReview(date: Date, musicVideo: String, stars: Double, text: String, subreviewsStars: [Double], subreviewsTopics: [String], subreviewsTexts: [String], user: String) -> String{
        let db = Firestore.firestore()
        let ref = db.collection("MusicVideoReview").document()
        let documentID = ref.documentID
        ref.setData(["date": date, "musicVideo": musicVideo, "stars": stars, "text": text, "user": user, "subreviewsStars": subreviewsStars, "subreviewsTopics": subreviewsTopics, "subreviewsTexts": subreviewsTexts]) { error in
            if let error = error {
                print(error.localizedDescription)
            }
        }
        return documentID
    }
    
    func makeReviewPartOfMusicVideo(review: String, musicVideo: String){
        let db = Firestore.firestore()
        let ref = db.collection("MusicVideo").document(musicVideo)
        ref.updateData([
            "reviews": FieldValue.arrayUnion([review])
        ]) { error in
            if let error = error {
                print("Error updating document: \(error)")
            } else {
                print("Document successfully updated")
            }
        }
    }
    
    func makeMusicVideoBelongToSong(song: String, musicVideo: String){
        let db = Firestore.firestore()
        let ref = db.collection("Song").document(song)
        ref.updateData([
            "musicVideos": FieldValue.arrayUnion([musicVideo])
        ]) { error in
            if let error = error {
                print("Error updating document: \(error)")
            } else {
                print("Document successfully updated")
            }
        }
        
        if let index = songs.firstIndex(where: { $0.id == song }) {
            songs[index].musicVideos.append(musicVideo)
        } else {
            print("Song to add music video to not found")
        }
    }
    
    func makeOutfitBeAMatchToAnother(outfitID: String, matchID: String) {
        let db = Firestore.firestore()
        let ref = db.collection("Outfit").document(matchID)
        ref.updateData([
            "matches": FieldValue.arrayUnion([outfitID])
        ]) { error in
            if let error = error {
                print("Error updating document: \(error)")
            } else {
                print("Document successfully updated")
            }
        }
        
        if let index = outfits.firstIndex(where: { $0.id == matchID }) {
            outfits[index].matches.append(outfitID)
        } else {
            print("Outfit to make be a match of another outfit not found")
        }
    }
    
    func getProfileWithGivenUserID(id: String) -> Profile? {
        return profiles.first { $0.id == id }
    }
    
    func getProjectCover(id: String) -> ProjectCover? {
        return projectCovers.first { $0.id == id }
    }
    
    func getProject(id: String) -> Project? {
        return projects.first { $0.id == id }
    }
    
    func getArtists(ids: [String]) -> [Artist]? {
        var orderedArtists: [Artist] = []
        for artistID in ids {
            if let artist = artists.first(where: { $0.id == artistID }) {
                orderedArtists.append(artist)
            }
        }
        return orderedArtists
    }
    
    func getArtistName(id: String) -> String {
        if let artist = artists.first(where: { $0.id == id }) {
            return artist.name
        } else {
            return "Unknown Artist"
        }
    }
    
    func getProjectAverageStars(project: Project) -> Double {
        let projectReviewsFiltered = projectReviews.filter { $0.project == project.id }
        
        if projectReviewsFiltered.isEmpty {
            return 0.0
        }
        
        let totalStars = projectReviewsFiltered.reduce(0.0) { sum, review in
            return sum + review.stars
        }
        
        let averageStars = totalStars / Double(projectReviewsFiltered.count)
        
        return averageStars
    }
    
    func getSongAverageStars(song: Song) -> Double {
        let songReviewsFiltered = songReviews.filter { $0.song == song.id }
        
        if songReviewsFiltered.isEmpty {
            return 0.0
        }
        
        let totalStars = songReviewsFiltered.reduce(0.0) { sum, review in
            return sum + review.stars
        }
        
        let averageStars = totalStars / Double(songReviewsFiltered.count)
        
        return averageStars
    }
    
    func getMusicVideoAverageStars(musicVideo: MusicVideo) -> Double {
        let musicVideoReviewsFiltered = musicVideoReviews.filter { $0.musicVideo == musicVideo.id }
        
        if musicVideoReviewsFiltered.isEmpty {
            return 0.0
        }
        
        let totalStars = musicVideoReviewsFiltered.reduce(0.0) { sum, review in
            return sum + review.stars
        }
        
        let averageStars = totalStars / Double(musicVideoReviewsFiltered.count)
        
        return averageStars
    }
    
    func getPodcastAverageStars(podcast: Podcast) -> Double {
        let podcastReviewsFiltered = podcastReviews.filter { $0.podcast == podcast.id }
        
        if podcastReviewsFiltered.isEmpty {
            return 0.0
        }
        
        let totalStars = podcastReviewsFiltered.reduce(0.0) { sum, review in
            return sum + review.stars
        }
        
        let averageStars = totalStars / Double(podcastReviewsFiltered.count)
        
        return averageStars
    }
    
    func getProjectType(project: Project) -> String {
        switch project.type {
        case 1:
            return "Album"
        case 2:
            return "EP"
        case 3:
            return "Mixtape"
        case 4:
            return "Single"
        default:
            return "Error6969"
        }
    }
    
    func getSongsOfAnAlbum(songIDs: [String]) -> [Song] {
        var orderedSongs: [Song] = []
        for songID in songIDs {
            if let song = songs.first(where: { $0.id == songID }) {
                orderedSongs.append(song)
            }
        }
        return orderedSongs
    }
    
    func getMusicVideosOfASong(musicVideosIDs: [String]) -> [MusicVideo] {
        var orderedMusicVideos: [MusicVideo] = []
        for musicVideoID in musicVideosIDs {
            if let musicVideo = musicVideos.first(where: { $0.id == musicVideoID }) {
                orderedMusicVideos.append(musicVideo)
            }
        }
        return orderedMusicVideos
    }
    
    func getFeaturesOfASong(artistsIDs: [String]) -> [Artist] {
        var orderedArtists: [Artist] = []
        for artistID in artistsIDs {
            if let artist = artists.first(where: { $0.id == artistID }) {
                orderedArtists.append(artist)
            }
        }
        return orderedArtists
    }
    
    func getProjectReviews(reviewsIDs: [String]) -> [ProjectReview] {
        var orderedReviews: [ProjectReview] = []
        for reviewID in reviewsIDs {
            if let review = projectReviews.first(where: { $0.id == reviewID }) {
                orderedReviews.append(review)
            }
        }
        return orderedReviews
    }
    
    func getSongReviews(reviewsIDs: [String]) -> [SongReview] {
        var orderedReviews: [SongReview] = []
        for reviewID in reviewsIDs {
            if let review = songReviews.first(where: { $0.id == reviewID }) {
                orderedReviews.append(review)
            }
        }
        return orderedReviews
    }
    
    func getMusicVideoReviews(reviewsIDs: [String]) -> [MusicVideoReview] {
        var orderedReviews: [MusicVideoReview] = []
        for reviewID in reviewsIDs {
            if let review = musicVideoReviews.first(where: { $0.id == reviewID }) {
                orderedReviews.append(review)
            }
        }
        return orderedReviews
    }
    
    func getSongWithGivenID(id: String) -> Song {
        let searchedSong = songs.filter { $0.id == id }
        return searchedSong[0]
    }
    
    func uploadImage(_ image: UIImage, path: String, completion: @escaping (String?) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(nil)
            return
        }

        let storageRef = Storage.storage().reference().child(path)
        
        storageRef.putData(imageData, metadata: nil) { _, error in
            if let error = error {
                print("Failed to upload image:", error.localizedDescription)
                completion(nil)
            } else {
                storageRef.downloadURL { url, error in
                    if let url = url {
                        completion(url.absoluteString)
                    } else {
                        completion(nil)
                    }
                }
            }
        }
    }
    
    func updateProfileImage(userID: String, image: UIImage, isBanner: Bool, completion: @escaping (String?) -> Void) {
        let path = isBanner ? "banners/\(userID).jpg" : "profile_pictures/\(userID).jpg"
        
        uploadImage(image, path: path) { url in
            guard let imageUrl = url else {
                completion(nil)
                return
            }
            
            let db = Firestore.firestore()
            let field = isBanner ? "bannerPicture" : "profilePicture"
            
            DispatchQueue.main.async {
                db.collection("Profile").document(userID).updateData([field: imageUrl]) { error in
                    if let error = error {
                        print("Failed to update Firestore:", error.localizedDescription)
                    } else {
                        print("Image URL successfully updated in Firestore")
                    }
                    completion(imageUrl)
                }
            }
        }
    }

    func listenForConversations(userID: String, lastConversation: DocumentSnapshot?, limit: Int = 50, completion: @escaping ([Conversation], DocumentSnapshot?) -> Void) -> ListenerRegistration {
        let db = Firestore.firestore()
        
        var query = db.collection("Conversation")
            .whereFilter(Filter.orFilter([
                Filter.whereField("userA", isEqualTo: userID),
                Filter.whereField("userB", isEqualTo: userID)
            ]))
            .order(by: "latestMessageTime", descending: true)
            .limit(to: limit)

        
        if let lastConversation = lastConversation {
            query = query.start(afterDocument: lastConversation)
        }

        let listener = query.addSnapshotListener { snapshot, error in
            guard let documents = snapshot?.documents, error == nil else {
                print("Error listening for conversations: \(error?.localizedDescription ?? "Unknown error")")
                completion([], nil)
                return
            }
            
            var conversations: [Conversation] = []
            
            var newLastConversation: DocumentSnapshot? = nil
            
            for document in documents {
                let data = document.data()
                let id = document.documentID
                let userA = data["userA"] as? String ?? ""
                let userB = data["userB"] as? String ?? ""
                let latestMessageID = data["latestMessageID"] as? String ?? ""
                let latestMessageTimeTimestamp = data["latestMessageTime"] as? Timestamp
                let latestMessageTime: Date = latestMessageTimeTimestamp?.dateValue() ?? Date()
                let latestMessageText = data["latestMessageText"] as? String ?? ""
                let latestMessageSender = data["latestMessageSender"] as? String ?? ""

                let conversation = Conversation(
                    id: id,
                    userA: userA,
                    userB: userB,
                    latestMessageID: latestMessageID,
                    latestMessageTime: latestMessageTime,
                    latestMessageText: latestMessageText,
                    latestMessageSender: latestMessageSender
                )

                conversations.append(conversation)
                
                newLastConversation = document
            }
            
            completion(conversations, newLastConversation)
        }
        
        return listener
    }
    
    func fetchConversationWithGivenID(conversationID: String, completion: @escaping (Conversation?) -> Void) {
        let db = Firestore.firestore()
        
        db.collection("Conversation").document(conversationID).getDocument { document, error in
            guard let document = document, document.exists, let data = document.data() else {
                print("Error fetching conversation: \(error?.localizedDescription ?? "Conversation not found")")
                completion(nil)
                return
            }

            let id = document.documentID
            let userA = data["userA"] as? String ?? ""
            let userB = data["userB"] as? String ?? ""
            let latestMessageID = data["latestMessageID"] as? String ?? ""
            let latestMessageTimeTimestamp = data["latestMessageTime"] as? Timestamp
            let latestMessageTime: Date = latestMessageTimeTimestamp?.dateValue() ?? Date()
            let latestMessageText = data["latestMessageText"] as? String ?? ""
            let latestMessageSender = data["latestMessageSender"] as? String ?? ""

            let conversation = Conversation(
                id: id,
                userA: userA,
                userB: userB,
                latestMessageID: latestMessageID,
                latestMessageTime: latestMessageTime,
                latestMessageText: latestMessageText,
                latestMessageSender: latestMessageSender
            )

            completion(conversation)
        }
    }
    
    func getIDOfTheNewestConversation(userID: String, completion: @escaping (String?) -> Void) -> ListenerRegistration {
        let db = Firestore.firestore()
        
        let query = db.collection("Conversation")
            .whereFilter(Filter.orFilter([
                Filter.whereField("userA", isEqualTo: userID),
                Filter.whereField("userB", isEqualTo: userID)
            ]))
            .order(by: "latestMessageTime", descending: true)
            .limit(to: 1)

        let listener = query.addSnapshotListener { snapshot, error in
            guard let document = snapshot?.documents.first, error == nil else {
                print("No conversations or error: \(error?.localizedDescription ?? "Unknown error")")
                completion(nil)  // Return nil if no conversation found or if there's an error
                return
            }
            
            let id = document.documentID
            print("Newest conversation ID: \(id)")
            completion(id)  // Return the ID through the completion handler
        }
        
        return listener  // Return the listener
    }
    
    func getIDOfTheOldestConversation(userID: String, completion: @escaping (String?) -> Void) -> ListenerRegistration {
        let db = Firestore.firestore()
        
        let query = db.collection("Conversation")
            .whereFilter(Filter.orFilter([
                Filter.whereField("userA", isEqualTo: userID),
                Filter.whereField("userB", isEqualTo: userID)
            ]))
            .order(by: "latestMessageTime", descending: false)
            .limit(to: 1)

        let listener = query.addSnapshotListener { snapshot, error in
            guard let document = snapshot?.documents.first, error == nil else {
                print("No conversations or error: \(error?.localizedDescription ?? "Unknown error")")
                completion(nil)  // Return nil if no conversation found or if there's an error
                return
            }
            
            let id = document.documentID
            print("Oldest conversation ID: \(id)")
            completion(id)  // Return the ID through the completion handler
        }
        
        return listener  // Return the listener
    }
    
    func listenForRecentMessages(conversationID: String, lastMessage: DocumentSnapshot?, lessMessages: Bool, numberOfMessages: Int = 50, prefixSize: Int = 10, completion: @escaping ([Message], DocumentSnapshot?, Int) -> Void) -> ListenerRegistration {
        let db = Firestore.firestore()
        
        let limit = lessMessages ? numberOfMessages - prefixSize : numberOfMessages // 200 for the first fetch, 150 for subsequent fetches
        
        var query = db.collection("Message")
            .whereField("conversationID", isEqualTo: conversationID)
            .order(by: "time", descending: true)
            .limit(to: limit)
        
        if let lastMessage = lastMessage {
            query = query.start(afterDocument: lastMessage)
        }

        let listener = query.addSnapshotListener(includeMetadataChanges: true) { snapshot, error in
            guard let documents = snapshot?.documents, error == nil else {
                print("Error listening for messages: \(error?.localizedDescription ?? "Unknown error")")
                completion([], nil, 0)
                return
            }

            var messages: [Message] = []
            var newLastMessage: DocumentSnapshot? = nil

            for document in documents {
                let data = document.data()
                let id = document.documentID
                let senderID = data["senderID"] as? String ?? ""
                let receiverID = data["receiverID"] as? String ?? ""
                let text = data["text"] as? String ?? ""
                let likedBy = data["likedBy"] as? [String] ?? []
                let isDelivered = data["isDelivered"] as? Bool ?? false
                let isRead = data["isRead"] as? Bool ?? false
                let replyingToMessageID = data["replyingToMessageID"] as? String ?? ""
                let timeTimestamp = data["time"] as? Timestamp
                let time: Date = timeTimestamp?.dateValue() ?? Date()
                let conversationID = data["conversationID"] as? String ?? ""
                
                let isPending = document.metadata.hasPendingWrites

                let message = Message(
                    id: id,
                    senderID: senderID,
                    receiverID: receiverID,
                    text: text,
                    likedBy: likedBy,
                    isPending: isPending,
                    isDelivered: isDelivered,
                    isRead: isRead,
                    replyingToMessageID: replyingToMessageID,
                    time: time,
                    conversationID: conversationID
                )

                messages.append(message)
                newLastMessage = document
            }

            completion(messages, newLastMessage, prefixSize)
        }

        return listener
    }
    
    func getIDOfTheOldestMessage(conversationID: String, completion: @escaping (String?) -> Void) -> ListenerRegistration {
        let db = Firestore.firestore()
        
        let query = db.collection("Message")
            .whereField("conversationID", isEqualTo: conversationID)
            .order(by: "time", descending: false)
            .limit(to: 1)

        let listener = query.addSnapshotListener { snapshot, error in
            guard let document = snapshot?.documents.first, error == nil else {
                print("No messages or error: \(error?.localizedDescription ?? "Unknown error")")
                completion(nil)  // Return nil if no conversation found or if there's an error
                return
            }
            
            let id = document.documentID
            print("Oldest message ID: \(id)")
            completion(id)  // Return the ID through the completion handler
        }
        
        return listener  // Return the listener
    }
    
    func getIDOfTheNewestMessage(conversationID: String, completion: @escaping (String?) -> Void) -> ListenerRegistration {
        let db = Firestore.firestore()
        
        let query = db.collection("Message")
            .whereField("conversationID", isEqualTo: conversationID)
            .order(by: "time", descending: true)
            .limit(to: 1)

        let listener = query.addSnapshotListener { snapshot, error in
            guard let document = snapshot?.documents.first, error == nil else {
                print("No messages or error: \(error?.localizedDescription ?? "Unknown error")")
                completion(nil)  // Return nil if no conversation found or if there's an error
                return
            }
            
            let id = document.documentID
            print("Newest message ID: \(id)")
            completion(id)  // Return the ID through the completion handler
        }
        
        return listener  // Return the listener
    }
    
    func sendMessage(conversation: Conversation, senderID: String, receiverID: String, text: String) {
        // Create the new message with Firebase-generated ID
        let db = Firestore.firestore()
        let ref = db.collection("Message").document() // Firebase generates the ID here
        let currentTime = Date()
        let newMessage = Message(
            id: ref.documentID, // Use the Firebase-generated ID
            senderID: senderID,
            receiverID: receiverID,
            text: text,
            likedBy: [],
            isPending: true,
            isDelivered: false,
            isRead: false,
            replyingToMessageID: "", // Optional: Could be passed if replying to another message
            time: currentTime,
            conversationID: conversation.id! // Previous message ID is the current latest message in the conversation
        )
        
        // Set the data for the new message document in Firestore
        ref.setData([
            "senderID": newMessage.senderID,
            "receiverID": newMessage.receiverID,
            "text": newMessage.text,
            "likedBy": newMessage.likedBy,
            "isPending": newMessage.isPending,
            "isDelivered": newMessage.isDelivered,
            "isRead": newMessage.isRead,
            "replyingToMessageID": newMessage.replyingToMessageID,
            "time": newMessage.time,
            "conversationID": newMessage.conversationID
        ]) { error in
            if let error = error {
                print("Error sending message: \(error.localizedDescription)")
                return
            }
            print("Message sent successfully!")

            // Update the conversation document with the latest message details
            
            let convRef = db.collection("Conversation").document(conversation.id!)
            
            convRef.getDocument { document, error in
                guard let document = document, document.exists, error == nil else {
                    print("Error fetching conversation: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                
                let data = document.data() ?? [:]
                
                let latestMessageTimeTimestamp = data["latestMessageTime"] as? Timestamp
                let latestMessageTime: Date = latestMessageTimeTimestamp?.dateValue() ?? Date()
                
                if currentTime > latestMessageTime {
                    db.collection("Conversation").document(conversation.id!).updateData([
                        "latestMessageID":ref.documentID,
                        "latestMessageTime": newMessage.time,
                        "latestMessageText": newMessage.text,
                        "latestMessageSender": senderID
                        
                    ]) { error in
                        if let error = error {
                            print("Error updating conversation: \(error.localizedDescription)")
                        } else {
                            print("Conversation updated successfully!")
                        }
                    }
                }
            }
        }
    }
    
    func likeMessage(messageID: String, userID: String) {
        let db = Firestore.firestore()
        let messageRef = db.collection("Message").document(messageID)
        
        messageRef.updateData([
            "likedBy": FieldValue.arrayUnion([userID])
        ]) { error in
            if let error = error {
                print("Error liking message: \(error.localizedDescription)")
            } else {
                print("Message liked successfully!")
            }
        }
    }
    
    func unlikeMessage(messageID: String, userID: String) {
        let db = Firestore.firestore()
        let messageRef = db.collection("Message").document(messageID)
        
        messageRef.updateData([
            "likedBy": FieldValue.arrayRemove([userID])
        ]) { error in
            if let error = error {
                print("Error unliking message: \(error.localizedDescription)")
            } else {
                print("Message unliked successfully!")
            }
        }
    }
    
    private var listener: ListenerRegistration?
    
    func startGlobalMessageListener(for userID: String) {
        // Remove any existing listener to prevent duplicates
        listener?.remove()
        
        let db = Firestore.firestore()
        listener = db.collection("Message")
            .whereField("receiverID", isEqualTo: userID) // Listen for messages sent to this user
            .whereField("isDelivered", isEqualTo: false)  // Only listen for undelivered messages
            .addSnapshotListener { snapshot, error in
                guard let snapshot = snapshot, error == nil else { return }
                
                for document in snapshot.documents {
                    let messageID = document.documentID
                    let data = document.data()
                    let id = document.documentID
                    let senderID = data["senderID"] as? String ?? ""
                    let receiverID = data["receiverID"] as? String ?? ""
                    let text = data["text"] as? String ?? ""
                    let likedBy = data["likedBy"] as? [String] ?? []
                    let isPending = data["isPending"] as? Bool ?? false
                    let isDelivered = data["isDelivered"] as? Bool ?? false
                    let isRead = data["isRead"] as? Bool ?? false
                    let replyingToMessageID = data["replyingToMessageID"] as? String ?? ""
                    let timeTimestamp = data["time"] as? Timestamp
                    let time: Date = timeTimestamp?.dateValue() ?? Date()
                    let conversationID = data["conversationID"] as? String ?? ""
                    
                    let message = Message(
                        id: id,
                        senderID: senderID,
                        receiverID: receiverID,
                        text: text,
                        likedBy: likedBy,
                        isPending: isPending,
                        isDelivered: isDelivered,
                        isRead: isRead,
                        replyingToMessageID: replyingToMessageID,
                        time: time,
                        conversationID: conversationID
                    )
                    
                    // Update Firestore to mark it as delivered
                    db.collection("Message").document(messageID).updateData(["isDelivered": true])
                    
                    // Store unread messages locally
                    DispatchQueue.main.async {
                        self.unreadMessages.append(message)
                    }
                }
            }
    }
      
    func stopGlobalListener() {
        listener?.remove()
        listener = nil
    }

    func followUser(currentUserID: String, targetUserID: String, completion: @escaping (Error?) -> Void) {
        let db = Firestore.firestore()
        
        let currentUserRef = db.collection("Profile").document(currentUserID)
        let targetUserRef = db.collection("Profile").document(targetUserID)
        
        db.runTransaction({ (transaction, errorPointer) -> Any? in
            transaction.updateData([
                "following": FieldValue.arrayUnion([targetUserID]),
                "followingCount": FieldValue.increment(Int64(1))
            ], forDocument: currentUserRef)
            
            transaction.updateData([
                "followers": FieldValue.arrayUnion([currentUserID]),
                "followersCount": FieldValue.increment(Int64(1))
            ], forDocument: targetUserRef)
            
            return nil
        }) { (object, error) in
            completion(error)
        }
    }
    
    func unfollowUser(currentUserID: String, targetUserID: String, completion: @escaping (Error?) -> Void) {
        let db = Firestore.firestore()
        
        let currentUserRef = db.collection("Profile").document(currentUserID)
        let targetUserRef = db.collection("Profile").document(targetUserID)
        
        db.runTransaction({ (transaction, errorPointer) -> Any? in
            transaction.updateData([
                "following": FieldValue.arrayRemove([targetUserID]),
                "followingCount": FieldValue.increment(Int64(-1))
            ], forDocument: currentUserRef)
            
            transaction.updateData([
                "followers": FieldValue.arrayRemove([currentUserID]),
                "followersCount": FieldValue.increment(Int64(-1))
            ], forDocument: targetUserRef)
            
            return nil
        }) { (object, error) in
            completion(error)
        }
    }
    
    func isFollowing(currentUserID: String, targetUserID: String, completion: @escaping (Bool) -> Void) {
        let db = Firestore.firestore()
        let currentUserRef = db.collection("Profile").document(currentUserID)

        currentUserRef.getDocument { document, error in
            guard let document = document, document.exists, let data = document.data() else {
                completion(false)
                return
            }
            
            if let following = data["following"] as? [String] {
                completion(following.contains(targetUserID))
            } else {
                completion(false)
            }
        }
    }
    
    func checkIfUserReviewedProject(userID: String, projectID: String, completion: @escaping (Bool) -> Void) {
        let db = Firestore.firestore()
        
        db.collection("ProjectReview")
            .whereField("user", isEqualTo: userID)
            .whereField("project", isEqualTo: projectID)
            .limit(to: 1)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error checking user review: \(error.localizedDescription)")
                    completion(false)
                    return
                }
                
                let hasReviewed = snapshot?.documents.isEmpty == false
                completion(hasReviewed)
            }
    }
    
    func fetchOlderReviews(for review: ProjectReview, completion: @escaping ([ProjectReview]) -> Void) {
        let db = Firestore.firestore()
        
        db.collection("ProjectReview")
            .whereField("project", isEqualTo: review.project)
            .whereField("user", isEqualTo: review.user)
            .whereField("isLatest", isEqualTo: false)
            .order(by: "date", descending: true)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching older reviews: \(error.localizedDescription)")
                    completion([])
                    return
                }

                let reviews = snapshot?.documents.compactMap { doc -> ProjectReview? in
                    let data = doc.data()
                    let id = doc.documentID
                    let stars = data["stars"] as? Double ?? 0
                    let text = data["text"] as? String ?? ""
                    let subreviewsTopics = data["subreviewsTopics"] as? [String] ?? []
                    let subreviewsStars = data["subreviewsStars"] as? [Double] ?? []
                    let subreviewsTexts = data["subreviewsTexts"] as? [String] ?? []
                    let project = data["project"] as? String ?? ""
                    let user = data["user"] as? String ?? ""
                    let dateTimestamp = data["date"] as? Timestamp
                    let date = dateTimestamp?.dateValue() ?? Date()
                    let isLatest = data["isLatest"] as? Bool ?? false
                    
                    return ProjectReview(
                        id: id,
                        stars: stars,
                        text: text,
                        subreviewsStars: subreviewsStars,
                        subreviewsTopics: subreviewsTopics,
                        subreviewsTexts: subreviewsTexts,
                        project: project,
                        user: user,
                        date: date,
                        isLatest: isLatest
                    )
                } ?? []

                completion(reviews)
            }
    }*/
    
    */
