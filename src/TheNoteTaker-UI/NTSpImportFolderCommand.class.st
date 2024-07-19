"
Implements logic to add a single note to a note taking application. Particularily, it provides a user-request dialog to ask for note input information to be added.
"
Class {
	#name : 'NTSpImportFolderCommand',
	#superclass : 'NTSpAbstractCommand',
	#category : 'TheNoteTaker-UI-Commands',
	#package : 'TheNoteTaker-UI',
	#tag : 'Commands'
}

{ #category : 'default' }
NTSpImportFolderCommand class >> defaultDescription [

	^ 'Import folder of notes'
]

{ #category : 'default' }
NTSpImportFolderCommand class >> defaultName [

	^ 'Import Folder'
]

{ #category : 'adding' }
NTSpImportFolderCommand >> addNoteFromFileReference: aFileReference [

	self facade addNoteFromFileReference: aFileReference
]

{ #category : 'executing' }
NTSpImportFolderCommand >> execute [

	| folder |
	folder := StOpenDirectoryPresenter new 
					extent: 800 @800 ; 
					openModal.
	self halt.
	folder ifNil: [ ^ self ].
	self processFolder: folder.
	self context items: self facade notes
]

{ #category : 'testing' }
NTSpImportFolderCommand >> isValidNoteTitle: aString [ 
	"Answer <true> if aString is a valid note title"
	
	^ self application isValidNoteTitle: aString
]

{ #category : 'executing' }
NTSpImportFolderCommand >> processFolder: aFileReference [

	aFileReference allChildren
		select: [ :fileRef | self isValidNoteTitle: fileRef contents ]
		thenDo: [ :fileRef | self addNoteFromFileReference: fileRef ]
]

{ #category : 'executing' }
NTSpImportFolderCommand >> processSelections: selections [

	selections isEmptyOrNil
		ifTrue: [ ^ self ].
	selections
		select: [ : selection | self isValidNoteTitle: selection asFileReference contents ]
		thenDo: [ : selection | self addNoteFromFileReference: selection asFileReference ]
]

{ #category : 'executing' }
NTSpImportFolderCommand >> validNoteExtensions [
	"Answer a <Collection> of <String> each one specifying a valid file extension for a note"
	
	^ { 
		'txt' .
		'md' 
		}
]
