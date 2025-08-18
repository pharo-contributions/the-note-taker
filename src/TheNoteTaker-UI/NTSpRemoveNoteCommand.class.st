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

{ #category : 'converting' }
NTSpRemoveNoteCommand >> asSpecCommand [

	^ super asSpecCommand
		  iconName: #delete;
		  shortcutKey: $D meta;
		  yourself
]

{ #category : 'testing' }
NTSpRemoveNoteCommand >> canBeExecuted [ 

	^ self hasSelectedNote
]

{ #category : 'executing' }
NTSpRemoveNoteCommand >> execute [
	"Request a title to delete the selected note"

	(self context confirm:
		 'Are you sure you want to remove the selected note(s)?') ifFalse: [
		^ self ].
	self selectedNotes do: [ :note |
			note exists ifTrue: [
					note fileReference ensureDelete.
					self context owner statusBar pushMessage:
						(self application log remove: note) ] ].
	self context removeNotes: self selectedNotes.
]
