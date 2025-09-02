"
This is the main Notes Taker Spec2 application class which:

- Handles the notes container: A class which acts as a repository of notes.
- Provides convenience methods to retrieve notes and its metadata.
- Handles the application initialization: See the `NtSpApplication>>start` method.
- Creates a new entry for this application in the World menu.


"
Class {
	#name : 'NTSpApplication',
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
NTSpApplication class >> applicationTitle [

	^ 'The Note Taker'
]

{ #category : 'private' }
NTSpApplication class >> beDeployed [
	IsDeployed := true
]

{ #category : 'private' }
NTSpApplication class >> beUndeployed [
	IsDeployed := false
]

{ #category : 'private' }
NTSpApplication class >> isDeployed [

	^ IsDeployed ifNil: [ self beUndeployed ]
]

{ #category : 'private' }
NTSpApplication class >> menuNoteTakersOn: aBuilder [
	<worldMenu>

	(aBuilder item: #NoteTaker)
		parent: #Tools;
		label: self applicationTitle;
		icon: (self iconNamed: #catalog);
		action: [ NTSpApplication new run ];
		help: 'The Note Taker';
		order: 630
]

{ #category : 'private' }
NTSpApplication class >> openFull [ 
	<script>
	
	^ self new startFullScreen 
]

{ #category : 'private' }
NTSpApplication class >> openIt [

	<script>
	self new run
]

{ #category : 'private' }
NTSpApplication >> applicationTitle [ 

	^ self class applicationTitle 
]

{ #category : 'running' }
NTSpApplication >> configFileLocation [

	^ self currentFolder / 'TNTSettings.config'
]

{ #category : 'running' }
NTSpApplication >> currentFolder [

	^ settings currentFolder
]

{ #category : 'running' }
NTSpApplication >> currentFolder: aFileReference [

	settings currentFolder: aFileReference
]

{ #category : 'running' }
NTSpApplication >> exportSettings [

	(SettingBrowser currentTree nodeNamed: #tnt) ifNil: [ ^ self ].

	settingPersistence storeSettingNodes:
		(SettingBrowser currentTree nodeNamed: #tnt) allChildren.

	self currentFolder / 'TNTSettings.old.txt' deleteIfAbsent: [ ]
]

{ #category : 'running' }
NTSpApplication >> importSettings [

	self configFileLocation ifAbsent: [ ^ self ].
	(SettingBrowser currentTree nodeNamed: #tnt) ifNotNil: [ :tntNode |
		settingPersistence updateSettingNodes: tntNode allChildren ]
]

{ #category : 'initialization' }
NTSpApplication >> initialize [

	super initialize.
	settings := NTSettings new.
	noteTakerContainer := NTContainer new importFolder:
		                      self currentFolder.
	taskContainer := TaskManager new.
	log := NTLog newWithFolder: self currentFolder.
	settingPersistence := SystemSettingsPersistence new fileReference:
		                      self configFileLocation.
	settings whenCurrentFolderChangeDo: [ :newFolder :oldFolder |
		newFolder = oldFolder ifFalse: [ self updateApplication ] ]
]

{ #category : 'initialization' }
NTSpApplication >> initializeMainPresenter [

	mainPresenter := NTSpNoteTakerMainUI newApplication: self.
]

{ #category : 'accessing' }
NTSpApplication >> log [

	^ log
]

{ #category : 'running' }
NTSpApplication >> mainPresenter [

	^ mainPresenter
]

{ #category : 'running' }
NTSpApplication >> mainPresenter: aNtSpNoteTakerMainUI [

	mainPresenter := aNtSpNoteTakerMainUI
]

{ #category : 'accessing' }
NTSpApplication >> noteTakerContainer [

	^ noteTakerContainer
]

{ #category : 'initialization' }
NTSpApplication >> settings [

	^ settings
]

{ #category : 'running' }
NTSpApplication >> start [

	self initializeMainPresenter.
	mainPresenter open.
	self importSettings
]

{ #category : 'running' }
NTSpApplication >> startFullScreen [
	" Private - Open the main application window in full screen, intended for the release version "

	self initializeMainPresenter.
	mainPresenter asWorldWindow open.
	self importSettings
]

{ #category : 'running' }
NTSpApplication >> taskContainer [

	^ taskContainer
]

{ #category : 'accessing' }
NTSpApplication >> updateApplication [

	log logFileReference: self currentFolder.
	settingPersistence fileReference: self configFileLocation.
	noteTakerContainer replaceFolder: self currentFolder.
	mainPresenter ifNotNil: [ :main | main updatePresenter ].
	self importSettings
]

{ #category : 'windows' }
NTSpApplication >> windowClosed: aWindowPresenter [

	super windowClosed: aWindowPresenter.

	self windows ifEmpty: [self exportSettings]
]
