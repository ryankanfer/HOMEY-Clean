import SwiftUI

struct SearchSection: View {
    @Binding var searchText: String
    @Binding var showSearchSuggestions: Bool
    @Binding var isSearching: Bool
    @Binding var searchResults: [DocumentVault]
    
    let performSearch: (String) -> Void
    let getSmartSearchSuggestions: () -> [String]
    let onVaultSelected: (DocumentVault) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                    .font(.title3)
                
                TextField("Ask me anything about your documents...", text: $searchText)
                    .textFieldStyle(.plain)
                    .foregroundColor(.white)
                    .font(.body)
                    .onChange(of: searchText) { newValue in
                        performSearch(newValue)
                    }
                
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                        isSearching = false
                        searchResults = []
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                            .font(.title3)
                    }
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.15))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.blue.opacity(0.3), lineWidth: isSearching ? 2 : 0)
                    )
            )
            
            // Smart suggestions
            if showSearchSuggestions && searchText.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Try asking:")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 8) {
                        ForEach(getSmartSearchSuggestions(), id: \.self) { suggestion in
                            Button(action: {
                                searchText = suggestion
                                performSearch(suggestion)
                            }) {
                                Text(suggestion)
                                    .font(.caption)
                                    .foregroundColor(.blue)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color.blue.opacity(0.1))
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(.top, 8)
            }
            
            // Search results
            if isSearching && !searchResults.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Search Results")
                            .font(.headline.bold())
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Text("\(searchResults.count) found")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    ForEach(searchResults) { vault in
                        DocumentCategoryCard(vault: vault) {
                            onVaultSelected(vault)
                        }
                    }
                }
                .padding(.top, 12)
            } else if isSearching && searchResults.isEmpty && !searchText.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "doc.text.magnifyingglass")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                    
                    Text("No documents found")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text("Try searching for 'tax documents', 'income proof', or 'identification'")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                .padding(40)
            }
        }
    }
}