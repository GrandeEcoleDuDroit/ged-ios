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
            
            Spacer()
                .frame(height: Dimens.smallPadding)
            
            Button(action: onAddTaskClick) {
                AddMissionTaskItem()
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(.rect)
            }.buttonStyle(ClickStyle())
            
            ForEach(missionTasks) { missionTask in
                Button(action: { onTaskClick(missionTask) }) {
                    MissionTaskItem(
                        missionTask: missionTask,
                        onRemoveTaskClick: { onRemoveTaskClick(missionTask) }
                    )
                    .padding()
                    .contentShape(.rect)
                }
                .buttonStyle(ClickStyle())
            }
        }.frame(maxWidth: .infinity)
    }
}

private struct AddMissionTaskItem: View {
    var body: some View {
        HStack(spacing: Dimens.smallPadding) {
            Image(systemName: "plus")
            
            Text(stringResource(.addTask))
        }
        .foregroundStyle(.onSurfaceVariant)
    }
}

struct MissionTaskItem: View {
    let missionTask: MissionTask
    let onRemoveTaskClick: () -> Void
    
    var body: some View {
        HStack {
            Text(missionTask.value)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            RemoveButton(action: onRemoveTaskClick)
        }
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
