//
//  SectionItemButtom.swift
//  BCC Media
//
//  Created by Fredrik Vedvik on 16/05/2023.
//

import SwiftUI

struct SectionItemButton: ButtonStyle {
    let focused: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.zero)
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(.white, lineWidth: configuration.isPressed || focused ? 6 : 0))
            .cornerRadius(10)
            .scaleEffect(configuration.isPressed ? 1.02 : focused ? 1.05 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed || focused)
    }
}

struct SectionItemCard: View {
    var item: Item
    var onClick: () async -> Void
    var width: CGFloat
    var height: CGFloat

    init(_ item: Item, width: CGFloat, height: CGFloat, onClick: @escaping () async -> Void) {
        self.item = item
        self.width = width
        self.height = height
        self.onClick = onClick
    }
    
    func clearProgress() {
        apolloClient.perform(mutation: API.SetEpisodeProgressMutation(id: item.id, progress: .none))
    }

    @State private var loading = false
    @FocusState var isFocused: Bool
    
    @State private var showOptions = false

    var body: some View {
        if let image = item.image {
            VStack(alignment: .leading, spacing: 20) {
                Button {
                    if showOptions {
                        return
                    }
                    Task {
                        withAnimation(.easeInOut(duration: 0.1)) {
                            loading.toggle()
                        }
                        await onClick()
                        withAnimation(.easeInOut(duration: 0.1)) {
                            loading.toggle()
                        }
                    }
                } label: {
                    ItemImage(image)
                        .frame(width: width, height: height)
                        .cornerRadius(10)
                        .overlay(
                            ZStack {
                                LockView(locked: item.locked)
                                LoadingOverlay(loading)
                            },
                            alignment: .top
                        )
                        .overlay(
                            ProgressBar(item: item),
                            alignment: .bottom
                        )
                }
                .simultaneousGesture(
                    LongPressGesture(minimumDuration: 1)
                        .onEnded { _ in
                            if item.type == .episode {
                                showOptions = true
                            }
                        }
                ).confirmationDialog("episodes_options", isPresented: $showOptions, titleVisibility: .visible) {
                    Button("episodes_clearProgress", role: .destructive) {
                        clearProgress()
                    }
                }
                .buttonStyle(SectionItemButton(focused: isFocused))
                .accessibilityLabel(item.title)
                .focused($isFocused)
                ItemTitle(item)
            }.frame(width: width)
        }
    }
}
