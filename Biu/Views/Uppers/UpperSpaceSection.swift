//
//  UpperSpaceSection.swift
//  Biu
//
//  Created by Zerui Chen on 15/8/20.
//

import SwiftUI

struct UpperSpaceSection<Content: View, Media: MediaRepresentable & Identifiable>: View {
    
    init(title: String, media: [Media], @ViewBuilder fullPage: @escaping () -> Content) {
        self.title = title
        self.media = media
        self.fullPage = fullPage
    }
    
    let title: String
    let fullPage: () -> Content
    let media: [Media]
        
    var body: some View {
        VStack {
            NavigationLink(destination: fullPage()) {
                HStack {
                    Text(title)
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding([.leading])
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .padding(.trailing)
                }
                .padding([.top, .bottom], 5)
            }
            .accentColor(Color(.label))
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    Color.clear
                        .frame(width: 0)
                    ForEach(media) { media in
                        MediaCell(media: media, showAuthor: false)
                            .frame(minWidth: 130, minHeight: 145)
                            .makeInteractive(media: media)
                    }
                    
                    Color.clear
                        .frame(width: 0)
                }
            }
        }
    }
}

//struct UpperSpaceSection_Previews: PreviewProvider {
//    static var previews: some View {
//        UpperSpaceSection()
//    }
//}
