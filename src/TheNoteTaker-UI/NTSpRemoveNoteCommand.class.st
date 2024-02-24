Class {
	#name : 'NTSpRemoveNoteCommand',
	#superclass : 'NTSpAbstractCommand',
	#category : 'TheNoteTaker-UI-Commands',
	#package : 'TheNoteTaker-UI',
	#tag : 'Commands'
}

{ #category : 'default' }
NTSpRemoveNoteCommand class >> defaultDescription [

	^ 'Remove the selected note'
]

{ #category : 'default' }
NTSpRemoveNoteCommand class >> defaultIconName [

	^ #delete
]

{ #category : 'default' }
NTSpRemoveNoteCommand class >> defaultName [

	^ 'Remove Note'
]

{ #category : 'testing' }
NTSpRemoveNoteCommand >> canBeExecuted [ 

	^ self hasSelectedNote
]

{ #category : 'executing' }
NTSpRemoveNoteCommand >> execute [
	"Request a title to create a new note"

	self facade removeNote: self selectedNote.
	self context refresh.
]
