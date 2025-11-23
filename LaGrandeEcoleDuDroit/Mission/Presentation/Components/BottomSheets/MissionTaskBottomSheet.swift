import SwiftUI

struct AddMissionTaskBottomSheet: View {
    let onAddClick: (String) -> Void
    
    @State private var value: String = ""
    
    var body: some View {
        MissionTaskBottomSheet(
            value: $value,
            buttonEnabled: !value.isEmpty,
            buttonText: stringResource(.add),
            onButtonClick: { onAddClick(value) }
        )
    }
}

struct EditMissionTaskBottomSheet: View {
    let missionTask: MissionTask
    let onEditClick: (MissionTask) -> Void
    
    @State private var value: String
    
    init(
        missionTask: MissionTask,
        onEditClick: @escaping (MissionTask) -> Void
    ) {
        self.missionTask = missionTask
        self.onEditClick = onEditClick
        self.value = missionTask.value
    }
    
    var body: some View {
        MissionTaskBottomSheet(
            value: $value,
            buttonEnabled: !value.isEmpty && value != missionTask.value,
            buttonText: stringResource(.save),
            onButtonClick: {
                onEditClick(missionTask.copy { $0.value = value })
            }
        )
    }
}

private struct MissionTaskBottomSheet: View {
    @Binding var value: String
    let buttonEnabled: Bool
    let buttonText: String
    let onButtonClick: () -> Void
    
    var body: some View {
        VStack {
            TextField(
                "",
                text: $value,
                prompt: Text(stringResource(.enterTask)).foregroundColor(.onSurfaceVariant),
                axis: .vertical
            )
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity,
                alignment: .topLeading
            )
            
            TextButton(
                text: buttonText,
                onClick: onButtonClick,
                enabled: buttonEnabled
            )
            .frame(maxWidth: .infinity, alignment: .bottomTrailing)
        }
        .padding()
        .padding(.top)
    }
}

#Preview {
    MissionTaskBottomSheet(
        value: .constant(""),
        buttonEnabled: true,
        buttonText: stringResource(.save),
        onButtonClick: {}
    )
}
