struct BuildBadge: View {
    var env = Bundle.main.infoDictionary?["APP_ENV"] as? String ?? "DEV"
    var build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "0"
    var body: some View {
        HStack(spacing: 8) {
            Text(env.uppercased())
                .font(.caption2).padding(.horizontal, 8).padding(.vertical, 4)
                .background(env == "PROD" ? .red.opacity(0.15) : .blue.opacity(0.15))
                .clipShape(Capsule())
            Text("#\(build)").font(.caption2).foregroundStyle(.secondary)
        }
    }
}