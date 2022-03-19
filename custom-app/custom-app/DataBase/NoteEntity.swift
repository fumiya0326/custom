//
//  NoteEntity.swift
//  custom-app
//
//  Created by ISN98 on 2022/03/19.
//

import Foundation

class NoteEntity: Entity {
    
    var entityName = "Note"
    var attributes: Dictionary<String, Any>
    
    let title: String
    let pdfDocumentData: Data
    let updateDate: Date
    
    init(title: String, pdfDocumentData: Data) {
        self.title = title
        self.pdfDocumentData = pdfDocumentData
        updateDate = Date()
        self.attributes = [
            "title": title,
            "pdfDocument": pdfDocumentData,
            "updateDate": updateDate,
        ]
    }
    
    init(title: String, pdfDocumentData: Data, updateDate: Date) {
        self.title = title
        self.pdfDocumentData = pdfDocumentData
        self.updateDate = updateDate
        self.attributes = [
            "title": title,
            "pdfDocument": pdfDocumentData,
            "updateDate": updateDate,
        ]
    }
    
    
    /**
     すべてのNoteEntityを取得
     */
    static func fetchAll() -> [NoteEntity]{
        let allNotes = DatabaseController().fetch("Note", with: nil) as! [Note]
        
        var noteEntitys:[NoteEntity] = []
        allNotes.forEach({ note in
            noteEntitys.append(NoteEntity(title: note.title!, pdfDocumentData: note.pdfDocument!))
        })
        
        return  noteEntitys
    }
    
    func insert(){
        DatabaseController().insert(entity: self)
    }

}
