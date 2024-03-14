"
If the command context has a selected note, then provide a confirmation request to the user to delete a note.

"
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
	"Request a title to delete the selected note"

	self facade removeNote: self selectedNote.
	self context refresh.
]
