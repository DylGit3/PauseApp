import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss

    @AppStorage("timeLimit") var timeLimit: Int = 600

    @State private var starTwinkle = false
    let twinkleTimer = Timer.publish(every: 2, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            // 🌌 Space background
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

            VStack {
                // 🔙 Custom back bar
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                    Spacer()
                    Text("Settings")
                        .font(.headline)
                        .foregroundColor(.white)
                    Spacer()
                    Image(systemName: "chevron.left")
                        .opacity(0)
                }
                .padding()

                // ⏱ Time limit stepper
                Form {
                    Section(header: Text("Time Limit").foregroundColor(.white)) {
                        Stepper(value: $timeLimit, in: 300...3600, step: 60) {
                            Text("Limit: \(timeLimit / 60) minutes")
                        }
                    }
                }
                .scrollContentBackground(.hidden)
            }
        }
        .onReceive(twinkleTimer) { _ in
            withAnimation(.easeInOut(duration: 1)) {
                starTwinkle.toggle()
            }
        }
        .navigationBarHidden(true)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SettingsView()
        }
    }
}
