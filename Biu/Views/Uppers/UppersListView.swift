//
//  UppersListView.swift
//  Biu
//
//  Created by Zerui Chen on 11/8/20.
//

import SwiftUI
import Introspect

struct UppersListView: View {
    
    @FetchRequest(sortDescriptors:
                    [NSSortDescriptor(keyPath: \SavedUpper.name, ascending: false)],
                  animation: .easeIn)
    var uppers: FetchedResults<SavedUpper>
    
    var body: some View {
        List {
            let groupedAndSortedUppers = uppers.groupedAndSorted()
            ForEach(groupedAndSortedUppers, id: \.0) { (letter, uppers) in
                Section(header: Text(String(letter))) {
                    ForEach(uppers) { upper in
                        NavigationLink(destination: UpperSpaceView(upper: upper)) {
                            UppersListCell(upper: upper)
                                .frame(maxWidth: .infinity)
                                .padding([.top, .bottom], 7)
                        }
                    }
                }
            }
            
            Color.clear
                .frame(height: 100)
        }
        .introspectTableView {
            $0.tableFooterView = UIView()
        }
        .navigationBarTitle(Text("Up主"))
    }
}

struct UppersListView_Previews: PreviewProvider {
    
    static func uppers() -> [SavedUpper] {
        let context = AppDelegate.shared.persistentContainer.viewContext
        let upper = SavedUpper(context: context)
        upper.name = "hanser"
        upper.face = URL(string: "https://i1.hdslb.com/bfs/face/28f95c383f2805dbed32e93007c91ccfda28775f.jpg@96w_96h.jpg")
        let upper2 = SavedUpper(context: context)
        upper2.name = "泠鸢yousa"
        upper2.face = URL(string: "https://i1.hdslb.com/bfs/face/28f95c383f2805dbed32e93007c91ccfda28775f.jpg@96w_96h.jpg")
        let upper3 = SavedUpper(context: context)
        upper3.name = "花园Serena"
        upper3.face = URL(string: "https://i1.hdslb.com/bfs/face/28f95c383f2805dbed32e93007c91ccfda28775f.jpg@96w_96h.jpg")
        let upper4 = SavedUpper(context: context)
        upper4.name = "さ"
        upper4.face = URL(string: "https://i1.hdslb.com/bfs/face/28f95c383f2805dbed32e93007c91ccfda28775f.jpg@96w_96h.jpg")
        return [
            upper,
            upper2,
            upper3,
            upper4
        ]
    }
    
    static var previews: some View {
        return UppersListView()
            .colorScheme(.dark)
    }
}
