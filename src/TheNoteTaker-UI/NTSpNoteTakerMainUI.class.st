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
			aSelectedNote ifNil: [ self editorPresenter noNote ] ifNotNil: [
					self displayNoteContents: aSelectedNote.
					aSelectedNote exists
						ifTrue: [ aSelectedNote openFromPresenter: self ]
						ifFalse: [ aSelectedNote newFromPresenter: self ] ] ].

	notesToolbarPresenter notesSearchCreateTextPresenter
		whenTextChangedDo: [
				notesIndexPresenter updateNotesList:
						(notesToolbarPresenter filterNotes:
								 self noteTakerContainer notes) ];
		whenSubmitDo: [ :newNoteName |
				notesIndexPresenter updateNotesList: self noteTakerContainer notes.
				notesIndexPresenter selectNote:
						(self application addNoteNamed: newNoteName).
				self editorPresenter takeKeyboardFocus.
				notesToolbarPresenter emptySearchBar ].

	notesToolbarPresenter tagsSearchCreateTextPresenter
		whenTextChangedDo: [
				notesIndexPresenter updateNotesList:
					(notesToolbarPresenter filterNotes: self noteTakerContainer notes) ]
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

{ #category : 'accessing - status bar' }
NTSpNoteTakerMainUI >> displayNoteContents: aNoteObject [

	notesContentPresenter displayContents: aNoteObject
]

{ #category : 'accessing' }
NTSpNoteTakerMainUI >> editorPresenter [
	"Answer the receiver's MicroDown editor presenter"

	^ notesContentPresenter

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
	statusBar pushMessage: self statusBarMessage.

]

{ #category : 'initialization' }
NTSpNoteTakerMainUI >> initializeNotesContent [
	
	notesContentPresenter := (self instantiate: NTSpEditorPresenter on: self).
	notesContentPresenter 
		layout: notesContentPresenter defaultLayout;
		emptyInputText;
		emptyRenderedText
]

{ #category : 'initialization' }
NTSpNoteTakerMainUI >> initializeNotesIndex [

	notesIndexPresenter := self instantiate: NTSpNoteIndexPresenter on: self application notes.
]

{ #category : 'initialization' }
NTSpNoteTakerMainUI >> initializeNotesToolbar [
	"This is a search and creator toolbar"

	notesToolbarPresenter := self instantiate: NTSpSearchCreatePresenter on: self model
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

{ #category : 'initialization' }
NTSpNoteTakerMainUI >> model [
	"Answer the receiver's <NTNoteFacade>"
	^ self application noteTakerContainer
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
NTSpNoteTakerMainUI >> notesToolbar [

	^ notesToolbarPresenter
]

{ #category : 'initialization' }
NTSpNoteTakerMainUI >> notesToolbarPresenter [
	"This is the getter of the notes toolbar"
	
	^ notesToolbarPresenter 
]

{ #category : 'accessing' }
NTSpNoteTakerMainUI >> nullNote [

	self updateWindowTitle.
	^ NTNullNoteObject new
]

{ #category : 'showing' }
NTSpNoteTakerMainUI >> open [ 

	super open.
	self centered
]

{ #category : 'accessing' }
NTSpNoteTakerMainUI >> processSelectedNote: aCollection [ 
	"If we have more than one selection we just display an empty note in the contents presenter"

	aCollection size > 1
		ifTrue: [ ^ self nullNote ].
	^ aCollection anyOne

]

{ #category : 'accessing' }
NTSpNoteTakerMainUI >> selectedNote [
	"Answer the receiver's selected <NtNoteModel>"

	^ self notesIndexPresenter selectedNote
]

{ #category : 'accessing' }
NTSpNoteTakerMainUI >> selectedNoteTitle [
	"Answer the receiver's selected <NtNoteObject> title"
	^ self notesIndexPresenter selectedNoteTitle
	
]

{ #category : 'initialization' }
NTSpNoteTakerMainUI >> setInitialExtentTo: aSpWindowPresenter [
	
	aSpWindowPresenter initialExtent: self initialExtentForWindow
]

{ #category : 'initialization' }
NTSpNoteTakerMainUI >> setTitleTo: aSpWindowPresenter [

	aSpWindowPresenter title: self applicationTitle

]

{ #category : 'initialization' }
NTSpNoteTakerMainUI >> setWindowIconTo: aSpWindowPresenter [

	aSpWindowPresenter	windowIcon: (self iconNamed: #page).
]

{ #category : 'accessing' }
NTSpNoteTakerMainUI >> statusBar [

	^ statusBar
]

{ #category : 'accessing - status bar' }
NTSpNoteTakerMainUI >> statusBarMessage [

	| selectedNoteInfo |
	selectedNoteInfo := self selectedNote
		                    ifNil: [ '' ]
		                    ifNotNil: [
		                    (self application noteInformation:
			                     self selectedNote) size ].
	^ '{1} note' format: { selectedNoteInfo asString }
]

{ #category : 'layout' }
NTSpNoteTakerMainUI >> toolbarHeight [

	^ self class toolbarHeight
]

{ #category : 'event handling' }
NTSpNoteTakerMainUI >> updateContents [

	notesContentPresenter setModel: self nullNote
]

{ #category : 'activation' }
NTSpNoteTakerMainUI >> updateWindowTitle [

	self withWindowDo: [ : w |
		self hasSelectedNote
			ifFalse: [ self setTitleTo: w ] ]
]
