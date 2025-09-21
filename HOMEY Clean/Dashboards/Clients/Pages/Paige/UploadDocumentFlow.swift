//
//  UploadDocumentFlow.swift
//  HOMEY Clean
//
//  Complete upload flow with document type selection and file methods
//

import PhotosUI
import SwiftUI
#if canImport(UIKit)
    import UIKit
#endif

struct UploadDocumentFlow: View {
    @Environment(\.dismiss) private var dismiss
    @State private var currentStep: UploadStep = .selectType
    @State private var selectedDocumentType: DocumentUploadType?
    @State private var documentName = ""
    @State private var selectedMethod: UploadMethod?
    @State private var showImagePicker = false
    @State private var showDocumentPicker = false
    @State private var showCamera = false
    #if canImport(UIKit)
        @State private var selectedImage: UIImage?
    #else
        @State private var selectedImage: NSImage?
    #endif
    @State private var uploadProgress: Double = 0
    @State private var isUploading = false
    @State private var uploadComplete = false

    var body: some View {
        NavigationStack {
            Group {
                switch currentStep {
                case .selectType:
                    documentTypeSelection
                case .nameAndMethod:
                    nameAndMethodSelection
                case .uploading:
                    uploadingView
                case .complete:
                    uploadCompleteView
                }
            }
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if currentStep != .uploading && currentStep != .complete {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                }

                if currentStep == .selectType {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Next") {
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                currentStep = .nameAndMethod
                            }
                        }
                        .disabled(selectedDocumentType == nil)
                    }
                }
            }
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(selectedImage: $selectedImage) {
                processSelectedFile()
            }
        }
        .sheet(isPresented: $showDocumentPicker) {
            DocumentPicker { url in
                processDocumentFile(url)
            }
        }
        .fullScreenCover(isPresented: $showCamera) {
            CameraView(selectedImage: $selectedImage) {
                processSelectedFile()
            }
        }
    }

    // MARK: - Navigation Title

    private var navigationTitle: String {
        switch currentStep {
        case .selectType:
            return "Document Type"
        case .nameAndMethod:
            return "Upload Method"
        case .uploading:
            return "Uploading..."
        case .complete:
            return "Upload Complete"
        }
    }

    // MARK: - Document Type Selection

    private var documentTypeSelection: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("What type of document are you uploading?")
                        .font(.custom("PlayfairDisplay-Regular", size: 24))
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)

                    Text("Select the category that best matches your document")
                        .font(.custom("Lato-Regular", size: 16))
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 20)

                // Document Types Grid
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 12),
                    GridItem(.flexible(), spacing: 12)
                ], spacing: 16) {
                    ForEach(DocumentUploadType.allCases, id: \.self) { type in
                        DocumentTypeCard(
                            type: type,
                            isSelected: selectedDocumentType == type
                        ) {
                            selectedDocumentType = type
                            HapticManager.shared.impact(.light)
                        }
                    }
                }
                .padding(.horizontal, 20)

                Spacer(minLength: 100)
            }
            .padding(.vertical, 20)
        }
    }

    // MARK: - Name and Method Selection

    private var nameAndMethodSelection: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Name your document")
                        .font(.custom("PlayfairDisplay-Regular", size: 24))
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)

                    Text("Give it a descriptive name for easy identification")
                        .font(.custom("Lato-Regular", size: 16))
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 20)

                // Document Name Field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Document Name")
                        .font(.custom("Lato-Regular", size: 14))
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)

                    TextField(selectedDocumentType?.placeholder ?? "Enter document name", text: $documentName)
                        .font(.custom("Lato-Regular", size: 16))
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(.ultraThinMaterial)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .strokeBorder(.white.opacity(0.1), lineWidth: 1)
                                )
                        )
                }
                .padding(.horizontal, 20)

                // Upload Method Selection
                VStack(alignment: .leading, spacing: 16) {
                    Text("How would you like to upload?")
                        .font(.custom("PlayfairDisplay-Regular", size: 20))
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .padding(.horizontal, 20)

                    VStack(spacing: 12) {
                        ForEach(UploadMethod.allCases, id: \.self) { method in
                            UploadMethodCard(
                                method: method,
                                isSelected: selectedMethod == method
                            ) {
                                selectedMethod = method
                                handleMethodSelection(method)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }

                Spacer(minLength: 100)
            }
            .padding(.vertical, 20)
        }
    }

    // MARK: - Uploading View

    private var uploadingView: some View {
        VStack(spacing: 32) {
            Spacer()

            // Upload Animation
            ZStack {
                Circle()
                    .stroke(.ultraThinMaterial, lineWidth: 8)
                    .frame(width: 120, height: 120)

                Circle()
                    .trim(from: 0, to: uploadProgress)
                    .stroke(
                        selectedDocumentType?.color ?? .blue,
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.3), value: uploadProgress)

                Image(systemName: selectedDocumentType?.icon ?? "doc.fill")
                    .font(.system(size: 32, weight: .medium))
                    .foregroundStyle(selectedDocumentType?.color ?? .blue)
            }

            VStack(spacing: 8) {
                Text("Uploading Document")
                    .font(.custom("PlayfairDisplay-Regular", size: 24))
                    .fontWeight(.semibold)

                Text(documentName.isEmpty ? "Untitled Document" : documentName)
                    .font(.custom("Lato-Regular", size: 16))
                    .foregroundColor(.secondary)

                Text("\(Int(uploadProgress * 100))%")
                    .font(.custom("Lato-Regular", size: 14))
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .monospacedDigit()
            }

            Spacer()
        }
        .onAppear {
            startUploadAnimation()
        }
    }

    // MARK: - Upload Complete View

    private var uploadCompleteView: some View {
        VStack(spacing: 32) {
            Spacer()

            // Success Animation
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                .green.opacity(0.2),
                                .green.opacity(0.05),
                                .clear
                            ],
                            center: .center,
                            startRadius: 30,
                            endRadius: 80
                        )
                    )
                    .frame(width: 120, height: 120)

                Circle()
                    .fill(.green)
                    .frame(width: 80, height: 80)

                Image(systemName: "checkmark")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
            }

            VStack(spacing: 8) {
                Text("Upload Complete!")
                    .font(.custom("PlayfairDisplay-Regular", size: 24))
                    .fontWeight(.semibold)

                Text("Your document has been securely uploaded")
                    .font(.custom("Lato-Regular", size: 16))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }

            Button("Done") {
                dismiss()
            }
            .font(.custom("Lato-Regular", size: 16))
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .padding(.horizontal, 32)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 25, style: .continuous)
                    .fill(.green)
            )

            Spacer()
        }
    }

    // MARK: - Helper Methods

    private func handleMethodSelection(_ method: UploadMethod) {
        HapticManager.shared.impact(.medium)

        switch method {
        case .takePhoto:
            showCamera = true
        case .choosePhoto:
            showImagePicker = true
        case .browseFiles:
            showDocumentPicker = true
        }
    }

    private func processSelectedFile() {
        guard selectedImage != nil else { return }

        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            currentStep = .uploading
        }
    }

    private func processDocumentFile(_: URL) {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            currentStep = .uploading
        }
    }

    private func startUploadAnimation() {
        isUploading = true

        // Simulate upload progress
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            uploadProgress += 0.05

            if uploadProgress >= 1.0 {
                timer.invalidate()

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        currentStep = .complete
                    }

                    HapticManager.shared.notification(.success)
                }
            }
        }
    }
}

