import SwiftUI

struct AddMissionTaskView: View {
    let onAddTaskClick: (String) -> Void
    
    @State private var value: String = ""
    private var createEnbaled: Bool {
        !value.isEmpty
    }
    
    var body: some View {
        MissionTaskView(
            value: $value,
            enabled: createEnbaled,
            confirmButtonText: stringResource(.add),
            onConfirmButtonClick: {
                onAddTaskClick(value)
            }
        )
        .navigationTitle(stringResource(.addTask))
    }
}

struct EditMissionTaskView: View {
    let missionTask: MissionTask
    let onSaveTaskClick: (MissionTask) -> Void
    
    @State private var value: String
    
    init(
        missionTask: MissionTask,
        onSaveTaskClick: @escaping (MissionTask) -> Void
    ) {
        self.missionTask = missionTask
        self.onSaveTaskClick = onSaveTaskClick
        self.value = missionTask.value
    }
    
    private var editEnabled: Bool {
        !value.isEmpty && value != missionTask.value
    }
    
    var body: some View {
        MissionTaskView(
            value: $value,
            enabled: editEnabled,
            confirmButtonText: stringResource(.save),
            onConfirmButtonClick: {
                onSaveTaskClick(missionTask.copy { $0.value = value })
            }
        )
        .navigationTitle(stringResource(.editTask))
    }
}

private struct MissionTaskView: View {
    @Binding var value: String
    let enabled: Bool
    let confirmButtonText: String
    let onConfirmButtonClick: () -> Void
    
    @FocusState private var focusState: MissionTaskField?
    
    var body: some View {
        TransparentTextFieldArea(
            stringResource(.enterTask),
            text: $value,
            focusState: _focusState,
            field: .missionTaskContent
        )
        .onChange(of: value) {
            value = $0.take(MissionUtilsPresentation.maxTaskLength)
        }
        .onAppear {
            focusState = .missionTaskContent
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity,
            alignment: .topLeading
        )
        .padding(.horizontal, Dimens.smallMediumPadding)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button(action: onConfirmButtonClick) {
                    if enabled {
                        Text(stringResource(.save))
                            .foregroundColor(.gedPrimary)
                    } else {
                        Text(stringResource(.save))
                    }
                }
                .disabled(!enabled)
            }
        }
    }
}

enum MissionTaskField: Hashable {
    case missionTaskContent
}

//#Preview {
//    MissionTaskView(
//        value: .constant(""),
//        enabled: false,
//        confirmButtonText: stringResource(.save),
//        onConfirmButtonClick: {}
//    )
//    .environment(\.managedObjectContext, GedDatabaseContainer.preview.container.viewContext)
//}
