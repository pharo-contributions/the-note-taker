"
I hold the settings of The Note Taker and save them in my own STON file, in the Pharo preferences folder.
Each setting is observable, so the applications react when it changes.

## Life cycle: who creates me and who uses me

1. `NTSettings class>>#default` creates the shared settings of the user, loaded from and saved to `NTSettings class>>#defaultPreferencesFile` (`<preferences>/TheNoteTaker/settings.ston`) with `persistTo:`. `NT3Application class>>#open` gives them to its application (`NT3Application class>>#onSettings:`).
2. `NT3Application>>#initialize` creates its own settings with `new`, kept in memory, until `settings:` replaces them.
3. `NT3Application` reads its notes folder from me, and reads and changes the list mode, whether tags are shown and the autosave delay.
4. `NTSettingsPresenter` edits me: it writes its fields into me when accepted (`NT3NoteListPresenter>>#openSettings` opens it).

## Responsibility:

- I know the notes folder (`currentFolder`), the git switch (`gitEnable`), the mode of the note list (`listMode`, one of `NTSettings listModes`), whether the list shows tags (`showsTags`) and the autosave delay in seconds (`autosaveSeconds`).
- I announce each change (`whenCurrentFolderChangeDo:`, `whenGitEnableChangeDo:`, `property:whenChangedDo:`).
- I read and write myself as a STON map, ignoring unknown keys and values of the wrong type.

## Collaborators:

- `STON`: reads and writes my file.
- `NTSettingsPresenter`: the editor of my values.
- `NT3ListMode`: its subclasses have the names of `NTSettings listModes` (`settingName`).

## Public API and Key Messages

- `NTSettings new` creates independent settings, for an application or a test. It never replaces `NTSettings default`.
- `NTSettings default` answers the shared settings, kept in the preferences file.
- `loadFrom: aFile` and `saveTo: aFile` read and write a settings file; `persistTo: aFile` loads from aFile, then saves to it each time a setting changes.
- `copyValuesFrom: otherSettings` takes the values of other settings.

## Examples

```
NTSettings exampleWithGitEnabled.
NTSettings scriptPersistToAStonFile.
```

The file looks like this (key order may vary):

```
{
	'currentFolder' : '/Users/me/Notes',
	'gitEnable' : true,
	'listMode' : #byTag,
	'showsTags' : false,
	'autosaveSeconds' : 30
}
```

## Internal Representation

All my slots are `ObservableSlot`s, lazily set to their default:
- `currentFolder`: a `FileReference`; `~/Documents/noteTaker` by default, created when first asked.
- `gitEnable`: a `Boolean`, false by default.
- `listMode`: a `Symbol`, `#byDate` by default.
- `showsTags`: a `Boolean`, true by default.
- `autosaveSeconds`: a positive `Integer`, 10 by default.

### Implementation Points

- A folder not on disk (e.g. in a memory file system during tests) is not written.
- `sharedState` and `restoreSharedState:` let tests restore `Default`.
"
Class {
	#name : 'NTSettings',
	#superclass : 'Object',
	#traits : 'TObservable',
	#classTraits : 'TObservable classTrait',
	#instVars : [
		'#currentFolder => ObservableSlot',
		'#gitEnable => ObservableSlot',
		'#listMode => ObservableSlot',
		'#showsTags => ObservableSlot',
		'#autosaveSeconds => ObservableSlot'
	],
	#classVars : [
		'#Default'
	],
	#category : 'TheNoteTaker-Core',
	#package : 'TheNoteTaker',
	#tag : 'Core'
}

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
	"Answer the file holding the user's settings, in the Pharo preferences folder"

	^ (FileLocator preferences / 'TheNoteTaker' / 'settings.ston') asFileReference
]

