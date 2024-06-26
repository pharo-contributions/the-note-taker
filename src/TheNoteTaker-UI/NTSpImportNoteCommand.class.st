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
NTSpImportNoteCommand class >> defaultIconName [

	^ #add
]

{ #category : 'default' }
NTSpImportNoteCommand class >> defaultName [

	^ 'Import Notes'
]

{ #category : 'adding' }
NTSpImportNoteCommand >> addNoteNamed: aString [ 

	self facade addNoteNamed: aString
]

{ #category : 'executing' }
NTSpImportNoteCommand >> execute [

	| selection |
	selection := (StOpenFilePresenter new filter: StFileFilter new)
		             openModal.
	(selection notNil and: [ selection isFile ]) ifFalse: [ ^ self ].
	(self isValidNote: selection asFileReference contents) ifTrue: [
		self addNoteNamed:
			selection asFileReference basenameWithoutExtension ].
	self context items: self facade notes
]

{ #category : 'testing' }
NTSpImportNoteCommand >> isValidNote: aString [ 
	"Answer <true> if aString is a valid note title"
	
	^ self application isValidNote: aString
]
