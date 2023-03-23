//
//  ProductEditView.swift
//  Expired
//
//  Created by satgi on 2023-01-25.
//

import SwiftUI

// Default Expiry Date: 2 weeks later
let DEFAULT_EXPIRY_DATE = Date(timeIntervalSinceNow: 86400 * 14)

struct ProductEditView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var productStore: ProductStore
    @EnvironmentObject var notificationVM: NotificationViewModel

    @State private var selectedProduct: Product?
    @State private var title: String
    @State private var category: Category?
    @State private var memo: String
    @State private var expiryDate: Date
    @State private var image: UIImage?
    @State private var showingPhotoLibrary: Bool = false
    @State private var showingPhotoAction: Bool = false
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary

    init(product: Product?) {
        if let selectedProduct = product {
            _selectedProduct = State(initialValue: selectedProduct)
            _title = State(initialValue: selectedProduct.title ?? "")
            _memo = State(initialValue: selectedProduct.memo ?? "")
            _category = State(initialValue: selectedProduct.category)
            _expiryDate = State(initialValue: selectedProduct.expiryDate ?? DEFAULT_EXPIRY_DATE)
            _image = State(initialValue: selectedProduct.image != nil ? UIImage(data: selectedProduct.image!) : nil)
        } else {
            _title = State(initialValue: "")
            _memo = State(initialValue: "")
            _category = State(initialValue: nil)
            _expiryDate = State(initialValue: DEFAULT_EXPIRY_DATE)
            _image = State(initialValue: nil)
        }
    }

    var body: some View {
        VStack {
            List {
                Section {
                    HStack {
                        Spacer()
                        ProductImage(image: image, size: .large)
                            .overlay(alignment: .bottomTrailing) {
                                Image(systemName: "pencil.circle.fill")
                                    .symbolRenderingMode(.multicolor)
                                    .foregroundColor(.accentColor)
                                    .font(.system(size: 30))
                                    .offset(x: 10, y: 10)
                                    .onTapGesture {
                                        showingPhotoAction.toggle()
                                    }
                            }
                        Spacer()
                    }
                    .padding(.vertical, 20)
                }
                Section(header: Text("Product Info")) {
                    HStack {
                        Image(systemName: "pencil")
                        TextField("Title", text: $title)
                    }
                    HStack {
                        Image(systemName: "note.text")
                        TextField("Memo", text: $memo)
                    }
                }

                Section(header: Text("Category")) {
                    HStack {
                        Image(systemName: "tray.fill")
                        Picker("Category", selection: $category) {
                            Text("None").tag(Category?(nil))
                            ForEach(productStore.categories) { category in
                                Text(category.title ?? "Unknown").tag(category as Category?)
                            }
                        }
                    }
                }

                Section(header: Text("Expiry Date")) {
                    HStack {
                        Image(systemName: "hourglass.tophalf.fill")
                        DatePicker("Expiries At", selection: $expiryDate, displayedComponents: [.date, .hourAndMinute])
                    }
                }
            }
            .listStyle(GroupedListStyle())
        }
        .navigationTitle(navTitle)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    save()
                } label: {
                    Text("Save")
                }
                .disabled(title.isEmpty)
            }
        }
        .confirmationDialog("Update picture", isPresented: $showingPhotoAction, titleVisibility: .hidden) {
            if image != nil {
                Button("Remove picture", role: .destructive) {
                    image = nil
                }
            }
            
            Button("Select from photo library") {
                sourceType = .photoLibrary
                showingPhotoLibrary.toggle()
            }
            
            Button("Take a photo") {
                sourceType = .camera
                showingPhotoLibrary.toggle()
            }
        }
        .sheet(isPresented: $showingPhotoLibrary) {
            ImagePicker(image: $image, sourceType: sourceType)
        }
    }

    private var navTitle: String {
        return selectedProduct?.title ?? "Add Product"
    }
    
    private func save() {
        withAnimation {
            let now = Date()

            // To be optimized
            var updatedProduct: Product

            if selectedProduct == nil {
                updatedProduct = Product(context: viewContext)
                updatedProduct.id = UUID()
                updatedProduct.archived = false
                updatedProduct.createdAt = now
            } else {
                updatedProduct = selectedProduct!

                // If the existed product was archived and its new expiryDate is later from now
                // Reset the its archived value to false (unarchive it)
                if updatedProduct.archived && expiryDate > Date() {
                    updatedProduct.archived = false
                }
            }

            updatedProduct.category = category
            updatedProduct.image = image != nil ? image!.jpegData(compressionQuality: 0.3) : nil
            updatedProduct.title = title
            updatedProduct.expiryDate = expiryDate
            updatedProduct.memo = memo
            updatedProduct.updatedAt = now

            productStore.save(viewContext)
            notificationVM.updateProductNotifications(viewContext, product: updatedProduct)
            self.presentationMode.wrappedValue.dismiss()
        }
    }
}

struct ProductEditView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ProductEditView(product: ProductStore(PersistenceController.preview.container.viewContext).products[0])
        }
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        .environmentObject(ProductStore(PersistenceController.preview.container.viewContext))
        .environmentObject(NotificationViewModel())
    }
}
