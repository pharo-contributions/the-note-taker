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
NTSpRemoveNoteCommand class >> defaultName [

	^ 'Remove Note(s)'
]

{ #category : 'testing' }
NTSpRemoveNoteCommand >> canBeExecuted [ 

	^ self hasSelectedNote
]

{ #category : 'executing' }
NTSpRemoveNoteCommand >> execute [
	"Request a title to delete the selected note"

	(self confirm:
		 'Are you sure you want to remove the selected note(s)?') ifFalse: [
		^ self ].
	self selectedNotes do: [ :note |
			note exists ifTrue: [ note fileReference ensureDelete. self application log remove: note ] ].
	self noteTakerContainer removeNotes: self selectedNotes.
	self context updateRemovedNote
]
