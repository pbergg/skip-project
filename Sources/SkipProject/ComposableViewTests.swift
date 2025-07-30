//
//  SwiftUIView.swift
//  skip-project
//
//  Created by Paul Berg on 30/07/2025.
//

import SwiftUI

struct DirectViewsTests: View {
    @State var didTapButton = false

    var body: some View {
        VStack {
            Text(didTapButton ? "✅ Tapped!" : "❌ Not tapped")
            #if SKIP
            ComposeView { ctx in
                NewViewTests {
                    didTapButton ? didTapButton = false : didTapButton = true
                }
                .Compose(context: ctx)
            }
            #else
            Text("Hello iOS")
            #endif
        }
        .onChange(of: didTapButton) { oldValue, newValue in
            print("Button state change detected: \(newValue.description)")
        }
    }
}

#if SKIP
struct NewViewTests: ContentComposer {
    let onComplete: () -> Void
    
    @Composable func Compose(context: ComposeContext) {
        DirectView("Tomas") { str in
            print(str)
            onComplete()
        }
    }
}
#endif

func printStuff() {
    print("Stuff")
}
