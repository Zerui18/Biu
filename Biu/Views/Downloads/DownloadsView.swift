//
//  DownloadsView.swift
//  Biu
//
//  Created by Zerui Chen on 5/8/20.
//

import SwiftUI
import Grid

struct DownloadsView: View {
    
    @FetchRequest(sortDescriptors:
                    [NSSortDescriptor(keyPath: \SavedMedia.timestamp, ascending: false)],
                  predicate: NSPredicate(format: "isDownloaded == true"),
                  animation: .easeIn)
    private var downloadedSavedMedias: FetchedResults<SavedMedia>
    
    var body: some View {
        NavigationView {
            List {
                NavigationLink(
                    destination: DownloadingView()) {
                    Image(systemName: "square.and.arrow.down.on.square")
                    Text("正在下载")
                }

                NavigationLink(
                    destination: DownloadingView()) {
                    Image(systemName: "person.circle")
                    Text("Up主")
                }

                Grid(downloadedSavedMedias) { media in
                    DownloadedCell(media: media)
                        .frame(width: 160)
                        .onTapGesture {
                            MediaPlayerModel.shared.play(media)
                        }
                }
                .gridStyle(
                    ModularGridStyle(columns: .fixed(160), rows: .fixed(170), spacing: 20)
                )
                .padding([.top], 10)
                .padding([.bottom], 100)
                .background(Color(.systemBackground))
            }
            .padding([.top, .bottom], 10)
            .navigationBarTitle(Text("下载"))
        }
    }
}

struct DownloadsView_Previews: PreviewProvider {
    static var previews: some View {
        let context = AppDelegate.shared.persistentContainer.viewContext
        for _ in 1...5 {
            let newMedia = SavedMedia(context: context)
            newMedia.title = "Media 1"
            newMedia.owner = SavedUpper(context: context)
            newMedia.owner!.name = "hanser"
            newMedia.owner!.thumbnailURL = URL(string: "http://i2.hdslb.com/bfs/archive/07502ee8927e843b4f5b85b36a66cedde8079eeb.jpg")
            newMedia.isDownloaded = true
        }
        return DownloadsView()
            .colorScheme(.dark)
            .environment(\.managedObjectContext, context)
    }
}
