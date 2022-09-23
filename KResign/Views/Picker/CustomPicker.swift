//
//  CustomPicker.swift
//  KResign
//
//  Created by Crazy凡 on 2022/9/23.
//

import SwiftUI

extension Text {
    static func `default`() -> some View {
        Text("CurrentIcon").foregroundColor(.blue)
    }

    static func current() -> some View {
        Text("CurrentIcon").foregroundColor(.green)
    }

    static func both() -> some View {
        Text("CurrentIcon")
            .overlay(
                VStack(spacing: .zero) {
                    Color.blue
                    Color.green
                }.mask(Text("CurrentIcon"))
            )
    }
}

/// Picker provided by SwiftUI can cause stalling.
struct CustomPicker<Item, Content>: View where Item: Hashable, Content: View {
    var `default`: Item?
    @Binding var selection: Item
    var items: [Item]
    var content: (Item) -> Content

    @State private var isSheetShow: Bool = false
    @State private var howverItem: Item?

    var body: some View {
        HStack {
            Button {
                isSheetShow.toggle()
            } label: {
                itemView(of: selection, showIcon: true)
            }
        }
        .popover(isPresented: $isSheetShow, attachmentAnchor: .rect(.bounds)) {
            popoverView()
        }
    }
}

private extension CustomPicker {
    func popoverView() -> some View {
        ScrollView {
            ScrollViewReader { value in
                VStack(spacing: 2) {
                    ForEach(items, id: \.self) { item in
                        itemView(of: item)
                            .padding(EdgeInsets(top: 1, leading: 5, bottom: 2, trailing: 4))
                            .contentShape(RoundedRectangle(cornerRadius: 5))
                            .tag(item)
                            .id(item)
                            .onTapGesture {
                                isSheetShow.toggle()
                                selection = item
                            }
                            .onHover { howverItem = $0 ? item : nil}
                            .background(
                                howverItem == item ? Color.blue : Color.clear,
                                alignment: .center
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 5))

                    }
                    .onAppear {
                        value.scrollTo(selection, anchor: .center)
                    }
                }
            }
            .padding()
            .font(.system(size: 14))
        }
    }

    func itemView(of item: Item, showIcon: Bool = false) -> some View {
        HStack(spacing: 0) {
            switch (item, item) {
            case (self.default, self.selection): Text.both()
            case (self.default, _): Text.default()
            case (self.selection, _): Text.current()
            default: Text("")
            }
            content(item)
            Spacer()

            if showIcon {
                Image("chevron.up.chevron.down")
            }
        }
    }
}

struct CPicker_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            CustomPicker(default: 0, selection: .constant(0), items: Array(0...10)) {
                Text("\($0)")
            }
            CustomPicker(default: 0, selection: .constant(1), items: Array(0...10)) {
                Text("\($0)")
            }

            CustomPicker(selection: .constant(0), items: Array(0...10)) {
                Text("\($0)")
            }
            CustomPicker(selection: .constant(1), items: Array(0...10)) {
                Text("\($0)")
            }
        }
    }
}