// MARK: - Upload Step Enum

enum UploadStep {
    case selectType
    case nameAndMethod
    case uploading
    case complete
}

// MARK: - Upload Method Enum

enum UploadMethod: CaseIterable {
    case takePhoto
    case choosePhoto
    case browseFiles

    var title: String {
        switch self {
        case .takePhoto: return "Take Photo"
        case .choosePhoto: return "Choose Photo"
        case .browseFiles: return "Browse Files"
        }
    }

    var icon: String {
        switch self {
        case .takePhoto: return "camera.fill"
        case .choosePhoto: return "photo.fill"
        case .browseFiles: return "folder.fill"
        }
    }

    var description: String {
        switch self {
        case .takePhoto: return "Use your camera to capture the document"
        case .choosePhoto: return "Select an existing photo from your library"
        case .browseFiles: return "Choose a file from your device storage"
        }
    }
}

// MARK: - Document Upload Type Enum

public enum DocumentUploadType: CaseIterable {
    case genericPDF
    case bankStatement
    case taxReturn
    case payStub
    case creditReport
    case driversLicense
    case ssnCard
    case passport
    case leaseAgreement
    case rentalHistory
    case employmentLetter
    case w2
    case insurance

    var title: String {
        switch self {
        case .genericPDF: return "PDF"
        case .bankStatement: return "Bank Statement"
        case .taxReturn: return "Tax Return"
        case .payStub: return "Pay Stub"
        case .creditReport: return "Credit Report"
        case .driversLicense: return "Driver's License"
        case .ssnCard: return "SSN Card"
        case .passport: return "Passport"
        case .leaseAgreement: return "Lease Agreement"
        case .rentalHistory: return "Rental History"
        case .employmentLetter: return "Employment Letter"
        case .w2: return "W-2"
        case .insurance: return "Insurance"
        }
    }

    var icon: String {
        switch self {
        case .genericPDF: return "doc.fill"
        case .bankStatement: return "building.columns.fill"
        case .taxReturn: return "doc.text.fill"
        case .payStub: return "dollarsign.circle.fill"
        case .creditReport: return "chart.line.uptrend.xyaxis"
        case .driversLicense: return "car.fill"
        case .ssnCard: return "person.text.rectangle.fill"
        case .passport: return "book.closed.fill"
        case .leaseAgreement: return "house.fill"
        case .rentalHistory: return "building.fill"
        case .employmentLetter: return "briefcase.fill"
        case .w2: return "doc.plaintext.fill"
        case .insurance: return "shield.lefthalf.filled"
        }
    }

