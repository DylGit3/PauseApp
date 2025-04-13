import SwiftUI

struct TrackedAppsView: View {
    @Environment(\.dismiss) var dismiss
    @State private var starTwinkle = false

    // Persisted toggle states
    @AppStorage("trackTikTok") private var trackTikTok: Bool = true
    @AppStorage("trackInstagram") private var trackInstagram: Bool = true
    @AppStorage("trackYouTube") private var trackYouTube: Bool = true
    @AppStorage("trackReddit") private var trackReddit: Bool = true
    @AppStorage("trackX") private var trackX: Bool = true

    let twinkleTimer = Timer.publish(every: 2, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            // 🌌 Space Background
            GeometryReader { geometry in
                ZStack {
                    LinearGradient(
                        gradient: Gradient(colors: [.black, .blue.opacity(0.8)]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .ignoresSafeArea()

                    ForEach(0..<40, id: \.self) { _ in
                        Circle()
                            .frame(width: 2, height: 2)
                            .foregroundColor(.white.opacity(starTwinkle ? 0.9 : 0.3))
                            .position(
                                x: CGFloat.random(in: 0...geometry.size.width),
                                y: CGFloat.random(in: 0...geometry.size.height)
                            )
                    }
                }
            }

            // 🔘 UI Content
            VStack {
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                    Spacer()
                    Text("Tracked Apps")
                        .font(.title2)
                        .foregroundColor(.white)
                    Spacer()
                    Image(systemName: "chevron.left")
                        .opacity(0)
                }
                .padding()

                List {
                    Toggle("TikTok", isOn: $trackTikTok)
                    Toggle("Instagram", isOn: $trackInstagram)
                    Toggle("YouTube", isOn: $trackYouTube)
                    Toggle("Reddit", isOn: $trackReddit)
                    Toggle("X", isOn: $trackX)
                }
                .scrollContentBackground(.hidden)
            }
        }
        .onReceive(twinkleTimer) { _ in
            withAnimation(.easeInOut(duration: 1)) {
                starTwinkle.toggle()
            }
        }
    }
}

#Preview {
    NavigationView {
        TrackedAppsView()
    }
}
