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
NTSpAddNoteCommand class >> defaultIconName [

	^ #add
]

{ #category : 'default' }
NTSpAddNoteCommand class >> defaultName [

	^ 'Add Note'
]

{ #category : 'adding' }
NTSpAddNoteCommand >> addNoteNamed: aString [ 

	self facade addNoteNamed: aString
]

{ #category : 'executing' }
NTSpAddNoteCommand >> execute [
	"Request a title to create a new note"

	| answer |
	answer := self application newRequest
		title: 'Note title';
		label: 'Please provide the name of the new note';
		openModalWithParent: context window.

	(self isValidNote: answer) ifFalse: [ ^ self ].
	self addNoteNamed: answer trimBoth.
	self notesIndex refresh
]

{ #category : 'testing' }
NTSpAddNoteCommand >> isValidNote: aString [ 
	"Answer <true> if aString is a valid note title"
	
	^ self application isValidNote: aString
]
