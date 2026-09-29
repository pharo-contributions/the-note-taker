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
	#classVars : [
		'CurrentFolder',
		'Default',
		'GitEnable'
	],
	#category : 'TheNoteTaker-Core',
	#package : 'TheNoteTaker',
	#tag : 'Core'
}

{ #category : 'private' }
NTSettings class >> currentFolder [

	^ CurrentFolder ifNil: [
			  CurrentFolder := (FileLocator documents / 'noteTaker')
				                   asFileReference ensureCreateDirectory ]
]

{ #category : 'private' }
NTSettings class >> currentFolder: aFolder [

	CurrentFolder := aFolder
]

{ #category : 'commands' }
NTSettings class >> gitEnable [

	^ GitEnable
]

{ #category : 'commands' }
NTSettings class >> gitEnable: aBoolean [

	GitEnable := aBoolean
]

{ #category : 'settings xp' }
NTSettings class >> load [
	
	| storedSettings |
	storedSettings := (SystemSettingsPersistence new fileReference: self preferencesFileLocation)
	settingsNodesFromIdentifiers: #('GitEnable' 'CurrentFolder')
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
	"self settings"

	| builder |
	builder := SettingTreeBuilder new.
	(Pragma allNamed: #systemsettings in: self class) collect: [ :each |
		builder buildPragma: each ].
	^ builder nodeList collect: [ :each | each item ]
]

{ #category : 'setting io' }
NTSettings class >> settingsNodes [
	"Argh we have to get a tree to be able to load and save setting...."

	"self settingsNodes"

	| builder |
	builder := SettingTreeBuilder new.
	(Pragma allNamed: #systemsettings in: self class) 
		collect: [ :each | builder buildPragma: each ].
	^ builder nodeList
]

{ #category : 'settings' }
NTSettings class >> settingsOn: aBuilder [
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

	"we use the class and not directly the sharedVariable because there is a lazy initialize
	for the default location."
	
	^ self class currentFolder
]

{ #category : 'enumerating' }
NTSettings >> currentFolder: aFileReference [

	CurrentFolder := aFileReference
]

{ #category : 'enumerating' }
NTSettings >> gitEnable [

	^ GitEnable ifNil: [ GitEnable := false ]
]

{ #category : 'enumerating' }
NTSettings >> gitEnable: aBoolean [

	GitEnable := aBoolean
]

{ #category : 'initialization' }
NTSettings >> initialize [

	"this is mandatory for the observableSlots"
	self class initializeSlots: self.
	super initialize
]

{ #category : 'enumerating' }
NTSettings >> whenCurrentFolderChangeDo: aBlock [

	self 
		property: #currentFolder 
		whenChangedDo: aBlock
]

{ #category : 'enumerating' }
NTSettings >> whenGitEnableChangeDo: aBlock [

	self property: #gitEnable whenChangedDo: aBlock
]
