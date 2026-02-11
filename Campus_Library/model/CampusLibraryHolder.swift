//
//  CampusLibraryHolder.swift
//  Campus_Library
//
//  Created by user285973 on 2/10/26.
//


import SwiftUI
import CoreData

class CampusLibraryHolder: ObservableObject {
    let context: NSManagedObjectContext
  
    @Published var categories: [Category] = []
    @Published var books: [Book] = []
    @Published var members: [Member] = []
    @Published var loans: [Loan] = []
    
    init(_ context: NSManagedObjectContext) {
        self.context = context
        refreshAll()
    }
    
    func refreshAll() {
        refreshCategories()
        refreshBooks()
        refreshMembers()
        refreshLoans()
    }
    
    func refreshCategories() {
        let req = Category.fetchRequest()
        req.sortDescriptors = [NSSortDescriptor(keyPath: \Category.name, ascending: true)]
        do { categories = try context.fetch(req)
        }
        catch { print("Error: \(error)")
        }
    }
    
    func refreshBooks() {
        let req = Book.fetchRequest()
        req.sortDescriptors = [NSSortDescriptor(keyPath: \Book.title, ascending: true)]
        do { books = try context.fetch(req)
        }
        catch { print("Error: \(error)")
        }
    }
    
    func refreshMembers() {
        let req = Member.fetchRequest()
        req.sortDescriptors = [NSSortDescriptor(keyPath: \Member.name, ascending: true)]
        do { members = try context.fetch(req)
        }
        catch { print("Error: \(error)")
        }
    }
    
    func refreshLoans() {
        let req = Loan.fetchRequest()
        req.sortDescriptors = [NSSortDescriptor(keyPath: \Loan.borrowedAt, ascending: false)]
        do { loans = try context.fetch(req)
        }
        catch
        { print("Error: \(error)")
        }
    }
   
    func save() {
        do { try context.save()
        }
        catch { print("Error saving: \(error)")
        }
    }
   
    func createCategory(name: String) {
        let newCat = Category(context: context)
        newCat.id = UUID()
        newCat.name = name
        save()
        refreshCategories()
    }
    
    func createBook(title: String, author: String, isbn: String, category: Category?) {
        let newBook = Book(context: context)
        newBook.id = UUID()
        newBook.title = title
        newBook.author = author
        newBook.isbn = isbn
        newBook.addedAt = Date()
        newBook.isAvailable = true
        newBook.category = category
        save()
        refreshBooks()
    }
    
        func updateBook(_ book: Book, title: String, author: String, isbn: String, category: Category?) {
            book.title = title
            book.author = author
            book.isbn = isbn
            book.category = category
            save()
            refreshBooks()
        }
    
    func deleteBook(_ book: Book) {
        context.delete(book)
        save()
        refreshBooks()
    }
    
    func createMember(name: String, email: String) {
        let newMember = Member(context: context)
        newMember.id = UUID()
        newMember.name = name
        newMember.email = email
        newMember.joinedAt = Date()
        save()
        refreshMembers()
    }
    
    func deleteMember(_ member: Member) {
        context.delete(member)
        save()
        refreshMembers()
    }
    
        func borrowBook(member: Member, book: Book, dueDays: Int = 7) {
            guard book.isAvailable else { return }
            
            let newLoan = Loan(context: context)
            newLoan.id = UUID()
            newLoan.borrowedAt = Date()
            newLoan.dueAt = Date().addingTimeInterval(TimeInterval(dueDays * 86400))

            newLoan.member = member
            newLoan.book = book
            book.isAvailable = false
            
            save()
            
            refreshBooks()
            refreshLoans()
            refreshMembers()
        }
    
    func returnLoan(_ loan: Loan) {
        loan.returnedAt = Date()
        loan.status = "Returned"
        loan.book?.isAvailable = true
        
        save()
        refreshBooks()
        refreshLoans()
        refreshMembers()
    }
}
