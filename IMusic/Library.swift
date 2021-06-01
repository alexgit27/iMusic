//
//  Library.swift
//  IMusic
//
//  Created by Alexandr on 31.03.2021.
//

import SwiftUI
import URLImage
 
struct Library: View {
   @State var tracks = UserDefaults.standard.getTracks()
   @State private var showAlert = false
   @State private var track: SearchViewModel.Cell!
    
    var tabBarDelegate: MainTabBarControllerDelegate?
    
    var body: some View {
        NavigationView {
            VStack {
                GeometryReader { geometry in
                    HStack(spacing: 20) {
                        Button(action: {
                            self.track = tracks[0]
                            self.tabBarDelegate?.maximazeTrackViewController(viewModel: track)
                        }, label: {
                            Image(systemName: "play.fill")
                                .frame(width: geometry.size.width / 2 - 10 , height: 50)
                                .accentColor(Color.init(#colorLiteral(red: 0.9921568627, green: 0.1764705882, blue: 0.3333333333, alpha: 1)))
                                .background(Color.init(#colorLiteral(red: 0.9531342387, green: 0.9490900636, blue: 0.9562709928, alpha: 1)))
                                .cornerRadius(10)
                        })
                        Button(action: {
                            self.tracks = UserDefaults.standard.getTracks()
                        }, label: {
                            Image(systemName: "arrow.2.circlepath")
                                .frame(width: geometry.size.width / 2 - 16 , height: 50)
                                .accentColor(Color.init(#colorLiteral(red: 0.9921568627, green: 0.1764705882, blue: 0.3333333333, alpha: 1)))
                                .background(Color.init(#colorLiteral(red: 0.9531342387, green: 0.9490900636, blue: 0.9562709928, alpha: 1)))
                                .cornerRadius(10)
                        })
                    }
                }.padding().frame(height: 65)
                Divider().padding(.leading).padding(.trailing)

                List {
                    ForEach(tracks) { track in
                        LibraryCell(cell: track).gesture(LongPressGesture().onEnded({_ in
                                                                                        self.track = track
                                                                                        self.showAlert = true })
                                                            .simultaneously(with: TapGesture().onEnded({ (_) in
                                                                let keyWindow = UIApplication.shared.connectedScenes.filter ({
                                                                    $0.activationState == .foregroundActive
                                                                }).map({$0 as? UIWindowScene}).compactMap({$0}).first?.windows.filter({$0.isKeyWindow}).first
                                                                let tabBarVC = keyWindow?.rootViewController as? MainTabBarController
                                                                tabBarVC?.trackDetailView.delegate = self
                                                                self.track = track
                                                                self.tabBarDelegate?.maximazeTrackViewController(viewModel: self.track)
                                                            })))
                    }.onDelete(perform: delete)
                }
                
            }
            .actionSheet(isPresented: $showAlert, content: {
                ActionSheet(title: Text("Are sure you want delete this track"), buttons: [.destructive(Text("Delete"), action: {
                    delete(track: self.track)
                }), .cancel()])
            })
                .navigationBarTitle("Library")
        }.background(Color.init(#colorLiteral(red: 0.9921568627, green: 0.1764705882, blue: 0.3333333333, alpha: 1)))
        
    }
    
    func delete(at offset: IndexSet) {
        tracks.remove(atOffsets: offset)
        if let savedData = try? NSKeyedArchiver.archivedData(withRootObject: tracks, requiringSecureCoding: false) {
            let defaults = UserDefaults.standard
            defaults.setValue(savedData, forKey: UserDefaults.favouriteTrackKey)
        }
    }
    
    func delete(track: SearchViewModel.Cell) {
        let index = tracks.firstIndex(of: track)
        guard let myIndex = index else { return }
        tracks.remove(at: myIndex)
        if let savedData = try? NSKeyedArchiver.archivedData(withRootObject: tracks, requiringSecureCoding: false) {
            let defaults = UserDefaults.standard
            defaults.setValue(savedData, forKey: UserDefaults.favouriteTrackKey)
        }
    }
}


struct LibraryCell: View {
    var cell: SearchViewModel.Cell

    
    var body: some View {
        HStack {
            URLImage(url: URL(string: cell.iconUrlString ?? "")!, content: { image in
                                         image
                                             .resizable()
                                            .frame(width: 60, height: 60)
                                            .cornerRadius(2.0)
                                     })

            VStack(alignment: .leading) {
            Text("\(cell.trackName)")
            Text("\(cell.artistName)")
            }
        }
    }
}

struct Library_Previews: PreviewProvider {
    static var previews: some View {
        Library()
    }
}

extension Library: TrackMmovingDelegate {
    func moveBackTrack() -> SearchViewModel.Cell? {
        let index = tracks.firstIndex(of: track)
        guard let myIndex = index else { return nil }
        var nextTrack: SearchViewModel.Cell
        if myIndex - 1 == -1 {
            nextTrack = tracks[tracks.count - 1]
        } else {
            nextTrack = tracks[myIndex - 1]
        }
        self.track = nextTrack
        return nextTrack
    }
    
    func moveForwardTrack() -> SearchViewModel.Cell? {
        let index = tracks.firstIndex(of: track)
        guard let myIndex = index else { return nil }
        var nextTrack: SearchViewModel.Cell
        if myIndex + 1 == tracks.count {
            nextTrack = tracks[0]
        } else {
            nextTrack = tracks[myIndex + 1]
        }
        self.track = nextTrack
        return nextTrack
    }
    
    
}
