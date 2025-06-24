"
Presents a table with basic metadata information about saved notes in the system.

"
Class {
	#name : 'NTSpNoteIndexPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'notesTable',
		'notes'
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
		  register: ((NTSpAddNoteCommand
				    forSpecWithIconNamed: #add
				    shortcutKey: 'A' asShortcut) context: presenterInstance);
		  register: ((NTSpImportNoteCommand
				    forSpecWithIconNamed: #into
				    shortcutKey: 'I' asShortcut) context: presenterInstance);
		  register: ((NTSpImportFolderCommand
				    forSpecWithIconNamed: #into
				    shortcutKey: 'F' asShortcut) context: presenterInstance);
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
		add: notesTable;
		yourself.
]

{ #category : 'layout' }
NTSpNoteIndexPresenter >> defaultOutputPort [
	"self flags."

	"method never use"

	^ notesTable defaultOutputPort
]

{ #category : 'private' }
NTSpNoteIndexPresenter >> displayNoteTags: selectedNote [
	"Answer a <String> to be displayed"

	selectedNote tags ifEmpty: [ ^ '' ].
	^ (selectedNote tags collect: [ :each | each tagName ]) asArray joinUsing: ','
]

{ #category : 'accessing' }
NTSpNoteIndexPresenter >> editorPresenter [
	"Answer the receiver's <NTMDEditorPresenter>"

	^ self owner editorPresenter
]

{ #category : 'testing' }
NTSpNoteIndexPresenter >> hasSelectedNote [

	^ notesTable listSize ~= 0
]

{ #category : 'initialization' }
NTSpNoteIndexPresenter >> initializePresenters [

	notesTable := self newTable
		              beMultipleSelection;
		              addColumn: (SpStringTableColumn new
				               title: 'Title';
				               compareFunction: [ :e :f | e title > f title ];
				               evaluated: #title;
				               yourself);
		              addColumn: (SpStringTableColumn new
				               title: 'Tags';
				               "sortFunction: #yourself ascending;"evaluated: [
					               :selectedNote |
					               self displayNoteTags: selectedNote ];
				               yourself);
		              addColumn: (SpStringTableColumn new
				               title: 'Date';
				               width: 200 * self currentWorld displayScaleFactor;
				               "sortFunction: #yourself ascending;"evaluated: [
					               :selectedNote |
					               ZnUtils httpDate: selectedNote creationDate ];
				               yourself);
		              contextMenu: [
				              (self rootCommandsGroup / 'NTSelContextualMenu')
					              beRoot asMenuPresenter ];
		              items: notes.

	(NTSpImportFolderCommand new context: self) executeWithDefaultFolder
]

{ #category : 'accessing' }
NTSpNoteIndexPresenter >> items [
	"Answer a <Collection> of notes"

	^ notesTable items
]

{ #category : 'accessing' }
NTSpNoteIndexPresenter >> items: aCollection [ 

	notesTable items: aCollection
]

{ #category : 'accessing' }
NTSpNoteIndexPresenter >> notesTable [

	^ notesTable
]

{ #category : 'accessing' }
NTSpNoteIndexPresenter >> refresh [
	"Update the receievr's notes presenter"

	notesTable refresh.
]

{ #category : 'accessing' }
NTSpNoteIndexPresenter >> selectNote: aNTNoteObject [

	notesTable selectItem: aNTNoteObject
]

{ #category : 'accessing' }
NTSpNoteIndexPresenter >> selectedNote [

	^ notesTable selectedItem
]

{ #category : 'accessing' }
NTSpNoteIndexPresenter >> selectedNoteTitle [
	"Answer a <String> representing the title of the currently selected note"
	
	^ self selectedNote 
		ifNotNil: [ : n | n title ]
		ifNil: [ String empty ]
]

{ #category : 'accessing' }
NTSpNoteIndexPresenter >> selectedNotes [

	^ notesTable selectedItems
]

{ #category : 'accessing - model' }
NTSpNoteIndexPresenter >> setModelBeforeInitialization: aCollection [

	notes := aCollection.
]

{ #category : 'callbacks' }
NTSpNoteIndexPresenter >> updateRemovedNote [

	self refresh.
	notesTable selectionMode unselectAll.
	self owner
		updateWindowTitle;
		updateContents.
]
