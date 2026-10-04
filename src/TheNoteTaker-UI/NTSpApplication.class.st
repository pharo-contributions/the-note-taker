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
		'settings',
		'preferenceFile'
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

{ #category : 'accessing' }
NTSpApplication >> currentFolder [

	^ settings currentFolder
]

{ #category : 'accessing' }
NTSpApplication >> currentFolder: aFileReference [

	settings currentFolder: aFileReference
]

{ #category : 'accessing preferences' }
NTSpApplication >> defaultPreferencesFile [

	^ (FileLocator preferences / 'TheNoteTaker' / 'TNTSettings.config') asFileReference
]

{ #category : 'running' }
NTSpApplication >> exportSettings [

	(SettingBrowser currentTree nodeNamed: #tnt_note) 
	   ifNotNil: [ :tntNode | settingPersistence storeSettingNodes: tntNode allChildren ].

]

{ #category : 'running' }
NTSpApplication >> importSettings [

	self preferencesFile exists ifFalse: [ ^ self ].
	(SettingBrowser currentTree nodeNamed: #tnt_note) 
		ifNotNil: [ :tntNode |
			settingPersistence updateSettingNodes: tntNode allChildren ]
]

{ #category : 'running' }
NTSpApplication >> importSettings2 [
	"self new importSettings2"
	
	| reader storedSettings settingDeclarations |
	self preferencesFile exists 
		ifFalse: [ ^ self ].
	reader := SettingsStonReader new stream: self preferencesFile readStream.
	storedSettings := reader load. 
	settingDeclarations := self settings.
	storedSettings do: [ :aStoredSetting |
		| aSetDec |
		aSetDec := settingDeclarations 
			detect: [ :each | (aStoredSetting settingNodeIdentifier splitOn: '#') last = each name ].
		aSetDec realValue: aStoredSetting realValue ].
]

{ #category : 'initialization' }
NTSpApplication >> initialize [

	super initialize.
	settings := NTSettings new.
	"Preference file is either in the preference folder and it does not exist in the app."
	
	settingPersistence := SystemSettingsPersistence new fileReference:  self preferencesFile.
	
	self currentFolder:  settings defaultDocumentFolder.
	noteTakerContainer := NTContainer new. 	                     
	
	taskContainer := TaskManager new.
	log := NTLog newWithFolder: self currentFolder.
	
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

{ #category : 'accessing' }
NTSpApplication >> mainPresenter [

	^ mainPresenter
]

{ #category : 'accessing' }
NTSpApplication >> mainPresenter: aNtSpNoteTakerMainUI [

	mainPresenter := aNtSpNoteTakerMainUI
]

{ #category : 'accessing' }
NTSpApplication >> noteTakerContainer [

	^ noteTakerContainer
]

{ #category : 'accessing preferences' }
NTSpApplication >> preferencesFile [

	^ preferenceFile ifNil: [ preferenceFile := self defaultPreferencesFile asFileReference ]
]

{ #category : 'accessing preferences' }
NTSpApplication >> preferencesFile: aFileReference [

	preferenceFile := aFileReference
]

{ #category : 'accessing preferences' }
NTSpApplication >> settings [

	^ settings
]

{ #category : 'running' }
NTSpApplication >> start [

   "self useBackend: #Toplo."

	self preferencesFile exists
		ifTrue: [ self importSettings2 ]
		ifFalse: [ self exportSettings ].

	self currentFolder ifNil: [ self currentFolder: self preferencesFile ].
	
	noteTakerContainer importFolder: self currentFolder.

	self initializeMainPresenter.
	mainPresenter open.

]

{ #category : 'running' }
NTSpApplication >> startFullScreen [
	" Private - Open the main application window in full screen, intended for the release version "

	self initializeMainPresenter.
	mainPresenter asWorldWindow open.

]

{ #category : 'accessing' }
NTSpApplication >> taskContainer [

	^ taskContainer
]

{ #category : 'update' }
NTSpApplication >> updateApplication [

	log logFileReference: self currentFolder.
	noteTakerContainer replaceFolder: self currentFolder.
	mainPresenter ifNotNil: [ :main | main updatePresenter ].
	
]

{ #category : 'windows' }
NTSpApplication >> windowClosed: aWindowPresenter [

	super windowClosed: aWindowPresenter.
	self exportSettings
]
