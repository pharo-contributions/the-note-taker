"
Presents a table with basic metadata information about saved notes in the system.

"
Class {
	#name : 'NTSpNoteIndexPresenter',
	#superclass : 'SpPresenterWithModel',
	#instVars : [
		'componentList'
	],
	#category : 'TheNoteTaker-UI-Core',
	#package : 'TheNoteTaker-UI',
	#tag : 'Core'
}

{ #category : 'accessing' }
NTSpNoteIndexPresenter class >> buildCommandsGroupWith: presenterInstance forRoot: rootCommandGroup [

	rootCommandGroup
		register: (self buildNTContextualGroupWith: presenterInstance)
]

{ #category : 'accessing' }
NTSpNoteIndexPresenter class >> buildNTContextualGroupWith: presenterInstance [

	^ (CmCommandGroup named: 'NTSelContextualMenu') asSpecGroup
		register: (self buildNoteTakerOperationsGroupWith: presenterInstance);		
		yourself
]

{ #category : 'accessing' }
NTSpNoteIndexPresenter class >> buildNoteTakerOperationsGroupWith: presenterInstance [

	^ (CmCommandGroup named: 'NoteTakerMenu') asSpecGroup
		  register: ((NTSpImportNoteCommand
				    forSpecWithIconNamed: #into
				    shortcutKey: 'I' asShortcut) context: presenterInstance);
		  register: ((NTSpRemoveNoteCommand
				    forSpecWithIconNamed: #delete
				    shortcutKey: 'D' asShortcut) context: presenterInstance);
		  register: ((NTSpAddTagCommand
				    forSpecWithIconNamed: #add
				    shortcutKey: 'T' asShortcut) context: presenterInstance);
		  register: ((NTSpRemoveTagCommand
				    forSpecWithIconNamed: #delete
				    shortcutKey: 'D' asShortcut) context: presenterInstance);
		  beDisplayedAsGroup;
		  yourself
]

{ #category : 'layout' }
NTSpNoteIndexPresenter >> defaultLayout [

	^ SpBoxLayout newTopToBottom
		  add: componentList;
		  yourself
]

{ #category : 'layout' }
NTSpNoteIndexPresenter >> defaultOutputPort [

	^ SpDropListSelectionPort newPresenter: self
]

{ #category : 'testing' }
NTSpNoteIndexPresenter >> hasSelectedNote [

	^ componentList listSize ~= 0
]

{ #category : 'initialization' }
NTSpNoteIndexPresenter >> initializePresenters [

	componentList := self instantiate: SpComponentListPresenter.
	componentList beMultipleSelection.

	componentList contextMenu: [
			(self rootCommandsGroup / 'NTSelContextualMenu') beRoot
				asMenuPresenter ]
]

{ #category : 'accessing' }
NTSpNoteIndexPresenter >> items [
	"Answer a <Collection> of notes"

	^ componentList items collect: [ :each | each note ]
]

{ #category : 'accessing' }
NTSpNoteIndexPresenter >> items: aCollection [

	"componentList items: aCollection."

	componentList presenters:
		(aCollection collect: [ :each | NTNotePresenter new note: each ])
]

{ #category : 'callbacks' }
NTSpNoteIndexPresenter >> modelChanged [

	self items: owner noteTakerContainer notes
]

{ #category : 'accessing' }
NTSpNoteIndexPresenter >> notesTable [

	^ componentList
]

{ #category : 'accessing' }
NTSpNoteIndexPresenter >> selectNote: aNTNoteObject [

	componentList selectItem:
		(componentList items detect: [ :each | each note = aNTNoteObject ])
]

{ #category : 'accessing' }
NTSpNoteIndexPresenter >> selectedNote [

	^ componentList selectedItem ifNotNil: [ :notePresenter |
		  notePresenter note ]
]

{ #category : 'accessing' }
NTSpNoteIndexPresenter >> selectedNotes [

	^ componentList selectedItems collect: [ :each | each note ]
]

{ #category : 'callbacks' }
NTSpNoteIndexPresenter >> updateRemovedNote [

	self modelChanged.
	self owner
		updateWindowTitle;
		updateContents
]

{ #category : 'callbacks' }
NTSpNoteIndexPresenter >> whenSelectionChangedDo: aBlock [

	componentList whenSelectionChangedDo: aBlock
]
