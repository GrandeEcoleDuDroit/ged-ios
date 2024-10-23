import SwiftUI

struct LoadingButton: View {
    let label: String
    let onClick: () -> Void
    @Binding var isLoading: Bool
    
    var body: some View {
        Button(action: onClick) {
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .frame(maxWidth: .infinity)
                    .padding(10)
                    .foregroundColor(.white)
                    .background(Color(GedColor.primary))
                    .cornerRadius(30)

            } else {
                Text(label)
                    .frame(maxWidth: .infinity)
                    .padding(10)
                    .foregroundColor(.white)
                    .background(Color(GedColor.primary))
                    .cornerRadius(30)
            }
        }
        .disabled(isLoading)
    }
}

struct BackButton: View {
    let text: String?
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: "chevron.left")
                    .font(.title2)
                    .tint(.black)
                if text != nil {
                    Text(text!)
                        .tint(.black)
                }
            }
            
        }
    }
    
    init(text: String? = nil, action: @escaping () -> Void) {
        self.text = text
        self.action = action
    }
    
}

#Preview {
    var isLoading: Binding<Bool> = .constant(false)
    
    VStack(spacing: GedSpacing.verylLarge) {
        LoadingButton(
            label: "Loading button",
            onClick: {},
            isLoading : isLoading
        )
        
        Divider()
            .overlay(.black)
        
        BackButton(text: "Retour", action: {})
    }.padding()
}
