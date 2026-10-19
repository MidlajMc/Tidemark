import SwiftUI

struct AddHabitSheet: View {
    @Environment(\.dismiss) private var dismiss
    var onSave: (_ title: String, _ emoji: String, _ colorIndex: Int) -> Void

    @State private var title = ""
    @State private var emoji = "🧘"
    @State private var colorIndex = 3
    @FocusState private var focused: Bool
    @Namespace private var namespace

    private let emojis = ["🧘", "💧", "📚", "🏃", "🥗", "✍️", "🎸", "😴"]

    private var accent: Color { Theme.accents[colorIndex] }
    private var trimmedTitle: String { title.trimmingCharacters(in: .whitespacesAndNewlines) }
    private var canSave: Bool { !trimmedTitle.isEmpty }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("New habit")
                    .font(.system(.title, design: .rounded, weight: .bold))
                    .padding(.top, 24)

                preview

                VStack(alignment: .leading, spacing: 10) {
                    sectionLabel("Name")
                    TextField("e.g. Read 20 pages", text: $title)
                        .focused($focused)
                        .submitLabel(.done)
                        .padding(16)
                        .flowCard(cornerRadius: 18)
                }

                VStack(alignment: .leading, spacing: 10) {
                    sectionLabel("Icon")
                    emojiPicker
                }

                VStack(alignment: .leading, spacing: 10) {
                    sectionLabel("Color")
                    colorPicker
                }

                PrimaryButton(title: "Create habit", systemImage: "sparkles", tint: accent) {
                    onSave(trimmedTitle, emoji, colorIndex)
                    dismiss()
                }
                .disabled(!canSave)
                .opacity(canSave ? 1 : 0.5)
                .animation(Motion.snappy, value: canSave)
                .padding(.top, 8)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .scrollIndicators(.hidden)
        .scrollDismissesKeyboard(.interactively)
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(32)
        .presentationBackground { AnimatedBackground() }
        .task {
            try? await Task.sleep(for: .milliseconds(450))
            focused = true
        }
    }

    // MARK: Pieces

    private var preview: some View {
        HStack(spacing: 14) {
            Text(emoji)
                .font(.system(size: 30))
                .frame(width: 56, height: 56)
                .background(accent.opacity(0.2), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                .contentTransition(.interpolate)

            Text(trimmedTitle.isEmpty ? "Your new habit" : trimmedTitle)
                .font(.headline)
                .foregroundStyle(trimmedTitle.isEmpty ? .secondary : .primary)
                .lineLimit(1)

            Spacer()
        }
        .padding(16)
        .flowCard(cornerRadius: 24)
        .animation(Motion.snappy, value: emoji)
        .animation(Motion.snappy, value: colorIndex)
    }

    private var emojiPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                ForEach(emojis, id: \.self) { option in
                    Button {
                        withAnimation(Motion.snappy) { emoji = option }
                    } label: {
                        Text(option)
                            .font(.title2)
                            .frame(width: 46, height: 46)
                            .background {
                                if emoji == option {
                                    Circle()
                                        .fill(accent.opacity(0.28))
                                        .matchedGeometryEffect(id: "emojiSelection", in: namespace)
                                }
                            }
                    }
                    .buttonStyle(PressableButtonStyle())
                }
            }
        }
    }

    private var colorPicker: some View {
        HStack(spacing: 14) {
            ForEach(Theme.accents.indices, id: \.self) { index in
                Button {
                    withAnimation(Motion.snappy) { colorIndex = index }
                } label: {
                    Circle()
                        .fill(Theme.accents[index].gradient)
                        .frame(width: 34, height: 34)
                        .overlay {
                            if colorIndex == index {
                                Circle()
                                    .strokeBorder(Theme.accents[index], lineWidth: 2.5)
                                    .padding(-6)
                                    .matchedGeometryEffect(id: "colorRing", in: namespace)
                            }
                        }
                }
                .buttonStyle(PressableButtonStyle(scale: 0.9))
            }
        }
        .padding(.horizontal, 6)
    }

    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(.secondary)
    }
}
