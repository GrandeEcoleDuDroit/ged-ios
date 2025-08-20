import SwiftUI

extension View {
    func onClick(isClicked: Binding<Bool>, action: @escaping () -> Void) -> some View {
        self
            .contentShape(Rectangle())
            .background(
                Color(.click)
                    .opacity(isClicked.wrappedValue ? 1 : 0)
                    .animation(.easeInOut(duration: 0.1), value: isClicked.wrappedValue)
            )
            .onTapGesture {
                isClicked.wrappedValue = true
                action()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    isClicked.wrappedValue = false
                }
            }
    }
    
    func onClick(
        isClicked: Binding<Bool>,
        action: @escaping () -> Void,
        backgroundColor: Color = .click
    ) -> some View {
        self
            .contentShape(Rectangle())
            .background(
                Color(UIColor(backgroundColor))
                    .opacity(isClicked.wrappedValue ? 1 : 0)
                    .animation(.easeInOut(duration: 0.1), value: isClicked.wrappedValue)
            )
            .onTapGesture {
                isClicked.wrappedValue = true
                action()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    isClicked.wrappedValue = false
                }
            }
    }
    
    func onLongClick(isClicked: Binding<Bool>, action: @escaping () -> Void) -> some View {
        self
            .contentShape(Rectangle())
            .background(
                Color(.click)
                    .opacity(isClicked.wrappedValue ? 1 : 0)
                    .animation(.easeInOut(duration: 0.1), value: isClicked.wrappedValue)
            )
            .onLongPressGesture(pressing: { isClicked.wrappedValue = $0 }) {
                isClicked.wrappedValue = true
                action()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    isClicked.wrappedValue = false
                }
            }
    }
    
    func clickEffect(isClicked: Binding<Bool>) -> some View {
        self
            .contentShape(Rectangle())
            .simultaneousGesture(
                TapGesture().onEnded {
                    isClicked.wrappedValue = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        isClicked.wrappedValue = false
                    }
                }
            )
            .background(
                Color(.click)
                    .opacity(isClicked.wrappedValue ? 1 : 0)
                    .animation(.easeInOut(duration: 0.1), value: isClicked.wrappedValue)
            )
    }
    
    func loading(_ isLoading: Bool) -> some View {
        self
            .disabled(isLoading)
            .opacity(isLoading ? 0.5 : 1)
            .overlay {
                if isLoading {
                    ProgressView(getString(.loading))
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(GedSpacing.small)
                        .shadow(radius: 1)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                        .ignoresSafeArea()
                }
            }
    }
}
