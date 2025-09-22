import SwiftUI

struct DocumentUploadSheet: View {
    @Binding var isPresented: Bool
    let targetVault: DocumentVault?

    @State private var selectedDocumentType: DocumentType = .bankStatement
    @State private var documentName = ""
    @State private var showImagePicker = false
    @State private var showDocumentPicker = false
    @State private var showCamera = false
    @State private var uploadProgress: Double = 0
    @State private var isUploading = false
    @State private var uploadComplete = false

    init(isPresented: Binding<Bool>, targetVault: DocumentVault? = nil) {
        _isPresented = isPresented
        self.targetVault = targetVault
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.black.opacity(0.95),
                    Color.gray.opacity(0.1),
                    Color.black.opacity(0.95)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack {
                    Button("Cancel") {
                        isPresented = false
                    }
                    .foregroundColor(.blue)

                    Spacer()

                    Text("Upload Document")
                        .font(.headline)
                        .foregroundColor(.white)

                    Spacer()

                    Button("Upload") {
                        startUpload()
                    }
                    .foregroundColor(.blue)
                    .disabled(documentName.isEmpty || isUploading)
                }
                .padding()
                .background(Color.black.opacity(0.4))

                ScrollView {
                    VStack(spacing: 24) {
                        // Upload Header
                        VStack(spacing: 16) {
                            Image(systemName: "doc.badge.plus")
                                .font(.system(size: 48, weight: .medium))
                                .foregroundColor(.blue)

                            Text("Upload Document")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)

                            if let vault = targetVault {
                                Text("Adding to \(vault.name)")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.top, 10)

                        // Document Type Selection
                        VStack(spacing: 16) {
                            Text("Document Type")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: 12) {
                                ForEach(DocumentType.allCases, id: \.self) { type in
                                    DocumentTypeButton(
                                        type: type,
                                        isSelected: selectedDocumentType == type
                                    ) {
                                        selectedDocumentType = type
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)

                        // Document Name Input
                        VStack(spacing: 12) {
                            Text("Document Name")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            TextField("Enter document name", text: $documentName)
                                .textFieldStyle(CustomTextFieldStyle())
                        }
                        .padding(.horizontal, 20)

                        // Upload Options
                        VStack(spacing: 16) {
                            Text("Upload Method")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            VStack(spacing: 12) {
                                UploadOptionButton(
                                    title: "Take Photo",
                                    subtitle: "Use camera to capture document",
                                    icon: "camera.fill",
                                    color: .green
                                ) {
                                    showCamera = true
                                }

                                UploadOptionButton(
                                    title: "Choose from Photos",
                                    subtitle: "Select from photo library",
                                    icon: "photo.fill",
                                    color: .blue
                                ) {
                                    showImagePicker = true
                                }

                                UploadOptionButton(
                                    title: "Browse Files",
                                    subtitle: "Select PDF or document file",
                                    icon: "doc.fill",
                                    color: .purple
                                ) {
                                    showDocumentPicker = true
                                }
                            }
                        }
                        .padding(.horizontal, 20)

                        // Upload Progress
                        if isUploading {
                            UploadProgressView(progress: uploadProgress)
                                .padding(.horizontal, 20)
                        }

                        // Upload Complete
                        if uploadComplete {
                            UploadCompleteView {
                                isPresented = false
                            }
                            .padding(.horizontal, 20)
                        }

                        Spacer(minLength: 50)
                    }
                }
            }
        }
        .sheet(isPresented: $showImagePicker) { Text("Image Picker") }
        .sheet(isPresented: $showDocumentPicker) { Text("Document Picker") }
        .sheet(isPresented: $showCamera) { Text("Camera View") }
    }

    private func startUpload() {
        isUploading = true
        uploadProgress = 0

        let totalDuration = 2.0
        let steps = 20
        let stepDuration = totalDuration / Double(steps)
        let progressIncrement = 1.0 / Double(steps)

        func updateProgress(step: Int) {
            guard step <= steps else {
                uploadProgress = 1.0
                isUploading = false
                uploadComplete = true
                return
            }

            uploadProgress = Double(step) * progressIncrement

            if step < steps {
                DispatchQueue.main.asyncAfter(deadline: .now() + stepDuration) {
                    updateProgress(step: step + 1)
                }
            } else {
                isUploading = false
                uploadComplete = true
            }
        }

        updateProgress(step: 1)
    }
}

// MARK: - Document Type Button

struct DocumentTypeButton: View {
    let type: DocumentType
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                Image(systemName: type.systemIcon)
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(isSelected ? .blue : .gray)

                Text(type.rawValue)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(isSelected ? .white : .gray)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(height: 80)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            colors: [
                                isSelected ? Color.blue.opacity(0.2) : Color.white.opacity(0.08),
                                isSelected ? Color.blue.opacity(0.1) : Color.white.opacity(0.04)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                isSelected ? Color.blue.opacity(0.5) : Color.white.opacity(0.1),
                                lineWidth: isSelected ? 2 : 1
                            )
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Custom Text Field Style

struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.1),
                                Color.white.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
            )
            .foregroundColor(.white)
    }
}

// MARK: - Upload Option Button

struct UploadOptionButton: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    color.opacity(0.3),
                                    color.opacity(0.1)
                                ],
                                center: .center,
                                startRadius: 20,
                                endRadius: 30
                            )
                        )
                        .frame(width: 50, height: 50)

                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(color)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)

                    Text(subtitle)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.gray)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.gray)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.08),
                                Color.white.opacity(0.04)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(color.opacity(0.3), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Upload Progress View

struct UploadProgressView: View {
    let progress: Double

    var body: some View {
        VStack(spacing: 16) {
            Text("Uploading Document...")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)

            VStack(spacing: 8) {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 8)
                            .cornerRadius(4)

                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [.blue, .cyan],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * progress, height: 8)
                            .cornerRadius(4)
                    }
                }
                .frame(height: 8)

                Text("\(Int(progress * 100))%")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.blue)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.1),
                            Color.white.opacity(0.05)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// MARK: - Upload Complete View

struct UploadCompleteView: View {
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 48, weight: .medium))
                .foregroundColor(.green)

            Text("Upload Complete!")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)

            Text("Your document has been successfully uploaded and is being processed.")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)

            Button("Done") {
                onDismiss()
            }
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 32)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            colors: [.green, .green.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.1),
                            Color.white.opacity(0.05)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.green.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

#Preview {
    DocumentUploadSheet(
        isPresented: .constant(true),
        targetVault: DocumentVault.sampleVaults[0]
    )
}