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
		'notesEditorPresenter',
		'statusBar'
	],
	#category : 'TheNoteTaker-UI-Core',
	#package : 'TheNoteTaker-UI',
	#tag : 'Core'
}

{ #category : 'accessing' }
NTSpNoteTakerMainUI >> applicationTitle [

	^ self application applicationTitle
]

{ #category : 'initialization' }
NTSpNoteTakerMainUI >> connectPresenters [

	notesIndexPresenter transmitTo: notesEditorPresenter transform: [ :aNotePresenter | aNotePresenter ifNotNil: [ aNotePresenter note ]].

	notesToolbarPresenter searchBarPresenter
		whenTextChangedDo: [
			notesIndexPresenter items: notesToolbarPresenter filter ];
		whenSubmitDo: [ :newNoteName |
				| newNote |
				newNote := self application addNoteNamed: newNoteName.
				newNote folderReference: self application settings noteLocation.
				notesToolbarPresenter emptySearchBar.
				notesIndexPresenter notesTable unselectAll.
				notesIndexPresenter selectNote: newNote.
				notesEditorPresenter takeKeyboardFocus ].

	notesToolbarPresenter tagsSearchButtonPresenter whenActivatedDo: [
		notesIndexPresenter items: notesToolbarPresenter filter ]
]

{ #category : 'layout' }
NTSpNoteTakerMainUI >> defaultLayout [

	^ SpBoxLayout newTopToBottom
		add: notesToolbarPresenter height: self toolbarHeight;
		add: (SpPanedLayout newLeftToRight
			positionOfSlider: 20 percent;
			add: notesIndexPresenter;
			add: notesEditorPresenter;
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

	notesToolbarPresenter := self instantiate: NTSpToolBarPresenter.
	notesToolbarPresenter setModel: self noteTakerContainer.
	
	notesIndexPresenter := self instantiate: NTSpNoteIndexPresenter.
	notesIndexPresenter model: self noteTakerContainer notes.
	(NTSpImportFolderCommand new context: notesIndexPresenter)
		executeWithDefaultFolder.
		
	notesEditorPresenter := self instantiate: NTSpEditorPresenter.
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

{ #category : 'accessing' }
NTSpNoteTakerMainUI >> notesEditorPresenter [

	^ notesEditorPresenter
]

{ #category : 'accessing' }
NTSpNoteTakerMainUI >> notesIndexPresenter [

	^ notesIndexPresenter
]

{ #category : 'accessing' }
NTSpNoteTakerMainUI >> notesToolbarPresenter [
	"This is the getter of the notes toolbar"
	
	^ notesToolbarPresenter 
]

{ #category : 'showing' }
NTSpNoteTakerMainUI >> open [ 

	super open.
	self centered
]

{ #category : 'setter' }
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

	notesEditorPresenter newEmptyNote
]

{ #category : 'activation' }
NTSpNoteTakerMainUI >> updateWindowTitle [

	self withWindowDo: [ : w |
		self hasSelectedNote
			ifFalse: [ self setTitleTo: w ] ]
]
