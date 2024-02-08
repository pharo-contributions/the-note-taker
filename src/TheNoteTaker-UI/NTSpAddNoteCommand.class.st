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

{ #category : 'accessing' }
NTSpAddNoteCommand >> execute [
	"Request a title to create a new note"

	| answer |
	answer := self application newRequest 
		title: 'Note title';
		openModal.
	(answer isEmptyOrNil or: [ answer isValidNoteTitle not ]) 
		ifTrue: [ ^ self ].
	answer trimBoth.
	self notesIndex refresh
]
