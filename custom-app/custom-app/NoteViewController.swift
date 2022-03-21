//
//  NoteViewController.swift
//  custom-app
//
//  Created by ISN98 on 2022/03/20.
//

import UIKit
import PDFKit

class NoteViewController: UIViewController {
    
    var noteEntity: NoteEntity?
    
    @IBOutlet weak var pdfView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let noteEntity = self.noteEntity else {
            fatalError()
        }
    
        navigationItem.title = noteEntity.title
        let pdfDocument = PDFDocument(data: noteEntity.pdfDocumentData)
        let pdfView = PDFView(frame: self.view.bounds)
        pdfView.document = pdfDocument
        pdfView.autoScales = true
        pdfView.translatesAutoresizingMaskIntoConstraints = false
        
        self.pdfView.addSubview(pdfView)
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
