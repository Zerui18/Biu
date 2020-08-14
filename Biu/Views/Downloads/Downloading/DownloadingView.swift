//
//  DownloadingView.swift
//  Biu
//
//  Created by Zerui Chen on 15/7/20.
//

import SwiftUI

struct DownloadingView: View {
    
    @ObservedObject var model: DownloadsModel = .shared
    
    @FetchRequest(sortDescriptors:
                    [NSSortDescriptor(keyPath: \SavedMedia.timestamp, ascending: false)],
                  predicate: NSPredicate(format: "isDownloaded == false"),
                  animation: .easeIn)
    var downloadingSavedMedias: FetchedResults<SavedMedia>
    
    var body: some View {
        ScrollView {
            ForEach(downloadingSavedMedias) { savedMedia in
                DownloadingItemCell(media: savedMedia)
            }
            .padding(.bottom, 10)
        }
        .navigationBarTitle(Text("正在下载"))
    }
}

struct DownloadingView_Previews: PreviewProvider {
    static var previews: some View {
        DownloadingView()
            .environmentObject(DownloadsModel())
    }
}
