//
//  HomeView.swift
//  toDoListApp
//
//  Created by 山田滉暁 on 2022/04/30.
//

import SwiftUI

struct HomeView: View {
    
    @Environment(\.managedObjectContext) var viewContext

    //データの取得
    @FetchRequest(entity: Task.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Task.name, ascending: true)], animation: .easeInOut) var tasks: FetchedResults<Task>
    
    //サイドビュー
    @State private var offset = CGFloat.zero
    @State private var closeOffset = CGFloat.zero
    @State private var openOffset = CGFloat.zero
    
    @State var showHamburgerMenu = false
    
    var body: some View {
        
        GeometryReader { geometry in
            
            ZStack(alignment: .leading) {

                NavigationView {
            
                    List{
                        
                        ForEach(self.tasks, id: \.self) { task in
                            
                           HStack {
                               Text(task.name ?? "nil")

                               Spacer()

                               Text(task.priority ?? "nil")
                           }
                           .frame(height: 50)
                           .padding(.horizontal, 20)
                        }
                        .onDelete(perform: deleteTask)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.vertical, 3)
                    }
                    .listStyle(.plain)
                    
                    .toolbar {
                        
                        ToolbarItem(placement: .navigationBarLeading) {
                            
                            Button(action: {
                                self.offset = self.openOffset
                            }) {
                                Image(systemName: "line.horizontal.3")
                            }
                        }
                        
                        ToolbarItem(placement: .navigationBarTrailing) {
                            KebabMenu()
                        }
                    }
                    Color.gray.opacity(
                        Double((self.closeOffset - self.offset) / self.closeOffset) - 0.4
                    )
                }
                
                ZStack {
                    AddTaskButton()
                        .frame(width: 80, height: 80)
                        //新規ボタンの位置変更
                        .offset(x: 280, y: 340)
                }
                
                HamburgerMenu()
                    .background(Color.white)
                    .frame(width: geometry.size.width * 0.82)
                    .edgesIgnoringSafeArea(.bottom)
                    .onAppear(perform: {
                        self.offset = geometry.size.width * -1
                        self.closeOffset = self.offset
                        self.openOffset = .zero
                    })
                    .offset(x: self.offset)

                    .animation(.default, value: self.offset)
            }
            
//            .gesture(DragGesture(minimumDistance: 5)
//                .onChanged { value in
//                    if (self.offset < self.openOffset) {
//                        self.offset = self.closeOffset + value.translation.width
//                    }
//                }
//                .onEnded { value in
//                    if (value.location.x > value.startLocation.x) {
//                        self.offset = self.openOffset
//                    }
//                    else {
//                        self.offset = self.closeOffset
//                   }
//                }
//            )
        }
    }
    
    private func deleteTask(offsets: IndexSet) {
            withAnimation {
                offsets.map { tasks[$0] }.forEach(viewContext.delete)
    
                do {
                    try viewContext.save()
                } catch {
                    let nsError = error as NSError
                    fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                }
            }
        }

}


struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct HamburgerMenu: View {

    @State var showSettingView = false
    
    var body: some View {
        
        NavigationView {
            
            VStack(alignment: .leading, spacing: 0) {
                
                VStack {
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: 5)
                
                Divider()
                
                VStack {
                    
                    Button {
                        
                    } label: {
                        Label("全てのリスト", systemImage: "list.bullet.rectangle")
                    }
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 25)
                
                Divider()
                
                ScrollView (.vertical, showsIndicators: true) {
                    
                    VStack(alignment: .leading) {
                        
                        HStack {
                            
                            Image(systemName: "list.bullet")
                                .foregroundColor(.primary.opacity(0.4))
                            Text("リスト")
                                .foregroundColor(.primary.opacity(0.4))
                        }
                        Divider()
                        
                        .padding()
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 15)
                    .padding(.horizontal, 10)
                }
                .frame(maxWidth: .infinity, maxHeight: 600)

                VStack(alignment: .leading, spacing: 20) {
                    
                    Divider()
                    
                    TabButton(image: "Setting")

                }
            }
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity,maxHeight: .infinity, alignment: .leading)
        }
    }
    
    @ViewBuilder
    func TabButton(image: String) -> some View {
        
        Button {
            showSettingView.toggle()
        } label: {
            Image(image)
               .resizable()
               .renderingMode(.template)
               .aspectRatio(contentMode: .fill)
               .foregroundColor(.primary)
               .frame(width: 25, height: 25)
        }
        .padding(.horizontal, 10)
        .padding(.bottom, 0)
        .sheet(isPresented: $showSettingView) {
            SettingView()
        }
    }
}

struct KebabMenu: View {

    @State var showEdit = false
    @State var showAlert = false
    
    var body: some View {
        
        VStack  {
            
            Menu {
                
                Button {
                    self.showEdit.toggle()
                } label: {
                    Label("リストを編集", systemImage: "pencil")
                }
                
                Button {
                    self.showAlert.toggle()
                } label: {
                    Label("リストを削除", systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis")
                    .rotationEffect(.degrees(90))
            }
        }
        .sheet(isPresented: $showEdit) {
            EditTaskView()
        }
        
        .alert("このリストを削除しますか？", isPresented: $showAlert) {
            Button("削除", role: .destructive) {
                
            }
        } message: {
           Text("この操作によりリストが削除されます。")
        }
    }
}

struct AddTaskButton: View {
    
    @Environment(\.managedObjectContext) var viewContext
    
    @State private var showAddTaskView = false
    
    var body: some View {

            Button {
                showAddTaskView.toggle()
            } label: {
                Image(systemName: "plus.circle.fill")
                    .resizable()
                    .frame(width: 80, height: 80)
                    .padding()
            }
            .sheet(isPresented: $showAddTaskView) {
                AddTaskView().environment(\.managedObjectContext, self.viewContext)
            }
    }
}
