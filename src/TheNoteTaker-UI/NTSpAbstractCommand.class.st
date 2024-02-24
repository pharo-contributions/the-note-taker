Class {
	#name : 'NTSpAbstractCommand',
	#superclass : 'CmCommand',
	#category : 'TheNoteTaker-UI-Commands',
	#package : 'TheNoteTaker-UI',
	#tag : 'Commands'
}

{ #category : 'accessing' }
NTSpAbstractCommand >> application [

	^ self context application
]

{ #category : 'accessing' }
NTSpAbstractCommand >> applicationClass [

	^ self application class
]

{ #category : 'accessing' }
NTSpAbstractCommand >> facade [

	^ self application noteTakerFacade.
]

{ #category : 'testing' }
NTSpAbstractCommand >> hasSelectedNote [
	"Answer <true> if the items index presenter has focus on a note"

	^ self context hasSelectedNote
]

{ #category : 'accessing' }
NTSpAbstractCommand >> notesIndex [

	^ self context items
]

{ #category : 'accessing' }
NTSpAbstractCommand >> selectedNote [
	"Answer the currently selected <NTObject>"
	
	^ self context selectedNote

]

{ #category : 'accessing' }
NTSpAbstractCommand >> selectedNoteTitle [
	"Answer the currently selected <NTObject> title <String>"
	
	^ self selectedNote title
]
