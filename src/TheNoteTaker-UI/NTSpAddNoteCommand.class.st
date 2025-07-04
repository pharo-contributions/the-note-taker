"
Implements logic to add a single note to a note taking application. Particularily, it provides a user-request dialog to ask for note input information to be added.
"
Class {
	#name : 'NTSpAddNoteCommand',
	#superclass : 'NTSpAbstractCommand',
	#category : 'TheNoteTaker-UI-Commands',
	#package : 'TheNoteTaker-UI',
	#tag : 'Commands'
}

{ #category : 'default' }
NTSpAddNoteCommand class >> defaultDescription [

	^ 'Add a note'
]

{ #category : 'default' }
NTSpAddNoteCommand class >> defaultName [

	^ 'Add Note'
]

{ #category : 'adding' }
NTSpAddNoteCommand >> addNoteNamed: aString [ 
	"Answer a new <NTNoteObject> named aString"

	^ self noteTakerContainer addNoteNamed: aString
]

{ #category : 'executing' }
NTSpAddNoteCommand >> execute [
	"Request a title to create a new note"

	| answer newNote |
	answer := self application newRequest
		          title: 'Note title';
		          label: 'Please provide the name of the new note';
		          openModalWithParent: context window.

	(self isValidNoteName: answer) ifFalse: [ ^ self ].
	newNote := self addNoteNamed: answer.
	self context
		items: self noteTakerContainer notes;
		selectNote: newNote.
	self application log add: newNote
]

{ #category : 'testing' }
NTSpAddNoteCommand >> isValidNoteName: aString [ 
	"Answer <true> if aString is a valid note title"
	
	^ self application isValidNoteName: aString
]
