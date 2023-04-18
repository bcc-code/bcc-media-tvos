//
//  PosterSection.swift
//  BCC Media
//
//  Created by Fredrik Vedvik on 17/04/2023.
//

import SwiftUI

struct PosterSection: View {
    var title: String?
    var items: [Item]
    
    var body: some View {
        VStack {
            if let t = title {
                Text(t).font(.title3).frame(maxWidth: .infinity, alignment: .leading)
            }
            ScrollView(.horizontal) {
                LazyHStack(alignment: .top, spacing: 20) {
                    ForEach(items) { item in
                        if let img = item.image {
                            VStack(alignment: .leading, spacing: 20) {
                                NavigationLink {
                                    item
                                } label: {
                                    AsyncImage(url: URL(string: img + "?w=500&h=750&fit=crop&crop=faces")) { image in
                                        image.renderingMode(.original)
                                    } placeholder: {
                                        ProgressView()
                                    }.frame(width: 500, height: 750).cornerRadius(10)
                                }.buttonStyle(.card)
                                VStack(alignment: .leading) {
                                    Text(item.title)
                                }
                            }.frame(width: 500)
                        }
                    }
                }.padding(100)
            }.padding(-100)
        }
    }
}

struct PosterSection_Previews: PreviewProvider {
    static var previews: some View {
        PosterSection(items: previewItems)
    }
}