    var color: Color {
        switch self {
        case .genericPDF, .bankStatement, .taxReturn, .payStub, .creditReport:
            return Color(hex: "2ECC71") // Financial - Green
        case .driversLicense, .ssnCard, .passport:
            return Color(hex: "2E86DE") // Identity - Blue
        case .leaseAgreement, .rentalHistory:
            return Color(hex: "A66BFF") // Property - Purple
        case .employmentLetter, .w2:
            return Color(hex: "FF9F43") // Employment - Orange
        case .insurance:
            return Color(hex: "E74C3C") // Insurance - Red
        }
    }

    var placeholder: String {
        switch self {
        case .genericPDF: return "e.g., PDF Document"
        case .bankStatement: return "e.g., Chase Bank Statement - January 2024"
        case .taxReturn: return "e.g., Tax Return 2023"
        case .payStub: return "e.g., Pay Stub - December 2023"
        case .creditReport: return "e.g., Credit Report - Experian"
        case .driversLicense: return "e.g., Driver's License"
        case .ssnCard: return "e.g., Social Security Card"
        case .passport: return "e.g., US Passport"
        case .leaseAgreement: return "e.g., Lease Agreement - Main St Apt"
        case .rentalHistory: return "e.g., Rental History Report"
        case .employmentLetter: return "e.g., Employment Verification Letter"
        case .w2: return "e.g., W-2 Form 2023"
        case .insurance: return "e.g., Auto Insurance Policy"
        }
    }
}

// MARK: - Document Type Card

struct DocumentTypeCard: View {
    let type: DocumentUploadType
    let isSelected: Bool
    let onTap: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                // Icon with glow
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    type.color.opacity(isSelected ? 0.3 : 0.15),
                                    type.color.opacity(isSelected ? 0.1 : 0.05),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 20,
                                endRadius: 40
                            )
                        )
                        .frame(width: 60, height: 60)
                        .scaleEffect(isPressed ? 1.1 : 1.0)

                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 48, height: 48)
                        .overlay(
                            Circle()
                                .strokeBorder(
                                    isSelected ? type.color.opacity(0.3) : .white.opacity(0.1),
                                    lineWidth: isSelected ? 2 : 1
                                )
                        )

                    Image(systemName: type.icon)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(type.color)
                        .symbolRenderingMode(.hierarchical)
                }

                Text(type.title)
                    .font(.custom("Lato-Regular", size: 14))
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .padding(.vertical, 20)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .strokeBorder(
                                isSelected ? type.color.opacity(0.3) : .white.opacity(0.1),
                                lineWidth: isSelected ? 2 : 1
                            )
                    )
                    .shadow(
                        color: isSelected ? type.color.opacity(0.2) : .black.opacity(0.08),
                        radius: isSelected ? 12 : 8,
                        x: 0,
                        y: isSelected ? 8 : 4
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [.white.opacity(0.08), .clear],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}

// MARK: - Upload Method Card

struct UploadMethodCard: View {
    let method: UploadMethod
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 44, height: 44)
                        .overlay(
                            Circle()
                                .strokeBorder(.white.opacity(0.1), lineWidth: 1)
                        )

                    Image(systemName: method.icon)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(.primary)
                }

                // Content
                VStack(alignment: .leading, spacing: 4) {
                    Text(method.title)
                        .font(.custom("Lato-Regular", size: 16))
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)

                    Text(method.description)
                        .font(.custom("Lato-Regular", size: 14))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }

                Spacer()

                // Selection indicator
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(.green)
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .strokeBorder(
                                isSelected ? .green.opacity(0.3) : .white.opacity(0.1),
                                lineWidth: isSelected ? 2 : 1
                            )
                    )
                    .shadow(
                        color: isSelected ? .green.opacity(0.1) : .black.opacity(0.05),
                        radius: 8,
                        x: 0,
                        y: 4
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Placeholder Views

struct ImagePicker: UIViewControllerRepresentable {
    #if canImport(UIKit)
        @Binding var selectedImage: UIImage?
    #else
        @Binding var selectedImage: NSImage?
    #endif
    let onComplete: () -> Void

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_: PHPickerViewController, context _: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)

            guard let provider = results.first?.itemProvider else { return }

            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { image, _ in
                    DispatchQueue.main.async {
                        self.parent.selectedImage = image as? UIImage
                        self.parent.onComplete()
                    }
                }
            }
        }
    }
}

struct DocumentPicker: UIViewControllerRepresentable {
    let onComplete: (URL) -> Void

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.pdf, .plainText, .image])
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_: UIDocumentPickerViewController, context _: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let parent: DocumentPicker

        init(_ parent: DocumentPicker) {
            self.parent = parent
        }

        func documentPicker(_: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else { return }
            parent.onComplete(url)
        }
    }
}

struct CameraView: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    let onComplete: () -> Void

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_: UIImagePickerController, context _: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraView

        init(_ parent: CameraView) {
            self.parent = parent
        }

        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }

            picker.dismiss(animated: true) {
                self.parent.onComplete()
            }
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}

#Preview {
    UploadDocumentFlow()
}
