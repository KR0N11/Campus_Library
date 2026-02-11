//
//  BookView.swift
//  Campus_Library
//
//  Created by user285973 on 2/10/26.
//

import SwiftUI

struct BookView: View {
    @EnvironmentObject var holder: CampusLibraryHolder
    
    @State private var searchText = ""
    @State private var selectedCategory: Category? = nil
    @State private var showAddSheet = false

    var filteredBooks: [Book] {
        holder.books.filter { book in
            let matchesCategory = selectedCategory == nil || book.category == selectedCategory
            let matchesSearch = searchText.isEmpty ||
                                (book.title?.localizedCaseInsensitiveContains(searchText) ?? false) ||
                                (book.author?.localizedCaseInsensitiveContains(searchText) ?? false)
            return matchesCategory && matchesSearch
        }
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        Button(action: { selectedCategory = nil }) {
                            Text("All")
                                .font(.system(size: 14, weight: .medium))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(selectedCategory == nil ? Color.blue : Color.gray.opacity(0.1))
                                .foregroundColor(selectedCategory == nil ? .white : .primary)
                                .clipShape(Capsule())
                        }
                        
                        ForEach(holder.categories, id: \.self) { cat in
                            Button(action: { selectedCategory = cat }) {
                                Text(cat.name ?? "")
                                    .font(.system(size: 14, weight: .medium))
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(selectedCategory == cat ? Color.blue : Color.gray.opacity(0.1))
                                    .foregroundColor(selectedCategory == cat ? .white : .primary)
                                    .clipShape(Capsule())
                            }
                        }
                    }
                    .padding()
                }

                if filteredBooks.isEmpty {
                    ContentUnavailableView("No books found", systemImage: "book.closed")
                } else {
                    List {
                        ForEach(filteredBooks, id: \.self) { book in
                            NavigationLink(destination: EditBookView(book: book)) {
                                BookRow(book: book)
                            }
                        }
                        .onDelete { indexSet in
                            indexSet.map { filteredBooks[$0] }.forEach(holder.deleteBook)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .searchable(text: $searchText, prompt: "Search title or author")
            .navigationTitle("Library")
            .toolbar {
                Button(action: { showAddSheet = true }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                }
            }
            .sheet(isPresented: $showAddSheet) {
                AddBookView()
            }
        }
    }
}

struct BookRow: View {
    @ObservedObject var book: Book

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(book.title ?? "Unknown Title")
                .font(.headline)
            
            Text("by \(book.author ?? "Unknown Author")")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack(spacing: 4) {
                Image(systemName: book.isAvailable ? "checkmark.circle.fill" : "clock.fill")
                Text(book.isAvailable ? "Available" : "Borrowed")
            }
            .font(.caption.bold())
            .foregroundColor(book.isAvailable ? .green : .orange)
            .padding(.top, 2)
        }
        .padding(.vertical, 4)
    }
}

struct AddBookView: View {
    @EnvironmentObject var holder: CampusLibraryHolder
    @Environment(\.dismiss) var dismiss
    
    @State private var title = ""
    @State private var author = ""
    @State private var isbn = ""
    @State private var selectedCat: Category?
    @State private var newCategoryName = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Book Details")) {
                    TextField("Title", text: $title)
                    TextField("Author", text: $author)
                    TextField("ISBN (Optional)", text: $isbn)
                }
                
                Section(header: Text("Category")) {
                    Picker("Select Category", selection: $selectedCat) {
                        Text("None").tag(Category?.none)
                        ForEach(holder.categories, id: \.self) { cat in
                            Text(cat.name ?? "").tag(cat as Category?)
                        }
                    }
                    
                    HStack {
                        TextField("Create New Category", text: $newCategoryName)
                        Button(action: {
                            holder.createCategory(name: newCategoryName)
                            newCategoryName = ""
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.blue)
                        }
                        .disabled(newCategoryName.isEmpty)
                    }
                }
            }
            .navigationTitle("Add New Book")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        holder.createBook(title: title, author: author, isbn: isbn, category: selectedCat)
                        dismiss()
                    }
                    .disabled(title.isEmpty || author.isEmpty)
                    .bold()
                }
            }
        }
    }
}

struct EditBookView: View {
    @EnvironmentObject var holder: CampusLibraryHolder
    @Environment(\.dismiss) var dismiss
    @ObservedObject var book: Book

    @State private var title = ""
    @State private var author = ""
    @State private var isbn = ""
    @State private var selectedCat: Category?

    var body: some View {
        Form {
            Section(header: Text("Book Information")) {
                TextField("Title", text: $title)
                TextField("Author", text: $author)
                TextField("ISBN", text: $isbn)
            }
            
            Section(header: Text("Classification")) {
                Picker("Category", selection: $selectedCat) {
                    Text("None").tag(Category?.none)
                    ForEach(holder.categories, id: \.self) { cat in
                        Text(cat.name ?? "").tag(cat as Category?)
                    }
                }
            }
            
            Section {
                Button(book.isAvailable ? "Mark as Borrowed" : "Mark as Available") {
                    book.isAvailable.toggle()
                }
                .foregroundColor(book.isAvailable ? .red : .green)
            }
        }
        .navigationTitle("Edit Details")
        .onAppear {
            title = book.title ?? ""
            author = book.author ?? ""
            isbn = book.isbn ?? ""
            selectedCat = book.category
        }
        .toolbar {
            Button("Done") {
                holder.updateBook(book, title: title, author: author, isbn: isbn, category: selectedCat)
                dismiss()
            }
            .disabled(title.isEmpty || author.isEmpty)
            .bold()
        }
    }
}
