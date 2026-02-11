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
            VStack {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        Button("All") { selectedCategory = nil }
                            .padding(8)
                            .background(selectedCategory == nil ? Color.blue.opacity(0.2) : Color.gray.opacity(0.1))
                            .cornerRadius(8)
                        
                        ForEach(holder.categories, id: \.self) { cat in
                            Button(cat.name ?? "") { selectedCategory = cat }
                                .padding(8)
                                .background(selectedCategory == cat ? Color.blue.opacity(0.2) : Color.gray.opacity(0.1))
                                .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal)
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
                }
            }
            .searchable(text: $searchText, prompt: "Search title or author")
            .navigationTitle("Library Books")
            .toolbar {
                Button(action: { showAddSheet = true }) {
                    Image(systemName: "plus")
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
        VStack(alignment: .leading) {
            Text(book.title ?? "Unknown Title")
                .font(.headline)
            Text(book.author ?? "Unknown Author")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            if book.isAvailable {
                Text("Available")
                    .font(.caption)
                    .foregroundColor(.green)
            } else {
                Text("Borrowed")
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
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
                Section("Book Details") {
                    TextField("Title", text: $title)
                    TextField("Author", text: $author)
                    TextField("ISBN (Optional)", text: $isbn)
                }
                
                Section("Category") {
                    Picker("Select Category", selection: $selectedCat) {
                        Text("None").tag(Category?.none)
                        ForEach(holder.categories, id: \.self) { cat in
                            Text(cat.name ?? "").tag(cat as Category?)
                        }
                    }
                    
                    HStack {
                        TextField("New Category", text: $newCategoryName)
                        Button("Add") {
                            holder.createCategory(name: newCategoryName)
                            newCategoryName = ""
                        }
                        .disabled(newCategoryName.isEmpty)
                    }
                }
            }
            .navigationTitle("Add Book")
            .toolbar {
                Button("Save") {
                    holder.createBook(title: title, author: author, isbn: isbn, category: selectedCat)
                    dismiss()
                }
                .disabled(title.isEmpty || author.isEmpty)
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
            Section("Book Details") {
                TextField("Title", text: $title)
                TextField("Author", text: $author)
                TextField("ISBN", text: $isbn)
            }
            
            Section("Category") {
                Picker("Category", selection: $selectedCat) {
                    Text("None").tag(Category?.none)
                    ForEach(holder.categories, id: \.self) { cat in
                        Text(cat.name ?? "").tag(cat as Category?)
                    }
                }
            }
        }
        .navigationTitle("Edit Book")
        .onAppear {
            title = book.title ?? ""
            author = book.author ?? ""
            isbn = book.isbn ?? ""
            selectedCat = book.category
        }
        .toolbar {
            Button("Save") {
                holder.updateBook(book, title: title, author: author, isbn: isbn, category: selectedCat)
                dismiss()
            }
            .disabled(title.isEmpty || author.isEmpty)
        }
    }
}
