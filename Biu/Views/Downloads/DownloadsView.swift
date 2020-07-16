//
//  DownloadsView.swift
//  Biu
//
//  Created by Zerui Chen on 15/7/20.
//

import SwiftUI

struct DownloadsView: View {
    
    @ObservedObject var model: DownloadsModel = .shared
    
    @FetchRequest(sortDescriptors:
                    [NSSortDescriptor(keyPath: \SavedMedia.timestamp, ascending: true)],
                  predicate: NSPredicate(format: "isDownloaded == false"),
                  animation: .easeIn)
    var notDownloadedSavedMedias: FetchedResults<SavedMedia>
    
    @FetchRequest(sortDescriptors:
                    [NSSortDescriptor(keyPath: \SavedMedia.timestamp, ascending: true)],
                  predicate: NSPredicate(format: "isDownloaded == true"),
                  animation: .easeIn)
    var downloadedSavedMedias: FetchedResults<SavedMedia>
    
    var body: some View {
        NavigationView {
            ScrollView {
                Group {
                    
                    // 正在下载
                    if !notDownloadedSavedMedias.isEmpty {
                        Section(header:
                            Text("正在下载")
                                .bold()
                                // Align leading.
                                .fixedSize()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.bottom)
                        ) {
                            ForEach(notDownloadedSavedMedias) { (savedMedia: SavedMedia) in
                                DownloadsItemCell(media: savedMedia)
                            }
                            .padding(.bottom, 10)
                        }
                        
                        Spacer()
                            .frame(height: 30)
                    }
                    
                    // 已经下载
                    if !downloadedSavedMedias.isEmpty {
                        Section(header:
                            Text("已经下载")
                                .bold()
                                // Align leading.
                                .fixedSize()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.bottom)
                        ) {
                            ForEach(downloadedSavedMedias) { (savedMedia: SavedMedia) in
                                DownloadsItemCell(media: savedMedia)
                                    .onTapGesture {
                                        MediaPlayerModel.shared.play(savedMedia)
                                    }
                            }
                            .padding(.bottom, 10)
                        }
                        
                        Spacer()
                            .frame(height: 80)
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
