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
		'currentFolder',
		'settingPersistence',
		'mainPresenter'
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
NTSpApplication class >> CurrentFolder [
	"Answer the preferred <String> where notes will be stored"

	^ self default currentFolder
]

{ #category : 'private' }
NTSpApplication class >> CurrentFolder: aString [
	"Set the preferred fileReference where notes will be stored"
	self default currentFolder: aString.
]

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
	self default run
]

{ #category : 'private' }
NTSpApplication class >> settingsOn: aBuilder [

	<systemsettings>
	(aBuilder group: #tnt)
		label: 'The Note Taker';
		description: 'All TNT related settings';
		noOrdering;
		with: [
				(aBuilder setting: #CurrentFolder)
					label: 'Project Path';
					type: #Directory;
					ghostHelp:
						'/Users/ducasse/Workspace/FirstCircle/Writing/Working/researchnotes';
					description:
						'Enter your local or remote path where notes will be committed. It can be empty']
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

	^ currentFolder ifNil: [
			  (FileLocator documents / 'noteTaker') asFileReference
				  ensureCreateDirectory ]
]

{ #category : 'accessing' }
NTSpApplication >> currentFolder: aFileReference [

	currentFolder = aFileReference ifTrue: [ ^ self ].

	currentFolder := aFileReference.
	log logFileReference: currentFolder.
	settingPersistence fileReference: self configFileLocation.
	noteTakerContainer replaceFolder: currentFolder.
	mainPresenter ifNotNil: [ mainPresenter updatePresenter].
	self importSettings.
	
]

{ #category : 'running' }
NTSpApplication >> exportSettings [
	"self class environment
		at: #NTSettings
		ifPresent: [ :class |
				class class
					compiledMethodAt: #settingsOn:
					ifPresent: [ :meth | (meth pragmas collect: #keyword) traceCr ]
					ifAbsent: [ self error: 'Missing method' ] ]
		ifAbsent: [ self error: 'Missing class' ].
	SettingBrowser settingsKeywords traceCr."

	(SettingBrowser currentTree nodeNamed: #tnt) ifNil: [ ^ self ].

	settingPersistence storeSettingNodes:
		(SettingBrowser currentTree nodeNamed: #tnt) allChildren.
	
	(currentFolder / 'TNTSettings.old.txt') deleteIfAbsent: [  ]
]

{ #category : 'running' }
NTSpApplication >> importSettings [

	(SettingBrowser currentTree nodeNamed: #tnt) ifNil: [ ^ self ].
	
	settingPersistence updateSettingNodes:
		(SettingBrowser currentTree nodeNamed: #tnt) allChildren
]

{ #category : 'initialization' }
NTSpApplication >> initialize [

	super initialize.
	noteTakerContainer := NTContainer new.
	log := NTLog new.
	settingPersistence := SystemSettingsPersistence new.
	
	self currentFolder: self currentFolder.
	mainPresenter := (NTSpNoteTakerMainUI newApplication: self)
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

{ #category : 'running' }
NTSpApplication >> start [

	mainPresenter open
]

{ #category : 'running' }
NTSpApplication >> startFullScreen [
	" Private - Open the main application window in full screen, intended for the release version "

	mainPresenter asWorldWindow open
]

{ #category : 'windows' }
NTSpApplication >> windowClosed: aWindowPresenter [

	super windowClosed: aWindowPresenter.

	self windows ifEmpty: [self exportSettings]
]
