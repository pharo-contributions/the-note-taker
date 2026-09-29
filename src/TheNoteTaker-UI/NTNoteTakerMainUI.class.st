"
UI class for the note taker application.
This coordinates main events and layout of the main window.

Has the GitEnable settings. If it is enabled, the git button will be available, otherwise it will not be
"
Class {
	#name : 'NTNoteTakerMainUI',
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
NTNoteTakerMainUI class >> buildCommandsGroupWith: presenterInstance forRoot: rootCommandGroup [

	rootCommandGroup register:
		(self buildNTContextualGroupWith: presenterInstance)
]

{ #category : 'commands' }
NTNoteTakerMainUI class >> buildNTContextualGroupWith: presenterInstance [

	| commandGroup |
	commandGroup := (CmCommandGroup named: 'Toolbar') asSpecGroup
		                beRoot;
		                "register: (NTSpImportFolderCommand forSpec context:
					                 presenterInstance notesIndexPresenter);
		                register: (NTSpOpenFolderCommand forSpec context:
					                 presenterInstance notesIndexPresenter);"
		                yourself.
	self gitEnable ifTrue: [
			commandGroup register:
				(NTSpGitCommand forSpec context: presenterInstance) ].
	^ commandGroup
		  register: (NTSpLogCommand forSpec context: presenterInstance);
		  register: (NTSpSettingsCommand forSpec context: presenterInstance)
]

{ #category : 'nil' }
NTNoteTakerMainUI class >> gitEnable [

	^ GitEnable
]

{ #category : 'nil' }
NTNoteTakerMainUI class >> gitEnable: aBoolean [

	GitEnable := aBoolean
]

{ #category : 'accessing' }
NTNoteTakerMainUI >> applicationTitle [

	^ self application applicationTitle
]

{ #category : 'initialization' }
NTNoteTakerMainUI >> connectPresenters [

	notesIndexPresenter
		transmitTo: notesEditorPresenter
		transform: [ :aNotePresenter |
		aNotePresenter ifNotNil: [ aNotePresenter note ] ].

	notesIndexPresenter whenNoteCreatedDo: [
		notesEditorPresenter takeKeyboardFocus ].

	self application log whenWriteDo: [ :string |
		statusBar pushMessage: string ].

	notesEditorPresenter whenNoteSavedDo: [ :note |
			(notesIndexPresenter notes includes: note) ifFalse: [
				notesIndexPresenter addNote: note ].
			self application log save: note ].

	notesEditorPresenter whenNoteChangedDo: [ :note |
			notesIndexPresenter refreshSelectedItem.
			self window ifNotNil: [ :window |
				window title:
					self application applicationTitle , ' - ' , note title ] ]
]

{ #category : 'layout' }
NTNoteTakerMainUI >> defaultLayout [

	^ self noteLayout
]

{ #category : 'accessing' }
NTNoteTakerMainUI >> gitSettings [

	^ self settings gitEnable
]

{ #category : 'testing' }
NTNoteTakerMainUI >> hasSelectedNote [

	^ notesIndexPresenter hasSelectedNote 
]

{ #category : 'initialization' }
NTNoteTakerMainUI >> initialExtentForWindow [

	^ (900 @ 600) scaledByDisplayScaleFactor
]

{ #category : 'initialization' }
NTNoteTakerMainUI >> initialize [

	super initialize.
	statusBar pushMessage: 'note'
]

{ #category : 'initialization' }
NTNoteTakerMainUI >> initializeNoteToolBar [

	notesToolbarPresenter := self newToolbar fillWith:
		                         self rootCommandsGroup / 'Toolbar'.
		
	
	"For now comment out the todo app.
	notesToolbarPresenter add: (SpToolbarButtonPresenter new
			 icon: (self iconNamed: #refreshCircling);
			 label: 'Change to Todo list';
			 action: [ layout := self todoLayout ]) yourself"
]

{ #category : 'initialization' }
NTNoteTakerMainUI >> initializePresenters [

	notesIndexPresenter := self instantiate: NTNoteIndexPresenter.
	notesIndexPresenter model: self noteTakerContainer.
	notesIndexPresenter updatePresenter.

	notesEditorPresenter := self instantiate: NTEditorPresenter.

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
NTNoteTakerMainUI >> initializeWindow: aSpWindowPresenter [

	super initializeWindow: aSpWindowPresenter.

	self setTitleTo: aSpWindowPresenter.
	aSpWindowPresenter windowIcon: (self iconNamed: #page).
   aSpWindowPresenter initialExtent: self initialExtentForWindow.
]

{ #category : 'layout' }
NTNoteTakerMainUI >> noteLayout [

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
NTNoteTakerMainUI >> noteTakerContainer [

	^ self application noteTakerContainer
]

{ #category : 'accessing' }
NTNoteTakerMainUI >> notesEditorPresenter [

	^ notesEditorPresenter
]

{ #category : 'accessing' }
NTNoteTakerMainUI >> notesIndexPresenter [

	^ notesIndexPresenter
]

{ #category : 'accessing' }
NTNoteTakerMainUI >> notesToolbarPresenter [
	"This is the getter of the notes toolbar"
	
	^ notesToolbarPresenter 
]

{ #category : 'showing' }
NTNoteTakerMainUI >> open [ 

	super open.
	self centered
]

{ #category : 'setter' }
NTNoteTakerMainUI >> setTitleTo: aSpWindowPresenter [

	aSpWindowPresenter title: self applicationTitle

]

{ #category : 'accessing' }
NTNoteTakerMainUI >> settings [

	^ self application settings
]

{ #category : 'accessing' }
NTNoteTakerMainUI >> statusBar [

	^ statusBar
]

{ #category : 'layout' }
NTNoteTakerMainUI >> todoLayout [

	^ SpBoxLayout newTopToBottom
		  add: todoToolbarPresenter height: self toolbarHeight;
		  add: taskMainPresener;
		  yourself
]

{ #category : 'accessing' }
NTNoteTakerMainUI >> toolbarHeight [

	^ self class toolbarHeight
]

{ #category : 'activation' }
NTNoteTakerMainUI >> updatePresenter [

	self notesIndexPresenter updatePresenter
]

{ #category : 'activation' }
NTNoteTakerMainUI >> updateWindowTitle [

	self withWindowDo: [ : w |
		self hasSelectedNote
			ifFalse: [ self setTitleTo: w ] ]
]
