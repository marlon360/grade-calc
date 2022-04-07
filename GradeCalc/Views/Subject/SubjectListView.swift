//
//  SemesterListView.swift
//  GradeCalc
//
//  Created by Marlon Lückert on 08.03.20.
//  Copyright © 2020 Marlon Lückert. All rights reserved.
//

import Foundation
import SwiftUI

enum Sheet {
    case add, edit
}

struct SubjectListView: View {
    
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @FetchRequest(entity: Semester.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Semester.title, ascending: true)]) var semesters: FetchedResults<Semester>
    
    
    class SheetMananger: ObservableObject{
        
        @Published var showSheet = false
        @Published var whichSheet: Sheet = .add
        @Published var subject: Subject? = nil
    }
    
    @StateObject var sheetManager = SheetMananger()
    
    @State private var refreshing = false
    private var didSave =  NotificationCenter.default.publisher(for: .NSManagedObjectContextDidSave)
    
    @State var menuOpen = false
    
    @State var simulation = false
    
    @State var showsSemesterRenameAlert = false
    @State var selectedSemester: Semester?
    
    var topPadding: CGFloat = 0;
    
    init() {
        if #available(iOS 15.0, *) {
            topPadding = -20
        }
        UITableView.appearance().separatorStyle = .none
        UITableView.appearance().backgroundColor = UIColor(named: "BlueBackground")
    }
    
    var body: some View {
        ZStack {
            Rectangle()
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
                .foregroundColor(.clear)
                .background(Color(UIColor(named: "DarkBlueBackground") ?? .blue))
                .opacity(0.8)
                .edgesIgnoringSafeArea(.all)
                .zIndex(1)
                .opacity(self.menuOpen ? 1 : 0)
                .onTapGesture {
                    withAnimation {
                        self.menuOpen = false
                    }
                }
            
            VStack {
                GradeAverageView(menuOpen: self.$menuOpen, simulation: self.$simulation)
                ZStack(alignment: .bottom) {
                    if semesters.count == 0 {
                        VStack {
                            Spacer()
                            Text("no grades")
                                .multilineTextAlignment(.center)
                            Spacer()
                        }
                        .zIndex(2)
                    }
                    VStack() {
                        ZStack {
                            List {
                                ForEach(self.semesters) { semester in
                                    Button (semester.title ?? "semester") {
                                        self.selectedSemester = semester
                                        self.showsSemesterRenameAlert = true
                                    }
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                    .padding(.horizontal, 10)
                                    .padding(.top, 10)
                                    .padding(.bottom, 5)
                                    .listRowBackground(Color(UIColor(named: "BlueBackground") ?? .blue))
                                    .hideRowSeparator()
                                    
                                    ForEach(semester.subjectsArray, id: \.self) { subject in
                                        Button(action: {
                                            self.sheetManager.subject = subject
                                            self.sheetManager.whichSheet = .edit
                                            self.sheetManager.showSheet = true
                                        }){
                                            SubjectCellView(subject: subject)
                                        }
                                        .buttonStyle(BorderlessButtonStyle())
                                        .contextMenu {
                                            Button(action: {
                                                self.sheetManager.subject = subject
                                                self.sheetManager.whichSheet = .edit
                                                self.sheetManager.showSheet = true
                                            }) {
                                                Text("edit")
                                                Image(systemName: "pencil")
                                            }
                                            Button(action: {
                                                self.toggleActiveState(subject: subject)
                                            }) {
                                                Text(subject.active ? "deactivate" : "activate")
                                                Image(systemName: subject.active ? "xmark" : "checkmark")
                                            }
                                            Spacer()
                                            Button(action: {
                                                self.removeSubject(subject: subject)
                                            }) {
                                                Text("delete")
                                                    .foregroundColor(.red)
                                                Image(systemName: "trash")
                                                    .foregroundColor(.red)
                                            }
                                        }
                                    }
                                    .onDelete{ row in
                                        self.removeSubject(semester: semester, offsets: row)
                                    }
                                    .onReceive(self.didSave) { _ in
                                        self.refreshing.toggle()
                                    }
                                    .listRowBackground(Color(UIColor(named: "BlueBackground") ?? .blue))
                                    .hideRowSeparator()
                                }
                                Rectangle()
                                    .frame(height: 100)
                                    .foregroundColor(.clear)
                                    .background(Color(UIColor(named: "BlueBackground") ?? .blue))
                                    .listRowBackground(Color(UIColor(named: "BlueBackground") ?? .blue))
                            }
                            .padding(.top, topPadding)
                        }
                        .environment(\.defaultMinListRowHeight, 0)
                        .cornerRadius(20)
                        .padding(.top, -30)
                        .padding(.bottom, -30)
                        
                    }
                    HStack {
                        Spacer()
                        Button(action: {
                            self.sheetManager.whichSheet = .add
                            self.sheetManager.showSheet = true
                        }) {
                            Image(systemName:self.refreshing ? "plus" : "plus")
                                .font(.system(size: 24, weight: .bold))
                                .padding(20)
                        }
                        .foregroundColor(Color.white)
                        .background(LinearGradient(gradient: Gradient(colors: [Color(UIColor(named: "GradientColor1") ?? .blue), Color(UIColor(named: "GradientColor2") ?? .purple)]), startPoint: .topLeading, endPoint: .bottomTrailing))
                        .mask(Circle())
                        .shadow(color: Color(.black).opacity(0.6), radius: 1.8, x: 0, y: 1)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 10)
                }
                .alert(isPresented: self.$showsSemesterRenameAlert, TextAlert(title: NSLocalizedString("rename", comment: "rename"), placeholder: self.selectedSemester?.title ?? "Semester", accept: NSLocalizedString("save", comment: "save"), cancel: NSLocalizedString("cancel", comment: "cancel"), action: {
                    if let newTitle = $0, let semester = self.selectedSemester {
                        self.renameSemester(semester: semester, title: newTitle)
                    } else {
                        print("Cannot save")
                    }
                }))
            }
            .sheet(isPresented: self.$sheetManager.showSheet) {
                if self.sheetManager.whichSheet == .edit {
                    SubjectAddView(subject: self.sheetManager.subject,isPresented: self.$sheetManager.showSheet)
                        .environment(\.managedObjectContext, self.managedObjectContext)
                }
                if self.sheetManager.whichSheet == .add {
                    SubjectAddView(subject:nil,isPresented: self.$sheetManager.showSheet)
                        .environment(\.managedObjectContext, self.managedObjectContext)
                }
            }
        }
        
    }
    
    func removeSubject(semester: Semester, offsets: IndexSet) {
        for index in offsets {
            let subject = semester.subjectsArray[index]
            removeSubject(subject: subject)
        }
    }
    
    func toggleActiveState(subject: Subject) {
        subject.active.toggle()
        do {
            try managedObjectContext.save()
        } catch {
            print(error)
        }
    }
    
    func renameSemester(semester: Semester, title: String) {
        semester.title = title;
        do {
            try managedObjectContext.save()
        } catch {
            print(error)
        }
    }
    
    func removeSubject(subject: Subject) {
        if let semester = subject.semester {
            if (semester.subjectsArray.count <= 1) {
                managedObjectContext.delete(semester)
            }
        }
        managedObjectContext.delete(subject)
        do {
            try managedObjectContext.save()
        } catch {
            print(error)
        }
    }
    
}
