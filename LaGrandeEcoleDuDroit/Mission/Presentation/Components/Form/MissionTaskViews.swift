import SwiftUI

struct AddMissionTaskView: View {
    let onAddTaskClick: (String) -> Void
    let onCancelClick: () -> Void
    
    @State private var value: String = ""
    private var createEnbaled: Bool {
        !value.isEmpty
    }
    
    var body: some View {
        NavigationStack {
            MissionTaskView(
                value: $value,
                enabled: createEnbaled,
                confirmButtonText: stringResource(.add),
                onConfirmButtonClick: {
                    onAddTaskClick(value)
                },
                onCancelClick: onCancelClick
            )
            .navigationTitle(stringResource(.addTask))
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct EditMissionTaskView: View {
    let missionTask: MissionTask
    let onSaveTaskClick: (MissionTask) -> Void
    let onCancelClick: () -> Void

    @State private var value: String
    
    init(
        missionTask: MissionTask,
        onSaveTaskClick: @escaping (MissionTask) -> Void,
        onCancelClick: @escaping () -> Void
    ) {
        self.missionTask = missionTask
        self.onSaveTaskClick = onSaveTaskClick
        self.value = missionTask.value
        self.onCancelClick = onCancelClick
    }
    
    private var editEnabled: Bool {
        !value.isEmpty && value != missionTask.value
    }
    
    var body: some View {
        NavigationStack {
            MissionTaskView(
                value: $value,
                enabled: editEnabled,
                confirmButtonText: stringResource(.save),
                onConfirmButtonClick: {
                    onSaveTaskClick(missionTask.copy { $0.value = value })
                },
                onCancelClick: onCancelClick
            )
            .navigationTitle(stringResource(.editTask))
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

private struct MissionTaskView: View {
    @Binding var value: String
    let enabled: Bool
    let confirmButtonText: String
    let onConfirmButtonClick: () -> Void
    let onCancelClick: () -> Void
    
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
        .padding(.horizontal, DimensResource.smallMediumPadding)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button(stringResource(.cancel), action: onCancelClick)
            }
            
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
        .interactiveDismissDisabled(true)
    }
}

enum MissionTaskField: Hashable {
    case missionTaskContent
}

#Preview {
    MissionTaskView(
        value: .constant(""),
        enabled: false,
        confirmButtonText: stringResource(.save),
        onConfirmButtonClick: {},
        onCancelClick: {}
    )
    .environment(\.managedObjectContext, GedDatabaseContainer.preview.container.viewContext)
}
