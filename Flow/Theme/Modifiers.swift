import SwiftUI

extension View {
    /// Card surface. Uses Liquid Glass on iOS 26 (when built with the iOS 26 SDK),
    /// and a material with a hairline border everywhere else.
    @ViewBuilder
    func flowCard(cornerRadius: CGFloat = 24) -> some View {
        #if compiler(>=6.2)
        if #available(iOS 26.0, *) {
            self.glassEffect(.regular, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        } else {
            self.materialCard(cornerRadius: cornerRadius)
        }
        #else
        self.materialCard(cornerRadius: cornerRadius)
        #endif
    }

    /// Marks a view as the source of an iOS 18 zoom transition. No-op on iOS 17.
    @ViewBuilder
    func matchedZoomSource(id: some Hashable, in namespace: Namespace.ID) -> some View {
        if #available(iOS 18.0, *) {
            self.matchedTransitionSource(id: id, in: namespace)
        } else {
            self
        }
    }

    /// Applies the iOS 18 zoom navigation transition to a destination. No-op on iOS 17.
    @ViewBuilder
    func matchedZoomTransition(sourceID: some Hashable, in namespace: Namespace.ID) -> some View {
        if #available(iOS 18.0, *) {
            self.navigationTransition(.zoom(sourceID: sourceID, in: namespace))
        } else {
            self
        }
    }
}

private extension View {
    func materialCard(cornerRadius: CGFloat) -> some View {
        self
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(.white.opacity(0.18), lineWidth: 1)
            }
    }
}
