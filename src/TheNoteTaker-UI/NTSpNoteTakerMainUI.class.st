Class {
	#name : 'NTSpNoteTakerMainUI',
	#superclass : 'SpPresenter',
	#instVars : [
		'notesToolbarPresenter',
		'notesIndexPresenter',
		'notesContentPresenter',
		'statusBar',
		'selectionCount'
	],
	#category : 'TheNoteTaker-UI-Core',
	#package : 'TheNoteTaker-UI',
	#tag : 'Core'
}

{ #category : 'accessing - status bar' }
NTSpNoteTakerMainUI >> decreaseNotesCount [

	selectionCount >= 1 ifFalse: [ ^ self ].
	selectionCount := selectionCount - 1.
	self updateStatusBar.
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
		yourself.
]

{ #category : 'accessing - status bar' }
NTSpNoteTakerMainUI >> increaseNotesCount [
	
	selectionCount := selectionCount + 1.
	self updateStatusBar.
]

{ #category : 'initialization' }
NTSpNoteTakerMainUI >> initialExtentForWindow [

	^ (900 @ 600) scaledByDisplayScaleFactor
]

{ #category : 'initialization' }
NTSpNoteTakerMainUI >> initialTitle [

	^ 'The Note Taker'

]

{ #category : 'initialization' }
NTSpNoteTakerMainUI >> initialize [

	super initialize.
	selectionCount := 0.
	statusBar pushMessage: self statusBarMessage.

]

{ #category : 'initialization' }
NTSpNoteTakerMainUI >> initializeNotesContent [

	notesContentPresenter := self instantiate: NTSpNoteContentPresenter.
]

{ #category : 'initialization' }
NTSpNoteTakerMainUI >> initializeNotesIndex [

	notesIndexPresenter := self instantiate: NTSpNoteIndexPresenter.
]

{ #category : 'initialization' }
NTSpNoteTakerMainUI >> initializeNotesToolbar [
	"This is a search and creator toolbar"
	
	notesToolbarPresenter := self instantiate: NTSpToolbarPresenter.
]

{ #category : 'initialization' }
NTSpNoteTakerMainUI >> initializePresenters [

	self 
		initializeNotesToolbar;
		initializeNotesIndex;
		initializeNotesContent;
		initializeStatusbar
]

{ #category : 'initialization' }
NTSpNoteTakerMainUI >> initializeStatusbar [

	statusBar := SpStatusBarPresenter new
]

{ #category : 'initialization' }
NTSpNoteTakerMainUI >> initializeWindow: aSpWindowPresenter [

	super initializeWindow: aSpWindowPresenter.

	self setTitleTo: aSpWindowPresenter.
	self setWindowIconTo: aSpWindowPresenter.
	self setInitialExtentTo: aSpWindowPresenter
]

{ #category : 'showing' }
NTSpNoteTakerMainUI >> open [ 

	super open;
		centered
]

{ #category : 'accessing - status bar' }
NTSpNoteTakerMainUI >> popMessage [

	statusBar popMessage
]

{ #category : 'accessing' }
NTSpNoteTakerMainUI >> selectedNote [
	"Answer the receiver's selected <NtNoteModel>"
	
	"self shouldBeImplemented"
	^ nil.
]

{ #category : 'initialization' }
NTSpNoteTakerMainUI >> setInitialExtentTo: aSpWindowPresenter [
	
	aSpWindowPresenter initialExtent: self initialExtentForWindow
]

{ #category : 'initialization' }
NTSpNoteTakerMainUI >> setTitleTo: aSpWindowPresenter [

	aSpWindowPresenter title: self initialTitle

]

{ #category : 'initialization' }
NTSpNoteTakerMainUI >> setWindowIconTo: aSpWindowPresenter [

	aSpWindowPresenter	windowIcon: (self iconNamed: #page).
]

{ #category : 'accessing - status bar' }
NTSpNoteTakerMainUI >> statusBarMessage [

	| selectedNoteInfo |
	
	selectedNoteInfo := self selectedNote
		ifNil: [ '' ]
		ifNotNil: [ (self application noteInformation: self selectedNote) size ].
	^ '{1} note' format: { selectedNoteInfo asString }
]

{ #category : 'layout' }
NTSpNoteTakerMainUI >> toolbarHeight [

	^ self class toolbarHeight
]

{ #category : 'accessing - status bar' }
NTSpNoteTakerMainUI >> updateStatusBar [

	statusBar pushMessage: self statusBarMessage.
]
