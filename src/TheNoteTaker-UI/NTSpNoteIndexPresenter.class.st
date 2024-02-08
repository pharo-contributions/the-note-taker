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

{ #category : 'callbacks' }
NTSpNoteIndexPresenter >> handleNoteChange: aSelectedNote [

	self shouldBeImplemented
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
			evaluated: #tags;
			yourself);
		addColumn: (SpStringTableColumn new
		   title: 'Date';
			sortFunction: #yourself ascending;		
			evaluated: #creationDate;
			yourself);
		whenSelectionChangedDo: [ : selection | self handleNoteChange: selection selectedItem ];
		contextMenu: [ (self rootCommandsGroup / 'NTSelContextualMenu') beRoot asMenuPresenter ];	
		yourself
]
