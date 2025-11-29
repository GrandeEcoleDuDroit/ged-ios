import SwiftUI

struct AddMissionTaskBottomSheet: View {
    let onAddTaskClick: (String) -> Void
    let onCancelClick: () -> Void
    
    @State private var createEnbaled = false
    
    var body: some View {
        MissionTaskBottomSheet(
            initialValue: "",
            onValueChange: { value in
                createEnbaled = !value.isEmpty
            },
            enabled: createEnbaled,
            buttonText: stringResource(.add),
            onButtonClick: { onAddTaskClick($0) },
            onCancelClick: onCancelClick
        )
    }
}

struct EditMissionTaskBottomSheet: View {
    let missionTask: MissionTask
    let onEditTaskClick: (MissionTask) -> Void
    let onCancelClick: () -> Void
    
    init(
        missionTask: MissionTask,
        onEditTaskClick: @escaping (MissionTask) -> Void,
        onCancelClick: @escaping () -> Void
    ) {
        self.missionTask = missionTask
        self.onEditTaskClick = onEditTaskClick
        self.onCancelClick = onCancelClick
    }
    
    @State private var editEnabled = false
    
    var body: some View {
        MissionTaskBottomSheet(
            initialValue: missionTask.value,
            onValueChange: { value in
                editEnabled = !value.isEmpty && value != missionTask.value
            },
            enabled: editEnabled,
            buttonText: stringResource(.save),
            onButtonClick: { value in
                onEditTaskClick(missionTask.copy { $0.value = value })
            },
            onCancelClick: onCancelClick
        )
    }
}

private struct MissionTaskBottomSheet: View {
    let initialValue: String
    let onValueChange: (String) -> Void
    let enabled: Bool
    let buttonText: String
    let onButtonClick: (String) -> Void
    let onCancelClick: () -> Void
    
    @State private var value: String
    
    init(
        initialValue: String,
        onValueChange: @escaping (String) -> Void,
        enabled: Bool,
        buttonText: String,
        onButtonClick: @escaping (String) -> Void,
        onCancelClick: @escaping () -> Void
    ) {
        self.initialValue = initialValue
        self.onValueChange = onValueChange
        self.enabled = enabled
        self.buttonText = buttonText
        self.onButtonClick = onButtonClick
        self.onCancelClick = onCancelClick
        
        self.value = initialValue
    }
    
    var body: some View {
        NavigationStack {
            TransparentTextFieldArea(
                initialText: initialValue,
                onTextChange: {
                    onValueChange($0)
                    value = $0.take(MissionConstants.maxTaskLength)
                    return value
                },
                placeHolder: stringResource(.enterTask)
            )
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity,
                alignment: .topLeading
            )
            .padding(.horizontal, Dimens.smallMediumPadding)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: onCancelClick) {
                        Text(stringResource(.cancel))
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { onButtonClick(value) }) {
                        if !enabled {
                            Text(stringResource(.save))
                        } else {
                            Text(stringResource(.save))
                                .foregroundColor(.gedPrimary)
                        }
                    }
                    .disabled(!enabled)
                }
            }
        }
    }
}

#Preview {
    MissionTaskBottomSheet(
        initialValue: "",
        onValueChange: { _ in },
        enabled: true,
        buttonText: stringResource(.save),
        onButtonClick: { _ in },
        onCancelClick: {}
    )
    .environment(\.managedObjectContext, GedDatabaseContainer.preview.container.viewContext)
}
