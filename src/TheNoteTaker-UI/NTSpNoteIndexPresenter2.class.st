"
Presents a table with basic metadata information about saved notes in the system.

"
Class {
	#name : 'NTSpNoteIndexPresenter2',
	#superclass : 'SpPresenterWithModel',
	#instVars : [
		'notesTable'
	],
	#category : 'TheNoteTaker-UI-Core',
	#package : 'TheNoteTaker-UI',
	#tag : 'Core'
}

{ #category : 'accessing' }
NTSpNoteIndexPresenter2 class >> buildCommandsGroupWith: presenterInstance forRoot: rootCommandGroup [

	rootCommandGroup
		register: (self buildNTContextualGroupWith: presenterInstance)
]

{ #category : 'accessing' }
NTSpNoteIndexPresenter2 class >> buildNTContextualGroupWith: presenterInstance [

	^ (CmCommandGroup named: 'NTSelContextualMenu') asSpecGroup
		register: (self buildNoteTakerOperationsGroupWith: presenterInstance);		
		yourself
]

{ #category : 'accessing' }
NTSpNoteIndexPresenter2 class >> buildNoteTakerOperationsGroupWith: presenterInstance [

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

{ #category : 'initialization' }
NTSpNoteIndexPresenter2 >> dateFormatter: aDateAndTime [
	"Answers a string formatting object as time stamp for HTTP1.1 (RFC 1123).
	Eg. Sun, 06 Nov 1994 08:49:37 GMT"

	| utc |
	utc := aDateAndTime asDateAndTime asUTC.
	^ String streamContents: [ :stream |
			  stream
				  nextPutAll: utc dayOfWeekAbbreviation;
				  nextPut: $,;
				  space.
			  stream nextPutAll:
				  (utc dayOfMonth printStringLength: 2 padded: true).
			  stream
				  space;
				  nextPutAll: utc monthAbbreviation;
				  space.
			  utc year printOn: stream.
			  stream space.
			  utc printHMSOn: stream.
			  stream nextPutAll: ' GMT' ]
]

{ #category : 'layout' }
NTSpNoteIndexPresenter2 >> defaultLayout [

	^ SpBoxLayout newTopToBottom 
		add: notesTable;
		yourself.
]

{ #category : 'layout' }
NTSpNoteIndexPresenter2 >> defaultOutputPort [

	^ SpDropListSelectionPort newPresenter: self
]

{ #category : 'private' }
NTSpNoteIndexPresenter2 >> displayNoteTags: selectedNote [
	"Answer a <String> to be displayed"

	| orderedTags |
	selectedNote tags ifEmpty: [ ^ '' ].
	
	orderedTags := selectedNote tags asOrderedCollection sorted: [:a :b | a tagName < b tagName].
	^ (orderedTags collect: [ :each | each tagName ]) asArray joinUsing: ','
]

{ #category : 'testing' }
NTSpNoteIndexPresenter2 >> hasSelectedNote [

	^ notesTable listSize ~= 0
]

{ #category : 'initialization' }
NTSpNoteIndexPresenter2 >> initializePresenters [

	notesTable := self instantiate: SpComponentListPresenter.

	notesTable contextMenu: [
			(self rootCommandsGroup / 'NTSelContextualMenu') beRoot
				asMenuPresenter ]
]

{ #category : 'accessing' }
NTSpNoteIndexPresenter2 >> items [
	"Answer a <Collection> of notes"

	^ notesTable items
]

{ #category : 'accessing' }
NTSpNoteIndexPresenter2 >> items: aCollection [ 

	notesTable items: aCollection.
	
	notesTable presenters: (aCollection collect: [ :each | NTNotePresenter new model: each])
]

{ #category : 'callbacks' }
NTSpNoteIndexPresenter2 >> modelChanged [

	notesTable refresh
]

{ #category : 'accessing' }
NTSpNoteIndexPresenter2 >> notesTable [

	^ notesTable
]

{ #category : 'accessing' }
NTSpNoteIndexPresenter2 >> selectNote: aNTNoteObject [

	notesTable selectItem: aNTNoteObject
]

{ #category : 'accessing' }
NTSpNoteIndexPresenter2 >> selectedNote [

	^ notesTable selectedItem
]

{ #category : 'accessing' }
NTSpNoteIndexPresenter2 >> selectedNotes [

	^ notesTable selectedItems
]

{ #category : 'callbacks' }
NTSpNoteIndexPresenter2 >> updateRemovedNote [

	self modelChanged.
	self owner
		updateWindowTitle;
		updateContents
]

{ #category : 'callbacks' }
NTSpNoteIndexPresenter2 >> whenSelectionChangedDo: aBlock [

	notesTable whenSelectionChangedDo: aBlock
]
