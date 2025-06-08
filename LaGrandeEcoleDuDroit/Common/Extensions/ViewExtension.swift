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
    
    func toast(
        isPresented: Binding<Bool>,
        message: String,
        position: UnitPoint = .bottom,
        type: ToastType = .initial
    ) -> some View {
        self.modifier(
            ToastModifier(
                isPresented: isPresented,
                message: message,
                position: position,
                type: type
            )
        )
        .animation(Animation.spring(), value: isPresented.wrappedValue)
    }
}

private struct ToastModifier: ViewModifier {
    @Binding var isPresented: Bool
    let message: String
    let position: UnitPoint
    let type: ToastType
    
    func body(content: Content) -> some View {
        ZStack {
            content
            if isPresented {
                switch position {
                    case .center:
                        CenterToast
                    default:
                        BottomToast
                }
            }
        }
    }
    
    var ToastTypeView: some View {
        return switch type {
            case .initial:
                AnyView(
                    Text(message)
                        .font(.body)
                        .padding()
                        .background(.toast)
                        .foregroundColor(.white)
                        .cornerRadius(GedSpacing.small)
                        .padding(.horizontal)
                        .zIndex(100)
                        .task {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                withAnimation {
                                    isPresented = false
                                }
                            }
                        }
                )
            case .loading:
                AnyView(
                    ZStack {
                        ProgressView(message)
                            .progressViewStyle(ToastProgressViewStyle())
                    }
                    .padding()
                    .background(.toast)
                    .foregroundColor(.white)
                    .cornerRadius(GedSpacing.small)
                    .padding(.horizontal)
                    .zIndex(100)
                )
            }
    }

    
    var CenterToast: some View {
        VStack {
            ToastTypeView
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
    
    var BottomToast: some View {
        VStack {
            Spacer()
            ToastTypeView
        }
        .padding(.bottom, 50)
    }

}

enum ToastType {
    case initial
    case loading
}

private struct ToastProgressViewStyle: ProgressViewStyle {
    func makeBody(configuration: Configuration) -> some View {
     ProgressView(configuration)
            .tint(.white)
    }
}
