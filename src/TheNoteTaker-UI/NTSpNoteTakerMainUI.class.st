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
		'statusBar',
		'taskMainPresener',
		'todoToolbarPresenter'
	],
	#classVars : [
		'GitEnable'
	],
	#category : 'TheNoteTaker-UI-Core',
	#package : 'TheNoteTaker-UI',
	#tag : 'Core'
}

{ #category : 'nil' }
NTSpNoteTakerMainUI class >> GitEnable [

	^ GitEnable
]

{ #category : 'nil' }
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
		                register: (NTSpImportFolderCommand forSpec context:
					                 presenterInstance notesIndexPresenter);
		                register: (NTSpOpenFolderCommand forSpec context:
					                 presenterInstance notesIndexPresenter);
		                yourself.
	self GitEnable ifTrue: [
			commandGroup register:
				(NTSpGitCommand forSpec context: presenterInstance) ].
	^ commandGroup
		  register: (NTSpLogCommand forSpec context: presenterInstance);
		  register: (NTSpSettingsCommand forSpec context: presenterInstance)
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
		aNotePresenter ifNotNil: [ aNotePresenter note ] ].

	self application log whenWriteDo: [ :string |
		statusBar pushMessage: string ].

	notesEditorPresenter whenNoteSavedDo: [ :note |
			(notesIndexPresenter notes includes: note) ifFalse: [
				notesIndexPresenter addNote: note ].
			(self application log save: note) ].

	notesEditorPresenter whenNoteChangedDo: [ :note |
			notesIndexPresenter refreshSelectedItem.
			self window ifNotNil: [ :window |
				window title:
					self application applicationTitle , ' - ' , note title ] ]
]

{ #category : 'layout' }
NTSpNoteTakerMainUI >> defaultLayout [

	^ self noteLayout
]

{ #category : 'layout' }
NTSpNoteTakerMainUI >> gitSettings [

	^ self settings gitEnable
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
NTSpNoteTakerMainUI >> initializeNoteToolBar [

	notesToolbarPresenter := self newToolbar fillWith:
		                         self rootCommandsGroup / 'Toolbar'.
		
	notesToolbarPresenter add: (SpToolbarButtonPresenter new
			 icon: (self iconNamed: #refreshCircling);
			 label: 'Change to Todo list';
			 action: [ layout := self todoLayout ]) yourself
]

{ #category : 'initialization' }
NTSpNoteTakerMainUI >> initializePresenters [

	notesIndexPresenter := self instantiate: NTSpNoteIndexPresenter.
	notesIndexPresenter model: self noteTakerContainer.
	notesIndexPresenter updatePresenter.

	notesEditorPresenter := self instantiate: NTSpEditorPresenter.

	taskMainPresener := self instantiate: SpTaskMainPresenter.
	todoToolbarPresenter := self newToolbar
		                        add: (SpToolbarButtonPresenter new
				                         icon: (self iconNamed: #refreshCircling);
				                         label: 'Change to note';
				                         action: [ layout := self noteLayout ]);
		                        yourself.
	GitEnable := self gitSettings.
	self settings whenGitEnableChangeDo: [ :newValue |
			GitEnable := newValue.
			self initializeNoteToolBar.
			layout := self defaultLayout ].
	self initializeNoteToolBar.
	statusBar := SpStatusBarPresenter new
]

{ #category : 'initialization' }
NTSpNoteTakerMainUI >> initializeWindow: aSpWindowPresenter [

	super initializeWindow: aSpWindowPresenter.

	self setTitleTo: aSpWindowPresenter.
	aSpWindowPresenter windowIcon: (self iconNamed: #page).
   aSpWindowPresenter initialExtent: self initialExtentForWindow.
]

{ #category : 'layout' }
NTSpNoteTakerMainUI >> noteLayout [

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

{ #category : 'layout' }
NTSpNoteTakerMainUI >> settings [

	^ self application settings
]

{ #category : 'accessing' }
NTSpNoteTakerMainUI >> statusBar [

	^ statusBar
]

{ #category : 'layout' }
NTSpNoteTakerMainUI >> todoLayout [

	^ SpBoxLayout newTopToBottom
		  add: todoToolbarPresenter height: self toolbarHeight;
		  add: taskMainPresener;
		  yourself
]

{ #category : 'layout' }
NTSpNoteTakerMainUI >> toolbarHeight [

	^ self class toolbarHeight
]

{ #category : 'layout' }
NTSpNoteTakerMainUI >> updatePresenter [

	self notesIndexPresenter updatePresenter
]

{ #category : 'activation' }
NTSpNoteTakerMainUI >> updateWindowTitle [

	self withWindowDo: [ : w |
		self hasSelectedNote
			ifFalse: [ self setTitleTo: w ] ]
]
