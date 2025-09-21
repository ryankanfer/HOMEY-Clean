import SwiftUI

public struct SpatialCompanionShell: View {
    @EnvironmentObject private var store: CompanionStore
    #if os(iOS)
        private var isiPhone: Bool { UIDevice.current.userInterfaceIdiom == .phone }
    #else
        private let isiPhone = false
    #endif

    @State private var sidebarOpen: Bool = false
    @State private var sidebarDrag: CGFloat = 0
    @State private var sidebarWidth: CGFloat = 360

    public init() {}

    public var body: some View {
        ZStack(alignment: .leading) {
            ModuleHost()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .contentShape(Rectangle())
                .onTapGesture {
                    if sidebarOpen {
                        withAnimation(.spring(response: 0.25, dampingFraction: 0.9)) { sidebarOpen = false }
                    }
                }

            SidebarContainer(width: $sidebarWidth, isOpen: $sidebarOpen) {
                SidebarContent(selected: store.active) { module in
                    withAnimation(.spring(response: 0.25, dampingFraction: 0.9)) {
                        store.active = module
                        sidebarOpen = false
                    }
                }
            }
            .offset(x: sidebarOffsetX)
            .animation(.spring(response: 0.25, dampingFraction: 0.9), value: sidebarOpen)

            if isiPhone {
                Color.clear
                    .frame(width: 18)
                    .contentShape(Rectangle())
                    .ignoresSafeArea(edges: .vertical)
                    .gesture(edgeRevealGesture)
            }
        }
        .safeAreaInset(edge: .bottom) {
            if isiPhone {
                MiniDockiPhone(
                    onHome: { withAnimation(.spring()) { store.active = .charlie } },
                    onBack: { withAnimation(.spring()) { store.pop() } }
                )
                .padding(.horizontal, 16)
                .padding(.bottom, 12)
            } else {
                EmptyView()
            }
        }
    }

    private var sidebarOffsetX: CGFloat {
        let hidden = -(sidebarWidth + 24)
        if sidebarOpen { return 0 }
        return min(0, hidden + max(0, sidebarDrag))
    }

    private var edgeRevealGesture: some Gesture {
        DragGesture(minimumDistance: 8, coordinateSpace: .local)
            .onChanged { value in
                guard value.startLocation.x <= 24 else { return }
                sidebarDrag = max(0, value.translation.width)
            }
            .onEnded { value in
                defer { sidebarDrag = 0 }
                guard value.startLocation.x <= 24 else { return }
                let shouldOpen = value.translation.width > 50
                withAnimation(.spring(response: 0.25, dampingFraction: 0.9)) {
                    sidebarOpen = shouldOpen
                }
            }
    }
}

private struct SidebarContent: View {
    let selected: CompanionModule
    let onSelect: (CompanionModule) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Modules")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 14)
                .padding(.top, 10)

            ForEach(CompanionModule.allCases, id: \.self) { module in
                Button {
                    onSelect(module)
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: module.systemIcon)
                            .imageScale(.medium)
                        Text(module.title)
                            .font(.body)
                        Spacer(minLength: 0)
                        if module == selected {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                                .imageScale(.small)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color.white.opacity(module == selected ? 0.12 : 0.06))
                    )
                }
                .buttonStyle(.plain)
                .contentShape(Rectangle())
            }

            Spacer(minLength: 0)
        }
        .padding(.vertical, 8)
    }
}

public struct SidebarContainer<Content: View>: View {
    @Binding var width: CGFloat
    @Binding var isOpen: Bool
    @ViewBuilder let content: Content

    @State private var resizeDrag: CGFloat = 0

    public init(width: Binding<CGFloat>, isOpen: Binding<Bool>, @ViewBuilder content: () -> Content) {
        _width = width
        _isOpen = isOpen
        self.content = content()
    }

