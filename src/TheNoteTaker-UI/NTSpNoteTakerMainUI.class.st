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

{ #category : 'accessing - status bar' }
NTSpNoteTakerMainUI >> increaseNotesCount [
	
	selectionCount := selectionCount + 1.
	self updateStatusBar.
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

{ #category : 'accessing - status bar' }
NTSpNoteTakerMainUI >> popMessage [

	statusBar popMessage
]

{ #category : 'accessing' }
NTSpNoteTakerMainUI >> selectedNote [
	"Answer the receiver's selected <NtNoteModel>"
	
	self shouldBeImplemented
]

{ #category : 'accessing - status bar' }
NTSpNoteTakerMainUI >> statusBarMessage [

	| selectedNoteInfo |
	
	selectedNoteInfo := self selectedNote
		ifNil: [ '' ]
		ifNotNil: [ (self application noteInformation: self selectedNote) size ].
	^ '{1} note' format: { selectedNoteInfo asString }
]

{ #category : 'accessing - status bar' }
NTSpNoteTakerMainUI >> updateStatusBar [

	statusBar pushMessage: self statusBarMessage.
]
