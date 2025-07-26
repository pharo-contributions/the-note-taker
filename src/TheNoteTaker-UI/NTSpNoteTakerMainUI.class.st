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
	#classVars : [
		'GitEnable'
	],
	#category : 'TheNoteTaker-UI-Core',
	#package : 'TheNoteTaker-UI',
	#tag : 'Core'
}

{ #category : 'commands' }
NTSpNoteTakerMainUI class >> GitEnable [

	^ GitEnable ifNil: [GitEnable := false] 
]

{ #category : 'commands' }
NTSpNoteTakerMainUI class >> GitEnable: aBoolean [

	GitEnable := aBoolean
]

{ #category : 'nil' }
NTSpNoteTakerMainUI class >> buildCommandsGroupWith: presenterInstance forRoot: rootCommandGroup [

	rootCommandGroup register:
		(self buildNTContextualGroupWith: presenterInstance)
]

{ #category : 'commands' }
NTSpNoteTakerMainUI class >> buildNTContextualGroupWith: presenterInstance [

	| commandGroup |
	commandGroup := (CmCommandGroup named: 'Toolbar') asSpecGroup
		                beRoot;
		                register:
			                (NTSpImportFolderCommand forSpec context:
					                 presenterInstance);
		                yourself.
	self GitEnable ifTrue: [
			commandGroup register:
				(NTSpGitCommand forSpec context: presenterInstance) ].
	^ commandGroup
		  register: (NTSpOpenFolderCommand forSpec context: presenterInstance);
		  register: (NTSpLogCommand forSpec context: presenterInstance);
		  register: (NTSpSettingsCommand forSpec context: presenterInstance)
]

{ #category : 'commands' }
NTSpNoteTakerMainUI class >> settingsOn: aBuilder [

	<systemsettings>
	(aBuilder setting: #GitEnable)
		parent: #tnt;
		target: self;
		order: 60;
		label: 'enable git command';
		description: 'When enabled, show git command button.
When disabled, hide git command button. '
]

{ #category : 'initialization' }
NTSpNoteTakerMainUI >> addNote: aNTNoteObject [

	self notesIndexPresenter addNote: aNTNoteObject
]

{ #category : 'accessing' }
NTSpNoteTakerMainUI >> applicationTitle [

	^ self application applicationTitle
]

{ #category : 'initialization' }
NTSpNoteTakerMainUI >> connectPresenters [

	notesIndexPresenter
		transmitTo: notesEditorPresenter
		transform: [ :aNotePresenter |
		aNotePresenter ifNotNil: [ aNotePresenter note ] ]
		postTransmission: [ notesEditorPresenter takeKeyboardFocus ]
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

	notesToolbarPresenter := self newToolbar fillWith:
		                         self rootCommandsGroup / 'Toolbar'.

	notesIndexPresenter := self instantiate: NTSpNoteIndexPresenter.
	notesIndexPresenter model: self noteTakerContainer.
	(NTSpImportFolderCommand new context: notesIndexPresenter)
		executeWithFolder: self application currentFolder.

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
