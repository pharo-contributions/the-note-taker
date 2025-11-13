"
I declare and hold settings used by the application.

I have event for execute an action when one of the settings changes.

For now, I have event for:

- currentFolder, with `whenCurrentFolderChangeDo:`
- gitEnable, with `whenGitEnableChangeDo:`
"
Class {
	#name : 'NTSettings',
	#superclass : 'Object',
	#traits : 'TObservable',
	#classTraits : 'TObservable classTrait',
	#instVars : [
		'#currentFolder => ObservableSlot',
		'#gitEnable => ObservableSlot'
	],
	#classVars : [
		'#Default'
	],
	#category : 'TheNoteTaker-Core',
	#package : 'TheNoteTaker',
	#tag : 'Core'
}

{ #category : 'private' }
NTSettings class >> CurrentFolder [

	^ self Default currentFolder
]

{ #category : 'private' }
NTSettings class >> CurrentFolder: aFileReference [

	self Default currentFolder: aFileReference
]

{ #category : 'private' }
NTSettings class >> Default [

	^ Default ifNil: [ Default := self new ]
]

{ #category : 'private' }
NTSettings class >> Default: aNTSettings [

	Default := aNTSettings
]

{ #category : 'commands' }
NTSettings class >> GitEnable [

	^ self Default gitEnable
]

{ #category : 'commands' }
NTSettings class >> GitEnable: aBoolean [

	self Default gitEnable: aBoolean
]

{ #category : 'settings xp' }
NTSettings class >> load [ 
	"self load"
	
	| storedSettings |
	"I over pass all the machenery of Persistence for now because I need to understand it better"
	
	storedSettings := (SystemSettingsPersistence new fileReference: self preferencesFileLocation) allStoredSettings collect: [ :each | (each settingNodeIdentifier splitOn: '#') last ].
	
	storedSettings := (SystemSettingsPersistence new fileReference: self preferencesFileLocation).
]

{ #category : 'setting io' }
NTSettings class >> loadSettings [

	| reader storedSettings settingDeclarations |
	reader := SettingsStonReader new stream: self preferencesFileLocation readStream.
	storedSettings := reader load. 
	settingDeclarations := self settings.
	storedSettings do: [ :aStoredSetting |
		| aSetDec |
		aSetDec := settingDeclarations 
			detect: [ :each | (aStoredSetting settingNodeIdentifier splitOn: '#') last = each name ].
		aSetDec realValue: aStoredSetting realValue ].
]

{ #category : 'commands' }
NTSettings class >> new [

	| instance |
	instance := super new.
	Default := instance.
	^ instance
]

{ #category : 'settings' }
NTSettings class >> notetakersettings [
	"<settingPragmaProcessor>"
]

{ #category : 'settings' }
NTSettings class >> preferencesFileLocation [

	^ (FileLocator preferences / 'TheNoteTaker' / 'TNTSettings.config') asFileReference
]

{ #category : 'settings' }
NTSettings class >> reset [

	<script>
	Default := nil
]

{ #category : 'settings xp' }
NTSettings class >> settings [
	"Argh we have to get a tree to be able to load and save setting...."
	"self settings"
	
	| builder |
	builder := SettingTreeBuilder new.
	(Pragma allNamed: #systemsettings in: self class) collect: [ :each | builder buildPragma: each ].
	^ builder nodeList collect: [ :each | each item ]
]

{ #category : 'setting io' }
NTSettings class >> settingsNodes [
	"Argh we have to get a tree to be able to load and save setting...."
	"self settings"
	
	| builder |
	builder := SettingTreeBuilder new.
	(Pragma allNamed: #systemsettings in: self class) collect: [ :each | builder buildPragma: each ].
	^ builder nodeList 
]

{ #category : 'settings' }
NTSettings class >> settingsOn: aBuilder [

	<systemsettings>
	"<notetakersettings>"
	
	(aBuilder group: #tnt)
		label: 'The Note Taker';
		description: 'All TNT related settings';
		noOrdering;
		with: [
				(aBuilder group: #tnt_note)
					label: 'Note section parameter';
					with: [
							(aBuilder setting: #GitEnable)
								parent: #tnt_note;
								target: self;
								order: 60;
								label: 'enable git command';
								description: 'When enabled, show git command button.
When disabled, hide git command button. '.
							(aBuilder setting: #CurrentFolder)
								label: 'Project Path';
								target: self;
								type: #Directory;
								ghostHelp:
									'/Users/ducasse/Workspace/FirstCircle/Writing/Working/researchnotes';
								description:
									'Enter your local or remote path where notes will be committed. It can be empty' ] ]
]

{ #category : 'settings xp' }
NTSettings class >> settingsTree [
	"Argh we have to get a tree to be able to load and save setting...."
	"self settingsTree"
	
	| builder |
	builder := SettingTreeBuilder new.
	(Pragma allNamed: #systemsettings in: self class) collect: [ :each | builder buildPragma: each ].
	(SettingTree acceptableKeywords: #(#notetakersettings)) settingTreeRoots.
	
	^ builder inspect
]

{ #category : 'setting io' }
NTSettings class >> storeSetting [

	| writer |
	writer := SettingsStonWriter new.
	writer stream: self preferencesFileLocation writeStream.
	writer addSettings: (StoredSettingsFactory new fromSettingNodes: self settingsNodes).
	writer store.
	writer stream flush.

]

{ #category : 'enumerating' }
NTSettings >> currentFolder [

	^ currentFolder ifNil: [
			  currentFolder := (FileLocator documents / 'noteTaker')
				                   asFileReference ensureCreateDirectory ]
]

{ #category : 'enumerating' }
NTSettings >> currentFolder: aFileReference [
	
	currentFolder := aFileReference
]

{ #category : 'enumerating' }
NTSettings >> gitEnable [

	^ gitEnable ifNil: [ gitEnable := false ]
]

{ #category : 'enumerating' }
NTSettings >> gitEnable: aBoolean [

	gitEnable := aBoolean
]

{ #category : 'initialization' }
NTSettings >> initialize [

	self class initializeSlots: self.
	super initialize.
]

{ #category : 'enumerating' }
NTSettings >> whenCurrentFolderChangeDo: aBlock [

	self property: #currentFolder whenChangedDo: aBlock
]

{ #category : 'enumerating' }
NTSettings >> whenGitEnableChangeDo: aBlock [

	self property: #gitEnable whenChangedDo: aBlock
]
