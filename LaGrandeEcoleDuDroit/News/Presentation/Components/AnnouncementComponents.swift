import SwiftUI

struct RecentAnnouncement: View {
    @Binding var announcement: Announcement
    
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            if let profilePictureUrl = announcement.author.profilePictureUrl {
                ProfilePicture(
                    url: profilePictureUrl,
                    scale: 0.5
                )
            } else {
                DefaultProfilePicture(scale: 0.5)
            }
            
            VStack(alignment: .leading, spacing: GedSpacing.verySmall) {
                Text(announcement.author.fullName)
                    .font(.titleSmall)
                    .bold()
                
                Text(announcement.title ?? announcement.content)
                    .foregroundStyle(Color(UIColor.lightGray))
                    .font(.bodyMedium)
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
            
            Text(announcement.date.formatted(.dateTime.year().month().day().hour().minute()))
                .font(.caption)
                .foregroundStyle(Color(UIColor.lightGray))
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
        .padding(.vertical, 5)
        .onTapGesture {
            print("Announcement tapped")
        }
    }
}

#Preview {
    RecentAnnouncement(
        announcement: .constant(announcementFixture)
    )
}
