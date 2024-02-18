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

{ #category : 'as yet unclassified' }
NTSpAbstractCommand >> facade [

	^ self application noteTakerFacade.
]

{ #category : 'testing' }
NTSpAbstractCommand >> hasSelectedNote [

	^ self selectedNote isNote
]

{ #category : 'accessing' }
NTSpAbstractCommand >> notesIndex [

	^ self context notesIndex
]

{ #category : 'accessing' }
NTSpAbstractCommand >> selectedNote [
	"Answer the currently selected <NTObject>"
	
	^ self notesIndex selectedItem
]

{ #category : 'accessing' }
NTSpAbstractCommand >> selectedNoteTitle [
	"Answer the currently selected <NTObject> title <String>"
	
	^ self selectedNote title
]
