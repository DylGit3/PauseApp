import SwiftUI
import UserNotifications

struct MainScreen: View {
    // MARK: - State Variables
    @State private var timeSpent: Int = 0
    @State private var isLocked: Bool = false
    @State private var timeLimit: Int = 600
    @State private var showUnlockConfirmation: Bool = false
    @State private var unlockCountdown: Int = 0
    @State private var starTwinkle: Bool = false

    // MARK: - Timers
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    let unlockTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    let twinkleTimer = Timer.publish(every: 2, on: .main, in: .common).autoconnect()

    // MARK: - Managers and Storage
    let notificationManager = NotificationManager()
    private let userDefaults = UserDefaults.standard
    private let lockoutStartKey = "lockoutStartTime"
    private let timeSpentKey = "timeSpent"

    // MARK: - Computed Properties
    private var isThreeMinutesBeforeLimit: Bool {
        timeLimit >= 180 && timeSpent == (timeLimit - 180)
    }

    private var secondsUntilMidnight: Int {
        let calendar = Calendar.current
        let now = Date()
        let midnight = calendar.startOfDay(for: calendar.date(byAdding: .day, value: 1, to: now)!)
        return Int(midnight.timeIntervalSince(now))
    }

    private var remainingTimeFormatted: String {
        let hours = secondsUntilMidnight / 3600
        let minutes = (secondsUntilMidnight % 3600) / 60
        let seconds = secondsUntilMidnight % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    private var timeLimitInMinutes: Binding<Int> {
        Binding<Int>(
            get: { timeLimit / 60 },
            set: { timeLimit = $0 * 60 }
        )
    }
    // MARK: - Initialization
    init() {
        if let lockoutStart = userDefaults.object(forKey: lockoutStartKey) as? Date {
            let calendar = Calendar.current
            let lockoutDay = calendar.startOfDay(for: lockoutStart)
            let today = calendar.startOfDay(for: Date())

            if lockoutDay == today {
                _isLocked = State(initialValue: true)
                _timeSpent = State(initialValue: userDefaults.integer(forKey: timeSpentKey))
            } else {
                clearLockoutState()
            }
        }
    }

    // MARK: - Helper Functions
    private func saveLockoutState() {
        userDefaults.set(Date(), forKey: lockoutStartKey)
        userDefaults.set(timeSpent, forKey: timeSpentKey)
    }

    private func clearLockoutState() {
        userDefaults.removeObject(forKey: lockoutStartKey)
        userDefaults.removeObject(forKey: timeSpentKey)
    }

    private func forceUnlock() {
        isLocked = false
        timeSpent = 0
        clearLockoutState()
        showUnlockConfirmation = false
        unlockCountdown = 0
    }

    // MARK: - UI
    var body: some View {
        NavigationView {
            ZStack {
                // 🌌 Space background with stars
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

                // 🌙 Main UI
                VStack(spacing: 20) {
                    // Top bar
                    HStack {
                        // 👤 Transparent placeholder to balance spacing
                        Image(systemName: "person.circle")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .opacity(0) // Hidden but takes up space

                        Spacer()

                        // 🪐 Title
                        Text("Pause")
                            .font(.system(size: 30, weight: .bold, design: .rounded))
                            .foregroundColor(.white)

                        Spacer()

                        // 👤 Visible user icon
                        NavigationLink(destination: SettingsView()) {
                            Image(systemName: "person.circle")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top)



                    Text("Screen Time: \(timeSpent / 60) min \(timeSpent % 60) sec")
                        .font(.title2)
                        .foregroundColor(.white.opacity(starTwinkle ? 1.0 : 0.8))

                    TextField("Time Limit (minutes)", value: timeLimitInMinutes, format: .number)
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal)
                        .keyboardType(.numberPad)
                        .disabled(isLocked)
                        .foregroundColor(.black)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.purple, lineWidth: 2)
                        )

                    NavigationLink(destination: TrackedAppsView()) {
                        Text("Add Tracked Apps")
                            .font(.headline)
                            .padding()
                            .background(Color.purple)
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                    }

                    Spacer()
                }

                // 🚫 Lockout Screen
                if isLocked {
                    Color.black.opacity(0.9)
                        .ignoresSafeArea()
                        .overlay(
                            VStack(spacing: 20) {
                                Text("Orbiting Break Mode!")
                                    .font(.title)
                                    .foregroundColor(.white)
                                    .shadow(color: .blue.opacity(0.5), radius: 5)

                                Text("Returns in: \(remainingTimeFormatted)")
                                    .font(.title2)
                                    .foregroundColor(.white.opacity(starTwinkle ? 1.0 : 0.8))

                                if unlockCountdown > 0 {
                                    Text("Re-entering Orbit in: \(unlockCountdown) seconds")
                                        .font(.headline)
                                        .foregroundColor(.yellow)
                                }

                                Button(action: {
                                    showUnlockConfirmation = true
                                }) {
                                    Text("Re-Enter Orbit Early")
                                        .font(.headline)
                                        .padding()
                                        .background(unlockCountdown > 0 ? Color.gray : Color.red)
                                        .foregroundColor(.white)
                                        .clipShape(Capsule())
                                }
                                .disabled(unlockCountdown > 0)

                                NavigationLink(destination: SettingsView()) {
                                    Text("Go to Space Station (Settings)")
                                        .font(.headline)
                                        .padding()
                                        .background(Color.blue)
                                        .foregroundColor(.white)
                                        .clipShape(Capsule())
                                }
                            }
                        )
                }
            }
            .navigationBarHidden(true)
        }
        .onReceive(timer) { _ in
            if !isLocked {
                timeSpent += 1
                if isThreeMinutesBeforeLimit {
                    notificationManager.scheduleReminder(after: 5)
                }
                if timeSpent >= timeLimit {
                    isLocked = true
                    saveLockoutState()
                    notificationManager.scheduleLockoutNotification()
                }
            }
        }
        .onReceive(unlockTimer) { _ in
            if unlockCountdown > 0 {
                unlockCountdown -= 1
                if unlockCountdown == 0 {
                    forceUnlock()
                }
            }
        }
        .onReceive(twinkleTimer) { _ in
            withAnimation(.easeInOut(duration: 1)) {
                starTwinkle.toggle()
            }
        }
        .onAppear {
            notificationManager.requestPermission()
        }
        .alert(isPresented: $showUnlockConfirmation) {
            Alert(
                title: Text("Re-Enter Orbit Early?"),
                message: Text("Are you sure you want to leave break mode? This will reset your timer. You’ll need to wait 10 seconds for re-entry."),
                primaryButton: .destructive(Text("Yes")) {
                    unlockCountdown = 10
                },
                secondaryButton: .cancel()
            )
        }
    }
}

struct MainScreen_Previews: PreviewProvider {
    static var previews: some View {
        MainScreen()
    }
}
