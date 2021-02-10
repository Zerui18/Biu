//
//  DownloadsView.swift
//  Biu
//
//  Created by Zerui Chen on 5/8/20.
//

import SwiftUI
import Grid
import Introspect

struct DownloadsView: View {
    
    @State var selection: String? = "recents"
    
    var body: some View {
        NavigationView {
            List(selection: $selection) {
                if isPad {
                    NavigationLink(
                        destination:
                            DownloadsRecentsGrid()
                                .padding()
                                .navigationBarTitle(Text("下载")),
                        tag: "recents",
                        selection: $selection
                    ) {
                        Image(systemName: "tray")
                        Text("最近下载")
                    }
                    .tag("recents")
                }
                
                NavigationLink(
                    destination: DownloadingView()) {
                    Image(systemName: "square.and.arrow.down.on.square")
                    Text("正在下载")
                }

                NavigationLink(
                    destination: UppersListView()) {
                    Image(systemName: "person.circle")
                    Text("Up主")
                }
                
                // Place grid directly if we're not on pad.
                if !isPad {
                    DownloadsRecentsGrid()
                }
            }
            .introspectTableView {
                $0.tableFooterView = UIView()
            }
            .mapIf(!isPad) {
                $0.navigationBarTitle(Text("下载"))
            }
        }
        .navigationViewStyle(DoubleColumnNavigationViewStyle())
    }
}

struct DownloadsRecentsGrid: View {
    @FetchRequest(sortDescriptors:
                    [NSSortDescriptor(keyPath: \SavedMedia.timestamp, ascending: false)],
                  predicate: NSPredicate(format: "isDownloaded == true"),
                  animation: .easeIn)
    private var downloadedSavedMedias: FetchedResults<SavedMedia>
    
    var body: some View {
        Grid(downloadedSavedMedias) { media in
            MediaCell(media: media)
                .frame(width: 160.p)
                .animation(nil)
                .makeInteractive(media: media)
        }
        .gridStyle(
            ModularGridStyle(columns: .fixed(160.p), rows: .fixed(170.p), spacing: 20.p)
        )
        .padding([.top], 10)
        .padding([.bottom], 100)
    }
}

struct DownloadsView_Previews: PreviewProvider {
    static var previews: some View {
        let context = AppDelegate.shared.persistentContainer.viewContext
        for _ in 1...5 {
            let newMedia = SavedMedia(context: context)
            newMedia.title = "Media 1"
            newMedia.thumbnailURL = URL(string: "https://i0.hdslb.com/bfs/archive/e523109320dde93e7919cbfed4a780bc1a4a81e6.jpg")
            newMedia.owner = SavedUpper(context: context)
            newMedia.owner!.name = "hanser"
            newMedia.owner!.face = URL(string: "http://i2.hdslb.com/bfs/archive/07502ee8927e843b4f5b85b36a66cedde8079eeb.jpg")
            newMedia.isDownloaded = true
        }
        return DownloadsView()
            .colorScheme(.dark)
            .environment(\.managedObjectContext, context)
    }
}
