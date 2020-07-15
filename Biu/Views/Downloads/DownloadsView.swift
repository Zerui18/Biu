//
//  DownloadsView.swift
//  Biu
//
//  Created by Zerui Chen on 15/7/20.
//

import SwiftUI

struct DownloadsView: View {
    
    @EnvironmentObject var model: DownloadsModel
    
    @FetchRequest(sortDescriptors:
                    [NSSortDescriptor(keyPath: \SavedMedia.timestamp, ascending: true)],
                  animation: .easeIn)
    var savedMedias: FetchedResults<SavedMedia>
    
    var body: some View {
        NavigationView {
            ScrollView {
                Group {
                    let downloading = savedMedias.filter { model.isDownloading(media: $0) }
                    Section(header:
                        Text("正在下载")
                            // Align leading.
                            .fixedSize()
                            .frame(maxWidth: .infinity, alignment: .leading)
                    ) {
                        ForEach(downloading) { (savedMedia: SavedMedia) in
                            DownloadsItemCell(media: savedMedia,
                                              downloadStatePublisher: model.downloadState(forMedia: savedMedia)!)
                        }
                    }
                    
                    Section(header:
                        Text("已经下载")
                            // Align leading.
                            .fixedSize()
                            .frame(maxWidth: .infinity, alignment: .leading)
                    ) {
                        ForEach(downloading) { (savedMedia: SavedMedia) in
                            DownloadsItemCell(media: savedMedia,
                                              downloadStatePublisher: model.downloadState(forMedia: savedMedia)!)
                        }
                    }
                }
                .padding()
            }
            .navigationBarTitle(Text("下载"))
        }
    }
}

struct DownloadsView_Previews: PreviewProvider {
    static var previews: some View {
        DownloadsView()
            .environmentObject(DownloadsModel())
    }
}
