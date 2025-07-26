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
		'settings',
		'currentFolder',
		'settingPersistence'
	],
	#classVars : [
		'Default',
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
NTSpApplication class >> default [
	^ Default ifNil: [ Default := self new ]
]

{ #category : 'private' }
NTSpApplication class >> default: aNTSpApplication [

	Default := aNTSpApplication
]

{ #category : 'private' }
NTSpApplication class >> isDeployed [
	^ IsDeployed ifNil: [ IsDeployed := false ]
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

	^ currentFolder / 'TNTSettings.config'
]

{ #category : 'accessing' }
NTSpApplication >> currentFolder [

	^ currentFolder
]

{ #category : 'accessing' }
NTSpApplication >> currentFolder: aFileReference [

	currentFolder := aFileReference.
	log logFileReference: aFileReference.
	settingPersistence fileReference: self configFileLocation.
]

{ #category : 'running' }
NTSpApplication >> exportSettings [

	settingPersistence storeSettingNodes: (SettingBrowser currentTree nodeNamed: #tnt) allChildren.
]

{ #category : 'running' }
NTSpApplication >> importSettings [

	settingPersistence updateSettingNodes: (SettingBrowser currentTree nodeNamed: #tnt) allChildren.
	
]

{ #category : 'initialization' }
NTSpApplication >> initialize [

	super initialize.
	noteTakerContainer := NTContainer new.
	settings := NTSettings.
	currentFolder := settings noteLocation.
	settingPersistence := SystemSettingsPersistence new fileReference: self configFileLocation.
	log := NTLog newWithFolder: currentFolder
]

{ #category : 'accessing' }
NTSpApplication >> log [

	^ log
]

{ #category : 'accessing' }
NTSpApplication >> log: aNTLog [

	log := aNTLog
]

{ #category : 'accessing' }
NTSpApplication >> noteTakerContainer [

	^ noteTakerContainer
]

{ #category : 'running' }
NTSpApplication >> reset [

	super reset.
	noteTakerContainer := NTContainer new.
	self start
]

{ #category : 'running' }
NTSpApplication >> settings [

	^ settings
]

{ #category : 'running' }
NTSpApplication >> start [

	self importSettings.
	(NTSpNoteTakerMainUI newApplication: self) open
]

{ #category : 'running' }
NTSpApplication >> startFullScreen [
	" Private - Open the main application window in full screen, intended for the release version "

	(NTSpNoteTakerMainUI newApplication: self) asWorldWindow open
]

{ #category : 'windows' }
NTSpApplication >> windowClosed: aWindowPresenter [
	
	super windowClosed: aWindowPresenter.

	self windows ifEmpty: [ self exportSettings ].
	
	
]
