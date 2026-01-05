import SwiftUI

struct MissionFormTaskSection: View {
    let missionTasks: [MissionTask]
    let onTaskClick: (MissionTask) -> Void
    let onAddTaskClick: () -> Void
    let onRemoveTaskClick: (MissionTask) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: .zero) {
            SectionTitle(title: stringResource(.tasks))
                .padding(.horizontal)
            
            Spacer().frame(height: Dimens.smallPadding)
            
            Button(action: onAddTaskClick) {
                AddMissionTaskItem()
            }
            .buttonStyle(ClickStyle())
            
            ForEach(missionTasks) { missionTask in
                Button(action: { onTaskClick(missionTask) }) {
                    MissionTaskItem(
                        missionTask: missionTask,
                        onRemoveTaskClick: { onRemoveTaskClick(missionTask) }
                    )
                }
                .buttonStyle(ClickStyle())
            }
        }.frame(maxWidth: .infinity)
    }
}

private struct AddMissionTaskItem: View {
    var body: some View {
        PlainListItem(
            headlineContent: {
                Text(stringResource(.addTask))
            },
            leadingContent: {
                Image(systemName: "plus")
            }
        )
        .padding(.vertical, Dimens.extraSmallPadding)
        .foregroundStyle(.onSurfaceVariant)
        .contentShape(.rect)
    }
}

struct MissionTaskItem: View {
    let missionTask: MissionTask
    let onRemoveTaskClick: () -> Void
    
    var body: some View {
        PlainListItem(
            headlineContent: {
                Text(missionTask.value)
            },
            trailingContent: {
                RemoveButton(action: onRemoveTaskClick)
            }
        )
        .padding(.vertical, Dimens.extraSmallPadding)
        .contentShape(.rect)
    }
}

#Preview {
    MissionFormTaskSection(
        missionTasks: missionTasksFixture,
        onTaskClick: { _ in },
        onAddTaskClick: {},
        onRemoveTaskClick: { _ in }
    )
    .environment(\.managedObjectContext, GedDatabaseContainer.preview.container.viewContext)
}
