"
I hold the settings of The Note Taker: the folder of the notes and whether the git commands are shown.
Each setting is observable, so the application reacts when it changes.

## Responsibility:

- I know the notes folder (`currentFolder`) and the git switch (`gitEnable`).
- I announce changes with `whenCurrentFolderChangeDo:` and `whenGitEnableChangeDo:`.
- I load and save myself in a file, in the format of the Pharo settings persistence.

## Collaborators:

- `SettingsStonReader` and `SettingsStonWriter` read and write my file, holding `StoredSetting` and `AbsolutePathStoredSetting` objects.
- The Pharo Settings browser edits `NTSettings default` through my class-side accessors (see `NTSettings class >> #settingsOn:`).

## Public API and Key Messages

- `NTSettings new` creates independent settings, for an application or a test. It never replaces `NTSettings default`.
- `NTSettings default` answers the settings of the Settings browser, loaded from and saved to `NTSettings defaultPreferencesFile`.
- `loadFrom: aFile` and `saveTo: aFile` read and write a settings file.
- `persistTo: aFile` loads from aFile, then saves to it each time a setting changes.

```
| settings |
settings := NTSettings new.
settings persistTo: FileSystem memory root / 'settings.config'.
settings gitEnable: true. ""now written in the file""
```

See `NTSettings class >> #exampleWithGitEnabled`.

## Internal Representation

- `currentFolder` (`ObservableSlot`): a `FileReference`. When unset, I answer `~/Documents/noteTaker` and create it.
- `gitEnable` (`ObservableSlot`): a `Boolean`, false by default.

### Implementation Points

In the file, a setting is named like in the Settings browser, e.g. `#tnt_note#gitEnable`. When loading I only look at the last part of the name, and I skip settings I do not know.
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

{ #category : 'accessing' }
NTSettings class >> default [
	"Answer the settings edited by the Settings browser, kept in the preferences file"

	^ Default ifNil: [
		  Default := self new
			             persistTo: self defaultPreferencesFile;
			             yourself ]
]

{ #category : 'private' }
NTSettings class >> default: aNTSettings [

	Default := aNTSettings
]

{ #category : 'settings' }
NTSettings class >> defaultPreferencesFile [

	^ (FileLocator preferences / 'TheNoteTaker' / 'TNTSettings.config') asFileReference
]

{ #category : 'examples' }
NTSettings class >> exampleWithGitEnabled [
	"Settings using a notes folder and showing the git commands"

	<sampleInstance>
	^ self new
		  currentFolder: '/Users/me/Notes' asFileReference;
		  gitEnable: true;
		  yourself
]

{ #category : 'commands' }
NTSettings class >> gitEnable [

	^ self default gitEnable
]

{ #category : 'commands' }
NTSettings class >> gitEnable: aBoolean [

	self default gitEnable: aBoolean
]

{ #category : 'settings' }
NTSettings class >> reset [

	<script>
	Default := nil
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
								ghostHelp: '/Users/ducasse/Workspace/FirstCircle/Writing/Working/researchnotes/';
								description: 'Enter your local or remote path where notes will be committed. It can be empty' ] ]
]

{ #category : 'enumerating' }
NTSettings >> currentFolder [

	^ currentFolder ifNil: [
			  currentFolder := self defaultDocumentFolder ensureCreateDirectory ]
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

{ #category : 'private - persistence' }
NTSettings >> identifierOf: aSettingName [
	"Answer the identifier the Settings browser uses for aSettingName"

	^ '#tnt_note#' , aSettingName
]

{ #category : 'initialization' }
NTSettings >> initialize [

	self class initializeSlots: self.
	super initialize.
]

{ #category : 'persistence' }
NTSettings >> loadFrom: aFile [
	"Set the receiver's settings from aFile, written in the format of Pharo settings persistence.
	A missing or unreadable file and unknown settings are ignored."

	aFile exists ifFalse: [ ^ self ].
	(SettingsStonReader new
		 stream: aFile readStream;
		 secureLoad) do: [ :each | self loadStoredSetting: each ]
]

{ #category : 'private - persistence' }
NTSettings >> loadStoredSetting: aStoredSetting [
	| name |
	name := (aStoredSetting settingNodeIdentifier splitOn: '#') last.
	name = 'currentFolder' ifTrue: [ ^ self currentFolder: aStoredSetting realValue ].
	name = 'gitEnable' ifTrue: [ ^ self gitEnable: aStoredSetting realValue ]
]

{ #category : 'persistence' }
NTSettings >> persistTo: aFile [
	"Load the receiver from aFile, then save it in aFile each time a setting changes"

	self loadFrom: aFile.
	self whenCurrentFolderChangeDo: [ self saveTo: aFile ].
	self whenGitEnableChangeDo: [ self saveTo: aFile ]
]

{ #category : 'persistence' }
NTSettings >> saveTo: aFile [
	"Write the receiver's settings in aFile, in the format of Pharo settings persistence"

	aFile parent ensureCreateDirectory.
	aFile ensureDelete.
	aFile writeStreamDo: [ :stream |
		SettingsStonWriter new
			stream: stream;
			addSettings: self storedSettings;
			store ]
]

{ #category : 'private - persistence' }
NTSettings >> storedSettings [
	"Answer the settings to write, as Pharo settings persistence objects.
	A folder that is unset or not on disk (e.g. in a memory file system during tests) is not written"

	| result |
	result := OrderedCollection new.
	(currentFolder isNotNil and: [ currentFolder fileSystem isDiskFileSystem ]) ifTrue: [
		result add: (AbsolutePathStoredSetting new
				 settingNodeIdentifier: (self identifierOf: #currentFolder);
				 realValue: currentFolder path segments asArray;
				 yourself) ].
	result add: (StoredSetting new
			 settingNodeIdentifier: (self identifierOf: #gitEnable);
			 realValue: self gitEnable;
			 yourself).
	^ result
]

{ #category : 'enumerating' }
NTSettings >> whenCurrentFolderChangeDo: aBlock [

	self property: #currentFolder whenChangedDo: aBlock
]

{ #category : 'enumerating' }
NTSettings >> whenGitEnableChangeDo: aBlock [

	self property: #gitEnable whenChangedDo: aBlock
]
