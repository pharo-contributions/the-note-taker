"
Presents a table with basic metadata information about saved notes in the system.

"
Class {
	#name : 'NTSpNoteIndexPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'notesIndexPresenter',
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
			forSpecWithIconNamed: #glamorousAdd
			shortcutKey: 'A' asShortcut) 
				context: presenterInstance);
				
			register: ((NTSpImportNoteCommand
			forSpecWithIconNamed: #glamorousInto
			shortcutKey: 'I' asShortcut) 
				context: presenterInstance);
				
			register: ((NTSpRemoveNoteCommand
			forSpecWithIconNamed: #delete
			shortcutKey: 'D' asShortcut) 
				context: presenterInstance);
								
		beDisplayedAsGroup;
		yourself
]

{ #category : 'layout' }
NTSpNoteIndexPresenter >> defaultLayout [

	^ SpBoxLayout newTopToBottom 
		add: notesIndexPresenter;
		yourself.
]

{ #category : 'layout' }
NTSpNoteIndexPresenter >> defaultOutputPort [ 
	
	^ notesIndexPresenter defaultOutputPort
]

{ #category : 'private' }
NTSpNoteIndexPresenter >> displayNoteTags: selectedNote [
	"Answer a <String> to be displayed"
	
	^ selectedNote tags 
		ifEmpty: [ '' ] 
		ifNotEmpty: [ : tags | tags join: ',' ]
]

{ #category : 'callbacks' }
NTSpNoteIndexPresenter >> handleNoteChange: aSelectedNote [

	aSelectedNote
		ifNotNil: [ 	 ]
]

{ #category : 'testing' }
NTSpNoteIndexPresenter >> hasSelectedNote [
	"Answer <true> if the receiver has a selected note"

	^ notesIndexPresenter listSize ~= 0 and: [ self selectedNote isNote ]
]

{ #category : 'initialization' }
NTSpNoteIndexPresenter >> initializePresenters [

	notesIndexPresenter := self newTable
		beMultipleSelection;
		addColumn: (SpStringTableColumn new
			title: 'Title';
			sortFunction: #yourself ascending;
			evaluated: #title;
			yourself);
		addColumn: (SpStringTableColumn new
			title: 'Tags';
			"sortFunction: #yourself ascending;"
			evaluated: [ : selectedNote | self displayNoteTags: selectedNote ];
			yourself);
		addColumn: (SpStringTableColumn new
		   title: 'Date';
			width: 200 * self currentWorld displayScaleFactor;
			"sortFunction: #yourself ascending;"
			evaluated: [ : selectedNote | ZnUtils httpDate: selectedNote creationDate ] ;
			yourself);
		whenSelectionChangedDo: [ : selection | self handleNoteChange: selection selectedItem ];
		contextMenu: [ (self rootCommandsGroup / 'NTSelContextualMenu') beRoot asMenuPresenter ];
		items: notes;
		yourself
]

{ #category : 'accessing' }
NTSpNoteIndexPresenter >> items [
	"Answer a <Collection> of notes"

	^ notesIndexPresenter items
]

{ #category : 'accessing' }
NTSpNoteIndexPresenter >> items: aCollection [ 

	notesIndexPresenter items: aCollection
]

{ #category : 'accessing' }
NTSpNoteIndexPresenter >> refresh [
	"Update the receievr's notes presenter"

	notesIndexPresenter refresh.
]

{ #category : 'accessing' }
NTSpNoteIndexPresenter >> selectNote: aNTNoteObject [
	"Select aNTNoteObject in the receiver"
	
	notesIndexPresenter selectItem: aNTNoteObject
]

{ #category : 'accessing' }
NTSpNoteIndexPresenter >> selectedNote [
	"Answer the receiver's selected <NtNoteModel>"

	^ notesIndexPresenter selectedItem
]

{ #category : 'accessing' }
NTSpNoteIndexPresenter >> selectedNoteTitle [
	"Answer a <String> representing the title of the currently selected note"

	^ self selectedNote title.
]

{ #category : 'accessing' }
NTSpNoteIndexPresenter >> selectedNotes [
	"Answer the <Collection> of <NTNoteObject> which are currently selected"

	^ notesIndexPresenter selectedItems
]

{ #category : 'accessing - model' }
NTSpNoteIndexPresenter >> setModelBeforeInitialization: aCollection [

	notes := aCollection
]

{ #category : 'as yet unclassified' }
NTSpNoteIndexPresenter >> updateRemovedNote [

	self refresh.
	self owner updateWindowTitle.
]
