"
Presents a table with basic metadata information about saved notes in the system.

"
Class {
	#name : 'NTSpNoteIndexPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'notesIndexPresenter'
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

"	aSelectedNote
		ifNotNil: [ 	self shouldBeImplemented ]" 
]

{ #category : 'initialization' }
NTSpNoteIndexPresenter >> initializePresenters [

	notesIndexPresenter := self newTable
		addColumn: (SpStringTableColumn new
			title: 'Title';
			sortFunction: #yourself ascending;			
			evaluated: #title;
			yourself);
		addColumn: (SpStringTableColumn new
			title: 'Tags';
			sortFunction: #yourself ascending;
			evaluated: [ : selectedNote | self displayNoteTags: selectedNote ];
			yourself);
		addColumn: (SpStringTableColumn new
		   title: 'Date';
			width: 200 * self currentWorld displayScaleFactor;
			sortFunction: #yourself ascending;		
			evaluated: [ : selectedNote | ZnUtils httpDate: selectedNote creationDate ] ;
			yourself);
		whenSelectionChangedDo: [ : selection | self handleNoteChange: selection selectedItem ];
		contextMenu: [ (self rootCommandsGroup / 'NTSelContextualMenu') beRoot asMenuPresenter ];	
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
