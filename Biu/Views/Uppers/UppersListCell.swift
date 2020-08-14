//
//  UppersListCell.swift
//  Biu
//
//  Created by Zerui Chen on 11/8/20.
//

import SwiftUI

struct UppersListCell: View {
    
    init(upper: SavedUpper) {
        self.upper = upper
        self.thumbnailImage = .init(url: upper.face!,
                                    placeholder: UIImage())
    }
    
    let upper: SavedUpper
    
    @ObservedObject
    var thumbnailImage: FetchImage
    
    var body: some View {
        HStack {
            thumbnailImage.image
                .frame(width: 55, height: 55)
                .background(Color(.secondarySystemFill))
                .cornerRadius(30, antialiased: true)
                .padding([.leading, .trailing], 10)
            
            Text(upper.name!)
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct AuthorsListCell_Previews: PreviewProvider {
    static var previews: some View {
        let context = AppDelegate.shared.persistentContainer.viewContext
        let upper = SavedUpper(context: context)
        upper.name = "hanser"
        upper.face = URL(string: "https://i1.hdslb.com/bfs/face/28f95c383f2805dbed32e93007c91ccfda28775f.jpg@96w_96h.jpg")
        return UppersListCell(upper: upper)
            .previewLayout(.fixed(width: 375, height: 70))
    }
}
