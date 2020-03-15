//
//  SemesterListView.swift
//  GradeCalc
//
//  Created by Marlon Lückert on 08.03.20.
//  Copyright © 2020 Marlon Lückert. All rights reserved.
//

import Foundation
import SwiftUI

enum ActiveSheet {
   case add, edit
}

struct SubjectListView: View {
    
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @FetchRequest(entity: Semester.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Semester.title, ascending: true)]) var semesters: FetchedResults<Semester>
    
    @State var sheetVisible = false
    @State var activeSheet: ActiveSheet = .add
    
    @State var currentSubject: Subject?
    
    @State private var refreshing = false
    private var didSave =  NotificationCenter.default.publisher(for: .NSManagedObjectContextDidSave)
    
    @State var menuOpen = false
    
    @State var simulation = false
    
    init() {
        UITableView.appearance().separatorStyle = .none
        UITableView.appearance().backgroundColor = UIColor(named: "BlueBackground")
    }
    
    var body: some View {
        ZStack {
            ZStack {
                VStack {
                    VStack {
                        Toggle(isOn: self.$simulation) {
                            Text("Simulation")
                        }
                        
                    }
                    .padding(30)
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .topLeading)
                    .background(Color(UIColor(named: "WhiteBackground") ?? .white))
                    .cornerRadius(20)
                    .shadow(color: Color(.black).opacity(0.6), radius: 2, x: 0, y: 1)
                    .scaleEffect(self.menuOpen ? 1 : 0.5, anchor: .topTrailing)
                    .padding(.horizontal, 30)
                    .animation(.spring(response: 0.4, dampingFraction: 0.7, blendDuration: 0.2))
                    Spacer()
                }
                
            }
            .zIndex(2)
            .opacity(self.menuOpen ? 1 : 0)
            .offset(y: 50)
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
                .padding(.bottom, -10)
            ZStack(alignment: .bottom) {
                VStack() {
                    List {
                        Rectangle()
                           .frame(height: 5)
                           .foregroundColor(.clear)
                           .background(Color(UIColor(named: "BlueBackground") ?? .blue))
                           .listRowBackground(Color(UIColor(named: "BlueBackground") ?? .blue))
                        ForEach(self.semesters) { semester in
                            Text(semester.title ?? "semester")
                                .font(.headline)
                                .padding(.horizontal, 10)
                                .padding(.top, 10)
                            .padding(.bottom, 5)
                                .listRowBackground(Color(UIColor(named: "BlueBackground") ?? .blue))
                            ForEach(semester.subjectsArray, id: \.title) { subject in
                                Button(action: {
                                    self.currentSubject = subject
                                    self.activeSheet = .edit
                                    self.sheetVisible = true
                                }){
                                    SubjectCellView(subject: subject)
                                }
                                .buttonStyle(BorderlessButtonStyle())
                                    .contextMenu {
                                        Button(action: {
                                            self.currentSubject = subject
                                            self.activeSheet = .edit
                                            self.sheetVisible = true
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
                        }
                        Rectangle()
                            .frame(height: 100)
                            .foregroundColor(.clear)
                            .background(Color(UIColor(named: "BlueBackground") ?? .blue))
                            .listRowBackground(Color(UIColor(named: "BlueBackground") ?? .blue))
                    }
                    .environment(\.defaultMinListRowHeight, 0)
                    .cornerRadius(20)
                    .padding(.top, -20)
                    .padding(.bottom, -30)
                    
                }
                HStack {
                    Spacer()
                    Button(action: {
                        self.activeSheet = .add
                        self.sheetVisible = true
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
        }
        .sheet(isPresented: $sheetVisible) {
            if self.activeSheet == .edit {
                SubjectAddView(subject: self.currentSubject,isPresented: self.$sheetVisible)
                .environment(\.managedObjectContext, self.managedObjectContext)
            }
            if self.activeSheet == .add {
                SubjectAddView(subject:nil,isPresented: self.$sheetVisible)
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
