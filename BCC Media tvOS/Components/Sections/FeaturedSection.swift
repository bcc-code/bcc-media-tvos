import SwiftUI

struct FeaturedButton: ButtonStyle {
    let focused: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.zero)
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(.white, lineWidth: configuration.isPressed || focused ? 4 : 0))
            .scaleEffect(configuration.isPressed ? 0.98 : focused ? 1.02 : 1)
            .animation(
                configuration.isPressed || focused ? .easeOutCirc(duration: 0.4) : .easeOutCirc(duration: 0.2),
                value: configuration.isPressed || focused
            )
    }
}

struct FeaturedCard: View {
    var item: Item
    var clicked: () async -> Void

    @State var loading = false
    @FocusState var isFocused: Bool

    var body: some View {
        Button(action: {
            Task {
                withAnimation(.easeOut(duration: 0.25)) {
                    loading.toggle()
                }
                await clicked()
                withAnimation(.easeOut(duration: 0.25)) {
                    loading.toggle()
                }
            }
        }) {
            ItemImage(item.image)
                .mask(LinearGradient(gradient: Gradient(colors: [.black, .black, .clear]), startPoint: .top, endPoint: .bottom))
                .cornerRadius(10)
                .padding(.zero)
                .overlay(
                    VStack(alignment: .leading, spacing: 20) {
                        Text(item.title).font(.barlowTitle)
                    }.padding([.bottom, .horizontal], 50),

                    alignment: .bottomLeading
                ).overlay(
                    LockView(locked: item.locked)
                ).overlay(LoadingOverlay(loading))
        }
        .buttonStyle(FeaturedButton(focused: isFocused))
        .padding(0)
        .focused($isFocused)
    }
}

struct FeaturedSection: View {
    var title: String?
    var items: [Item]
    var clickItem: SectionClickItem

    var withLiveElement: Bool

    init(_ title: String?, _ items: [Item], clickItem: @escaping SectionClickItem, withLiveElement: Bool = false) {
        self.title = title
        self.items = items
        self.clickItem = clickItem
        self.withLiveElement = withLiveElement && authenticationProvider.isAuthenticated()
    }

    @FocusState var liveFocused: Bool

    var body: some View {
        VStack {
            ScrollView(.horizontal) {
                LazyHStack(alignment: .top, spacing: 20) {
                    ForEach(items.indices, id: \.self) { index in
                        FeaturedCard(item: items[index]) {
                            await clickItem(items[index])
                        }
                    }.frame(width: 1000)
                }.padding(100)
            }.padding(-100)
                .frame(width: 1760, height: withLiveElement ? 600 : 800)
        }
    }
}

struct FeaturedSection_Previews: PreviewProvider {
    static var previews: some View {
        FeaturedSection(nil, previewItems) { _ in
        }
    }
}
