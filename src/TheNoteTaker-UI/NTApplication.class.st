"
This is the main Notes Taker Spec2 application class which:

- Handles the notes container: A class which acts as a repository of notes.
- Provides convenience methods to retrieve notes and its metadata.
- Handles the application initialization: See the `NtSpApplication>>start` method.
- Creates a new entry for this application in the World menu.


"
Class {
	#name : 'NTApplication',
	#superclass : 'SpApplication',
	#instVars : [
		'noteTakerContainer',
		'log',
		'settingPersistence',
		'mainPresenter',
		'taskContainer',
		'settings'
	],
	#classVars : [
		'IsDeployed'
	],
	#category : 'TheNoteTaker-UI-Core',
	#package : 'TheNoteTaker-UI',
	#tag : 'Core'
}

{ #category : 'private' }
NTApplication class >> applicationTitle [

	^ 'The Note Taker'
]

{ #category : 'private' }
NTApplication class >> beDeployed [
	IsDeployed := true
]

{ #category : 'private' }
NTApplication class >> beUndeployed [
	IsDeployed := false
]

{ #category : 'private' }
NTApplication class >> isDeployed [

	^ IsDeployed ifNil: [ IsDeployed := false ]
]

{ #category : 'private' }
NTApplication class >> menuNoteTakersOn: aBuilder [
	<worldMenu>

	(aBuilder item: #NoteTaker)
		parent: #Tools;
		label: self applicationTitle;
		icon: (self iconNamed: #catalog);
		action: [ NTApplication new run ];
		help: 'The Note Taker';
		order: 630
]

{ #category : 'private' }
NTApplication class >> openFull [ 
	<script>
	
	^ self new startFullScreen 
]

{ #category : 'private' }
NTApplication class >> openIt [

	<script>
	self new run
]

{ #category : 'private' }
NTApplication >> applicationTitle [ 

	^ self class applicationTitle 
]

{ #category : 'accessing' }
NTApplication >> currentFolder [

	^ settings currentFolder
]

{ #category : 'accessing' }
NTApplication >> currentFolder: aFileReference [

	settings currentFolder: aFileReference
]

{ #category : 'running' }
NTApplication >> exportSettings [

	(SettingBrowser currentTree nodeNamed: #tnt_note) 
		ifNotNil: [ :tntNode |
			settingPersistence storeSettingNodes: tntNode allChildren ]

	"self preferencesFileLocation parent / 'TNTSettings.old.txt'
		deleteIfAbsent: [ ]"
]

{ #category : 'running' }
NTApplication >> importSettings [

	self preferencesFileLocation exists ifFalse: [ ^ self ].
	(SettingBrowser currentTree nodeNamed: #tnt_note) 
		ifNotNil: [ :tntNode |
		settingPersistence updateSettingNodes: tntNode allChildren ]
]

{ #category : 'initialization' }
NTApplication >> initialize [

	super initialize.
	settings := NTSettings new.
	"Preference file is either in the preference folder 
	and it does not exist in the app."

	"
	All this logic is arcane
	settingPersistence := SystemSettingsPersistence new fileReference:
		                      self preferencesFileLocation.

	self preferencesFileLocation exists
		ifTrue: [ self importSettings ]
		ifFalse: [ self exportSettings ].
	"
	"let us hardcode something for now."

	"settings currentFolder: (FileSystem disk referenceTo:
			 '/Users/ducasse/Workspace/FirstCircle/Writing/Working/notes')."

	noteTakerContainer := NTContainer new importFolder:
		                      settings currentFolder.

	taskContainer := TaskManager new.
	log := NTLog newWithFolder: settings currentFolder.
	settings whenCurrentFolderChangeDo: [ :newFolder :oldFolder |
		newFolder = oldFolder ifFalse: [ self updateApplication ] ]
]

{ #category : 'initialization' }
NTApplication >> initializeMainPresenter [

	mainPresenter := NTNoteTakerMainUI newApplication: self.
]

{ #category : 'accessing' }
NTApplication >> log [

	^ log
]

{ #category : 'accessing' }
NTApplication >> mainPresenter [

	^ mainPresenter
]

{ #category : 'accessing' }
NTApplication >> mainPresenter: aNtSpNoteTakerMainUI [

	mainPresenter := aNtSpNoteTakerMainUI
]

{ #category : 'accessing' }
NTApplication >> noteTakerContainer [

	^ noteTakerContainer
]

{ #category : 'accessing' }
NTApplication >> preferencesFileLocation [

	^ (FileLocator preferences / 'TheNoteTaker' / 'TNTSettings.config') asFileReference
]

{ #category : 'accessing' }
NTApplication >> settings [

	^ settings
]

{ #category : 'running' }
NTApplication >> start [

   "self useBackend: #Toplo."
	self initializeMainPresenter.
	mainPresenter open.

]

{ #category : 'running' }
NTApplication >> startFullScreen [
	" Private - Open the main application window in full screen, intended for the release version "

	self initializeMainPresenter.
	mainPresenter asWorldWindow open.

]

{ #category : 'accessing' }
NTApplication >> taskContainer [

	^ taskContainer
]

{ #category : 'update' }
NTApplication >> updateApplication [

	log logFileReference: self currentFolder.
	noteTakerContainer replaceFolder: self currentFolder.
	mainPresenter ifNotNil: [ :main | main updatePresenter ].
	
]

{ #category : 'windows' }
NTApplication >> windowClosed: aWindowPresenter [

	super windowClosed: aWindowPresenter.
	Transcript show: 'Should be saving settings... see windowClosed: in NTSpApplication';cr.
	"self windows ifEmpty: [self exportSettings]"
]