{ #category : 'examples' }
NTSettings class >> exampleWithGitEnabled [
	"Settings using a notes folder, showing the git commands and listing the notes by tag without their tags"

	<sampleInstance>
	^ self new
		  currentFolder: '/Users/me/Notes' asFileReference;
		  gitEnable: true;
		  listMode: #byTag;
		  showsTags: false;
		  autosaveSeconds: 30;
		  yourself
]

{ #category : 'settings' }
NTSettings class >> listModes [
	"Answer the names of the modes of the note list, in the order of its mode buttons"

	^ #( #byDate #byTag #compact )
]

{ #category : 'settings' }
NTSettings class >> reset [

	<script>
	Default := nil
]

{ #category : 'testing support' }
NTSettings class >> restoreSharedState: aNTSettingsOrNil [

	Default := aNTSettingsOrNil
]

{ #category : 'script' }
NTSettings class >> scriptPersistToAStonFile [
	"Settings persisted to a STON file in memory: changing a setting rewrites the file. Answers the contents of the file"

	<example>
	| settings file |
	file := FileSystem memory root / 'TheNoteTaker' / 'settings.ston'.
	settings := self new.
	settings persistTo: file.
	settings
		gitEnable: true;
		listMode: #compact.
	^ file contents
]

{ #category : 'settings' }
NTSettings class >> settingNames [
	"Answer the names of the settings, which are also the names of their observable slots"

	^ #( #currentFolder #gitEnable #listMode #showsTags #autosaveSeconds )
]

{ #category : 'testing support' }
NTSettings class >> sharedState [
	"Answer the shared settings, so that tests can restore them with `restoreSharedState:`"

	^ Default
]

{ #category : 'private - persistence' }
NTSettings >> asMap [
	"Answer the settings to write, as a Dictionary of strings, symbols, booleans and integers.
	A folder that is unset or not on disk (e.g. in a memory file system during tests) is not written"

	| map |
	map := Dictionary new.
	(currentFolder isNotNil and: [ currentFolder asFileReference fileSystem isDiskFileSystem ]) ifTrue: [
		map at: 'currentFolder' put: currentFolder asFileReference fullName ].
	^ map
		  at: 'gitEnable' put: self gitEnable;
		  at: 'listMode' put: self listMode;
		  at: 'showsTags' put: self showsTags;
		  at: 'autosaveSeconds' put: self autosaveSeconds;
		  yourself
]

{ #category : 'accessing' }
NTSettings >> autosaveSeconds [
	"Answer how many seconds after the last edit the unsaved notes are saved"

	^ autosaveSeconds ifNil: [ autosaveSeconds := 10 ]
]

{ #category : 'accessing' }
NTSettings >> autosaveSeconds: anInteger [

	autosaveSeconds := anInteger
]

{ #category : 'accessing' }
NTSettings >> copyValuesFrom: aNTSettings [
	"Take the values of aNTSettings. Each changed value is announced"

	self
		currentFolder: aNTSettings currentFolder;
		gitEnable: aNTSettings gitEnable;
		listMode: aNTSettings listMode;
		showsTags: aNTSettings showsTags;
		autosaveSeconds: aNTSettings autosaveSeconds
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

{ #category : 'initialization' }
NTSettings >> initialize [

	self class initializeSlots: self.
	super initialize.
]

{ #category : 'accessing' }
NTSettings >> listMode [
	"Answer the name of the mode of the note list, one of `NTSettings listModes`"

	^ listMode ifNil: [ listMode := self class listModes first ]
]

{ #category : 'accessing' }
NTSettings >> listMode: aSymbol [

	listMode := aSymbol
]

{ #category : 'persistence' }
NTSettings >> loadFrom: aFile [
	"Set the receiver's settings from aFile, a STON map written by `saveTo:`.
	A missing or unreadable file, unknown keys and values of the wrong type are ignored"

	| map |
	aFile exists ifFalse: [ ^ self ].
	map := [ STON fromString: aFile contents ]
		       on: STONReaderError
		       do: [ ^ self ].
	map isDictionary ifFalse: [ ^ self ].
	self loadFromMap: map
]

{ #category : 'private - persistence' }
NTSettings >> loadFromMap: aDictionary [
	"Take the values of aDictionary that have the expected type"

	self
		read: 'currentFolder'
		from: aDictionary
		valid: #isString
		do: [ :value | self currentFolder: value asFileReference ].
	self
		read: 'gitEnable'
		from: aDictionary
		valid: [ :value | #( true false ) includes: value ]
		do: [ :value | self gitEnable: value ].
	self loadNoteListFromMap: aDictionary
]

{ #category : 'private - persistence' }
NTSettings >> loadNoteListFromMap: aDictionary [
	"Take the settings of the note list and of the autosave in aDictionary that have the expected type"

	self
		read: 'listMode'
		from: aDictionary
		valid: [ :value | value isString and: [ self class listModes includes: value asSymbol ] ]
		do: [ :value | self listMode: value asSymbol ].
	self
		read: 'showsTags'
		from: aDictionary
		valid: [ :value | #( true false ) includes: value ]
		do: [ :value | self showsTags: value ].
	self
		read: 'autosaveSeconds'
		from: aDictionary
		valid: [ :value | value isInteger and: [ value > 0 ] ]
		do: [ :value | self autosaveSeconds: value ]
]

{ #category : 'persistence' }
NTSettings >> persistTo: aFile [
	"Load the receiver from aFile, then save it in aFile each time a setting changes"

	self loadFrom: aFile.
	self class settingNames do: [ :each | self property: each whenChangedDo: [ self saveTo: aFile ] ]
]

{ #category : 'private - persistence' }
NTSettings >> read: aKey from: aDictionary valid: aValidBlock do: aBlock [
	"Evaluate aBlock with the value of aKey in aDictionary when there is one and aValidBlock accepts it"

	aDictionary at: aKey ifPresent: [ :value | (aValidBlock value: value) ifTrue: [ aBlock value: value ] ]
]

{ #category : 'persistence' }
NTSettings >> saveTo: aFile [
	"Write the receiver's settings in aFile, as a STON map"

	aFile parent ensureCreateDirectory.
	aFile ensureDelete.
	aFile writeStreamDo: [ :stream | STON put: self asMap onStreamPretty: stream ]
]

{ #category : 'accessing' }
NTSettings >> showsTags [
	"Answer whether the note list shows the first tags of the notes"

	^ showsTags ifNil: [ showsTags := true ]
]

{ #category : 'accessing' }
NTSettings >> showsTags: aBoolean [

	showsTags := aBoolean
]

{ #category : 'subscriptions' }
NTSettings >> unsubscribe: anObject [
	"Stop evaluating, on a change of a setting, the blocks that anObject subscribed"

	self class settingNames do: [ :each | (self observablePropertyNamed: each) unsubscribe: anObject ]
]

{ #category : 'enumerating' }
NTSettings >> whenCurrentFolderChangeDo: aBlock [

	self property: #currentFolder whenChangedDo: aBlock
]

{ #category : 'enumerating' }
NTSettings >> whenGitEnableChangeDo: aBlock [

	self property: #gitEnable whenChangedDo: aBlock
]
