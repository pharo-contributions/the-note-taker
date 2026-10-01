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
		'CurrentFolder',
		'GitEnable',
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

{ #category : 'settings' }
NTApplication class >> currentFolder [

	^ CurrentFolder ifNil: [
			  CurrentFolder := (FileLocator documents / 'noteTaker')
				                   asFileReference ensureCreateDirectory ]
]

{ #category : 'settings' }
NTApplication class >> currentFolder: aFolder [

	CurrentFolder := aFolder 
]

{ #category : 'settings' }
NTApplication class >> gitEnable [

	^ GitEnable
]

{ #category : 'settings' }
NTApplication class >> gitEnable: aBoolean [

	GitEnable := aBoolean
]

{ #category : 'private' }
NTApplication class >> isDeployed [

	^ IsDeployed ifNil: [ IsDeployed := false ]
]

{ #category : 'settings - io' }
NTApplication class >> load [

	| storedSettings |
	storedSettings := (SystemSettingsPersistence new fileReference:
		                   self preferencesFileLocation)
		                  settingsNodesFromIdentifiers:
		                  #( 'GitEnable' 'CurrentFolder' )
]

{ #category : 'settings - io' }
NTApplication class >> loadSettings [

	| reader storedSettings settingDeclarations |
	reader := SettingsStonReader new stream:
		          self preferencesFileLocation readStream.
	storedSettings := reader load.
	settingDeclarations := self settings.
	storedSettings do: [ :aStoredSetting |
			| aSetDec |
			aSetDec := settingDeclarations detect: [ :each |
				           (aStoredSetting settingNodeIdentifier splitOn: '#')
					           last = each name ].
			aSetDec realValue: aStoredSetting realValue ]
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

{ #category : 'settings - io' }
NTApplication class >> notetakersettings [
	"<settingPragmaProcessor>"

	
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

{ #category : 'settings - io' }
NTApplication class >> settings [
	"self settings"

	| builder |
	builder := SettingTreeBuilder new.
	(Pragma allNamed: #systemsettings in: self class) collect: [ :each |
		builder buildPragma: each ].
	^ builder nodeList collect: [ :each | each item ]
]

{ #category : 'settings - io' }
NTApplication class >> settingsNodes [
	"Argh we have to get a tree to be able to load and save setting...."

	"self settingsNodes"

	| builder |
	builder := SettingTreeBuilder new.
	(Pragma allNamed: #systemsettings in: self class) collect: [ :each |
		builder buildPragma: each ].
	^ builder nodeList
]

{ #category : 'settings - io' }
NTApplication class >> settingsOn: aBuilder [
	"<notetakersettings>"

	<systemsettings>
	(aBuilder group: #tnt)
		label: 'The Note Taker';
		description: 'All TNT related settings';
		noOrdering;
		with: [
				(aBuilder group: #tntNote)
					label: 'Note section parameter';
					with: [
							(aBuilder setting: #gitEnable)
								parent: #tntNote;
								target: self;
								order: 60;
								label: 'enable git command';
								description: 'When enabled, show git command button.
When disabled, hide git command button. '.
							(aBuilder setting: #currentFolder)
								label: 'Project Path';
								target: self;
								type: #Directory;
								ghostHelp:
									'/Users/ducasse/Workspace/FirstCircle/Writing/Working/researchnotes';
								description:
									'Enter your local or remote path where notes will be committed. It can be empty' ] ]
]

{ #category : 'settings - io' }
NTApplication class >> settingsTree [
	"Argh we have to get a tree to be able to load and save setting...."

	"self settingsTree"

	| builder |
	builder := SettingTreeBuilder new.
	(Pragma allNamed: #systemsettings in: self class) collect: [ :each |
		builder buildPragma: each ].
	(SettingTree acceptableKeywords: #( #notetakersettings ))
		settingTreeRoots.

	^ builder inspect
]

{ #category : 'settings - io' }
NTApplication class >> storeSetting [

	| writer |
	writer := SettingsStonWriter new.
	writer stream: self preferencesFileLocation writeStream.
	writer addSettings:
		(StoredSettingsFactory new fromSettingNodes: self settingsNodes).
	writer store.
	writer stream flush
]

{ #category : 'private' }
NTApplication >> applicationTitle [ 

	^ self class applicationTitle 
]

{ #category : 'accessing' }
NTApplication >> currentFolder [
	"we use the class and not directly the sharedVariable because there is a lazy initialize
	for the default location."

	^ self class currentFolder
]

{ #category : 'accessing' }
NTApplication >> currentFolder: aFileReference [

	CurrentFolder := aFileReference
]

{ #category : 'old' }
NTApplication >> exportSettings [

	(SettingBrowser currentTree nodeNamed: #tnt_note) 
		ifNotNil: [ :tntNode |
			settingPersistence storeSettingNodes: tntNode allChildren ]

	"self preferencesFileLocation parent / 'TNTSettings.old.txt'
		deleteIfAbsent: [ ]"
]

{ #category : 'running' }
NTApplication >> exportSettings2 [

	"(SettingBrowser currentTree nodeNamed: #tnt_note) ifNotNil: [
		:tntNode | self preferencesFileLocation parent / 'TNTSettings.old.txt'
		deleteIfAbsent: [ ]
		settingPersistence storeSettingNodes: tntNode allChildren ]"
	
	(FileLocator preferences / 'TheNoteTaker' / 'TNTPreferences.ston') asFileReference writeStreamDo: 
		[ :str | 
			| dict |
			dict := Dictionary new. 
			dict at: #currentFolder put: CurrentFolder fullName. 
			STON put: dict onStreamPretty: str 
			]
		
]

{ #category : 'accessing' }
NTApplication >> gitEnable [

	^ GitEnable ifNil: [ GitEnable := false ]
]

{ #category : 'accessing' }
NTApplication >> gitEnable: aBoolean [

	GitEnable := aBoolean
]

{ #category : 'old' }
NTApplication >> importSettings [

	self preferencesFileLocation exists ifFalse: [ ^ self ].
	(SettingBrowser currentTree nodeNamed: #tnt_note) ifNotNil: [
		:tntNode |
		settingPersistence updateSettingNodes: tntNode allChildren ]
]

{ #category : 'running' }
NTApplication >> importSettings2 [

	self preferencesFileLocation exists ifFalse: [ ^ self ].
	(FileLocator preferences / 'TheNoteTaker' / 'TNTPreferences.ston')
		asFileReference readStreamDo: [ :str |
			[
				| dict |
				dict := STON fromStream: str.
				CurrentFolder := (dict at: #currentFolder) asFileReference ]
				on: Error
				do: [ :e | "should have a better way to communicate error"
						Transcript
							show: 'Corrupted Preferences file.';
							cr ] ]
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

	self importSettings2.
	noteTakerContainer := NTContainer new importFolder:
		                      self currentFolder.

	taskContainer := TaskManager new.
	log := NTLog newWithFolder: self currentFolder.
	self initializeMainPresenter.
	mainPresenter open
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
