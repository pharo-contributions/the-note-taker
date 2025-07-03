"
UI class for the note taker application.
This coordinates main events and layout of the main window.

"
Class {
	#name : 'NTSpNoteTakerMainUI',
	#superclass : 'SpPresenter',
	#instVars : [
		'notesToolbarPresenter',
		'notesIndexPresenter',
		'notesContentPresenter',
		'statusBar'
	],
	#category : 'TheNoteTaker-UI-Core',
	#package : 'TheNoteTaker-UI',
	#tag : 'Core'
}

{ #category : 'initialization' }
NTSpNoteTakerMainUI >> applicationTitle [

	^ self application applicationTitle
]

{ #category : 'initialization' }
NTSpNoteTakerMainUI >> connectPresenters [

	notesIndexPresenter notesTable whenSelectedItemChangedDo: [
			:aSelectedNote |
			aSelectedNote
				ifNil: [ notesContentPresenter noNote ]
				ifNotNil: [ notesContentPresenter note: aSelectedNote ] ].

	notesToolbarPresenter notesSearchCreateTextPresenter
		whenTextChangedDo: [
			notesIndexPresenter updateNotesList: notesToolbarPresenter filter ];
		whenSubmitDo: [ :newNoteName |
				| newNote |
				newNote := self application addNoteNamed: newNoteName.
				newNote folderReference: self application settings noteLocation.
				notesToolbarPresenter emptySearchBar.
				notesIndexPresenter notesTable unselectAll.
				notesIndexPresenter selectNote: newNote.
				notesContentPresenter takeKeyboardFocus ].

	notesToolbarPresenter tagsSearchButtonPresenter
		whenActivatedDo: [
		notesIndexPresenter updateNotesList: notesToolbarPresenter filter ]
]

{ #category : 'layout' }
NTSpNoteTakerMainUI >> defaultLayout [

	^ SpBoxLayout newTopToBottom
		add: notesToolbarPresenter height: self toolbarHeight;
		add: (SpPanedLayout newTopToBottom
			positionOfSlider: 35 percent;
			add: notesIndexPresenter;
			add: notesContentPresenter;
			yourself);
		add: statusBar height: self toolbarHeight;
		yourself
]

{ #category : 'testing' }
NTSpNoteTakerMainUI >> hasSelectedNote [

	^ notesIndexPresenter hasSelectedNote 
]

{ #category : 'initialization' }
NTSpNoteTakerMainUI >> initialExtentForWindow [

	^ (900 @ 600) scaledByDisplayScaleFactor
]

{ #category : 'initialization' }
NTSpNoteTakerMainUI >> initialize [

	super initialize.
	statusBar pushMessage: 'note'
]

{ #category : 'initialization' }
NTSpNoteTakerMainUI >> initializePresenters [

	notesToolbarPresenter := self instantiate: NTSpSearchCreatePresenter.
	notesIndexPresenter := self instantiate: NTSpNoteIndexPresenter.
	notesIndexPresenter model: self noteTakerContainer.
	notesContentPresenter := self instantiate: NTSpEditorPresenter.
	statusBar := SpStatusBarPresenter new
]

{ #category : 'initialization' }
NTSpNoteTakerMainUI >> initializeWindow: aSpWindowPresenter [

	super initializeWindow: aSpWindowPresenter.

	self setTitleTo: aSpWindowPresenter.
	aSpWindowPresenter windowIcon: (self iconNamed: #page).
   aSpWindowPresenter initialExtent: self initialExtentForWindow.
]

{ #category : 'accessing' }
NTSpNoteTakerMainUI >> noteTakerContainer [

	^ self application noteTakerContainer
]

{ #category : 'initialization' }
NTSpNoteTakerMainUI >> notesContentPresenter [

	^ notesContentPresenter 
]

{ #category : 'accessing' }
NTSpNoteTakerMainUI >> notesIndexPresenter [

	^ notesIndexPresenter
]

{ #category : 'initialization' }
NTSpNoteTakerMainUI >> notesToolbarPresenter [
	"This is the getter of the notes toolbar"
	
	^ notesToolbarPresenter 
]

{ #category : 'showing' }
NTSpNoteTakerMainUI >> open [ 

	super open.
	self centered
]

{ #category : 'initialization' }
NTSpNoteTakerMainUI >> setTitleTo: aSpWindowPresenter [

	aSpWindowPresenter title: self applicationTitle

]

{ #category : 'accessing' }
NTSpNoteTakerMainUI >> statusBar [

	^ statusBar
]

{ #category : 'layout' }
NTSpNoteTakerMainUI >> toolbarHeight [

	^ self class toolbarHeight
]

{ #category : 'event handling' }
NTSpNoteTakerMainUI >> updateContents [

	notesContentPresenter noNote
]

{ #category : 'activation' }
NTSpNoteTakerMainUI >> updateWindowTitle [

	self withWindowDo: [ : w |
		self hasSelectedNote
			ifFalse: [ self setTitleTo: w ] ]
]
