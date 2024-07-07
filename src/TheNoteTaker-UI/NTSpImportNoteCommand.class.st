"
Implements logic to add a single note to a note taking application. Particularily, it provides a user-request dialog to ask for note input information to be added.
"
Class {
	#name : 'NTSpImportNoteCommand',
	#superclass : 'NTSpAbstractCommand',
	#category : 'TheNoteTaker-UI-Commands',
	#package : 'TheNoteTaker-UI',
	#tag : 'Commands'
}

{ #category : 'default' }
NTSpImportNoteCommand class >> defaultDescription [

	^ 'Import notes'
]

{ #category : 'default' }
NTSpImportNoteCommand class >> defaultName [

	^ 'Import Notes'
]

{ #category : 'adding' }
NTSpImportNoteCommand >> addNoteFromFileReference: aString [ 

	self facade addNoteFromFileReference: aString
]

{ #category : 'executing' }
NTSpImportNoteCommand >> execute [

	| selections |
	selections := (StOpenFilePresenter new
						beMultipleSelection;
						extensions: self validNoteExtensions;
						yourself) openModal.
	self processSelections: selections.
	self context items: self facade notes
]

{ #category : 'testing' }
NTSpImportNoteCommand >> isValidNoteTitle: aString [ 
	"Answer <true> if aString is a valid note title"
	
	^ self application isValidNoteTitle: aString
]

{ #category : 'executing' }
NTSpImportNoteCommand >> processSelections: selections [

	selections isEmptyOrNil 
		ifTrue: [ ^ self ].
	selections 
		select: [ : selection | self isValidNoteTitle: selection asFileReference contents ]
		thenDo: [ : selection | self addNoteFromFileReference: selection asFileReference ].
]

{ #category : 'executing' }
NTSpImportNoteCommand >> validNoteExtensions [
	"Answer a <Collection> of <String> each one specifying a valid file extension for a note"
	
	^ { 
		'txt' .
		'mic' .
		'md' 
		}
]
