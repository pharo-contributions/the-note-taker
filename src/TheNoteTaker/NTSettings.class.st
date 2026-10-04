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
NTSettings class >> currentFolder [

	^ self default currentFolder
]

{ #category : 'private' }
NTSettings class >> currentFolder: aFileReference [

	self default currentFolder: aFileReference
]

{ #category : 'private' }
NTSettings class >> default [

	^ Default ifNil: [ Default := self new ]
]

{ #category : 'private' }
NTSettings class >> default: aNTSettings [

	Default := aNTSettings
]

{ #category : 'settings' }
NTSettings class >> defaultPreferencesFile [

	^ (FileLocator preferences / 'TheNoteTaker' / 'TNTSettings.config') asFileReference
]

{ #category : 'commands' }
NTSettings class >> gitEnable [

	^ self default gitEnable
]

{ #category : 'commands' }
NTSettings class >> gitEnable: aBoolean [

	self default gitEnable: aBoolean
]

{ #category : 'settings xp' }
NTSettings class >> load [ 
	"self load"
	
	| storedSettings |
	"I over pass all the machenery of Persistence for now because I need to understand it better"
	
	storedSettings := (SystemSettingsPersistence new fileReference: self defaultPreferencesFile) allStoredSettings collect: [ :each | (each settingNodeIdentifier splitOn: '#') last ].
	
	storedSettings := (SystemSettingsPersistence new fileReference: self defaultPreferencesFile).
]

{ #category : 'setting io' }
NTSettings class >> loadSettings [
	"self loadSettings"
	
	| reader storedSettings settingDeclarations |
	self halt.
	reader := SettingsStonReader new stream: self defaultPreferencesFile readStream.
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
							(aBuilder setting: #gitEnable)
								parent: #tnt_note;
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
	writer stream: self preferencesFile writeStream.
	writer addSettings: (StoredSettingsFactory new fromSettingNodes: self settingsNodes).
	writer store.
	writer stream flush.

]

{ #category : 'enumerating' }
NTSettings >> currentFolder [

	^ currentFolder ifNil: [
			  currentFolder := self defaultDocumentFolder ensureDirectory ]
]

{ #category : 'enumerating' }
NTSettings >> currentFolder: aFileReference [
	
	currentFolder := aFileReference
]

{ #category : 'enumerating' }
NTSettings >> defaultDocumentFolder [

	^ (FileLocator documents / 'noteTaker') asFileReference 
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