    public var body: some View {
        HStack(spacing: 0) {
            VStack(spacing: 0) {
                content
            }
            .frame(width: clampedWidth)
            .background(.ultraThinMaterial)
            .overlay(alignment: .trailing) {
                Rectangle()
                    .fill(LinearGradient(
                        colors: [Color.white.opacity(0.18), Color.clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    ))
                    .frame(width: 1)
            }

            ResizeHandle()
                .contentShape(Rectangle())
                .gesture(resizeGesture)
        }
        .shadow(color: .black.opacity(0.18), radius: 20, x: 0, y: 10)
        .overlay(alignment: .topTrailing) {
            Button {
                withAnimation(.spring(response: 0.25, dampingFraction: 0.9)) { isOpen = false }
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .symbolRenderingMode(.hierarchical)
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .padding(8)
            }
        }
        .accessibilityIdentifier("SidebarContainer")
    }

    private var clampedWidth: CGFloat {
        let w = width + resizeDrag
        return min(420, max(320, w))
    }

    private var resizeGesture: some Gesture {
        DragGesture(minimumDistance: 2)
            .onChanged { value in
                resizeDrag = value.translation.width
            }
            .onEnded { value in
                width = min(420, max(320, width + value.translation.width))
                resizeDrag = 0
            }
    }

    private struct ResizeHandle: View {
        var body: some View {
            ZStack {
                LinearGradient(colors: [.clear, Color.white.opacity(0.08)], startPoint: .leading, endPoint: .trailing)
                    .frame(width: 10)
                Capsule()
                    .fill(Color.white.opacity(0.25))
                    .frame(width: 3, height: 36)
            }
            .frame(width: 18)
            .background(.ultraThinMaterial)
        }
    }
}

public struct ModuleHost: View {
    @EnvironmentObject private var store: CompanionStore
    @State private var pageIndex: Int = 0

    private let order: [CompanionModule] = [.charlie, .paige, .scout, .drew]

    public init() {}

    public var body: some View {
        GeometryReader { proxy in
            TabView(selection: $pageIndex) {
                CharlieDashboardView().frame(width: proxy.size.width).tag(idx(.charlie))
                PaigeDashboardView().frame(width: proxy.size.width).tag(idx(.paige))
                ScoutDashboardView().frame(width: proxy.size.width).tag(idx(.scout))
                DrewDashboardView().frame(width: proxy.size.width).tag(idx(.drew))
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .onAppear {
                if let i = order.firstIndex(of: store.active) { pageIndex = i }
            }
            .onChange(of: pageIndex) { _, newIndex in
                guard order.indices.contains(newIndex) else { return }
                let target = order[newIndex]
                if target != store.active { store.active = target }
            }
            .onChange(of: store.active) { _, newModule in
                if let i = order.firstIndex(of: newModule), i != pageIndex {
                    pageIndex = i
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func idx(_ m: CompanionModule) -> Int {
        order.firstIndex(of: m) ?? 0
    }
}

public struct MiniDockiPhone: View {
    var onHome: () -> Void
    var onBack: () -> Void

    public init(onHome: @escaping () -> Void, onBack: @escaping () -> Void) {
        self.onHome = onHome
        self.onBack = onBack
    }

    public var body: some View {
        HStack(spacing: 12) {
            Button(action: onBack) {
                Label("Back", systemImage: "chevron.left")
                    .font(.headline)
                    .padding(.horizontal, 14).padding(.vertical, 10)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.plain)
            .background(Capsule().fill(.ultraThinMaterial))
            .overlay(Capsule().stroke(Color.white.opacity(0.12), lineWidth: 1))
            .shadow(color: .black.opacity(0.12), radius: 10, x: 0, y: 6)

            Button(action: onHome) {
                Label("Home", systemImage: "house.fill")
                    .font(.headline)
                    .padding(.horizontal, 14).padding(.vertical, 10)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.plain)
            .background(Capsule().fill(.ultraThinMaterial))
            .overlay(Capsule().stroke(Color.white.opacity(0.12), lineWidth: 1))
            .shadow(color: .black.opacity(0.12), radius: 10, x: 0, y: 6)
        }
        .background(
            UnevenRoundedRectangle(
                cornerRadii: .init(topLeading: 24, bottomLeading: 0, bottomTrailing: 0, topTrailing: 24)
            )
            .fill(.ultraThinMaterial)
        )
        .overlay(
            UnevenRoundedRectangle(
                cornerRadii: .init(topLeading: 24, bottomLeading: 0, bottomTrailing: 0, topTrailing: 24)
            )
            .stroke(
                LinearGradient(
                    colors: [Color.white.opacity(0.20), Color.white.opacity(0.06)],
                    startPoint: .top,
                    endPoint: .bottom
                ),
                lineWidth: 1
            )
        )
        .ignoresSafeArea(edges: .bottom)
    }
}
