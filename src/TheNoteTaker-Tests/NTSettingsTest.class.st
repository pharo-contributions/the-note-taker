"
I test `NTSettings`: saving and loading the settings file, persisting changes, and that `NTSettings new` leaves `NTSettings default` alone.

The settings file lives in a memory file system, so I never touch the real preferences.
"
Class {
	#name : 'NTSettingsTest',
	#superclass : 'TestCase',
	#instVars : [
		'settings',
		'file',
		'savedSharedState'
	],
	#category : 'TheNoteTaker-Tests-Core',
	#package : 'TheNoteTaker-Tests',
	#tag : 'Core'
}

{ #category : 'helpers' }
NTSettingsTest >> loadedSettings [
	^ NTSettings new
		  loadFrom: file;
		  yourself
]

{ #category : 'running' }
NTSettingsTest >> setUp [

	super setUp.
	savedSharedState := NTSettings sharedState.
	file := FileSystem memory root / 'TheNoteTaker' / 'settings.ston'.
	settings := NTSettings new
]

{ #category : 'running' }
NTSettingsTest >> tearDown [

	NTSettings restoreSharedState: savedSharedState.
	super tearDown
]

{ #category : 'tests' }
NTSettingsTest >> testCopyValuesFrom [

	| other |
	other := NTSettings new
		         currentFolder: '/Users/me/Notes' asFileReference;
		         gitEnable: true;
		         listMode: #byTag;
		         showsTags: false;
		         autosaveSeconds: 20;
		         yourself.
	settings copyValuesFrom: other.
	self assert: settings currentFolder equals: other currentFolder.
	self assert: settings gitEnable.
	self assert: settings listMode equals: #byTag.
	self deny: settings showsTags.
	self assert: settings autosaveSeconds equals: 20
]

{ #category : 'tests' }
NTSettingsTest >> testDefaultPreferencesFileIsAStonFileInThePreferencesFolder [

	self
		assert: NTSettings defaultPreferencesFile
		equals: (FileLocator preferences / 'TheNoteTaker' / 'settings.ston') asFileReference
]

{ #category : 'tests' }
NTSettingsTest >> testDefaultValues [

	self deny: settings gitEnable.
	self assert: settings listMode equals: #byDate.
	self assert: settings showsTags.
	self assert: settings autosaveSeconds equals: 10
]

{ #category : 'tests' }
NTSettingsTest >> testListModesAreTheModesOfTheNoteList [

	self assert: NTSettings listModes equals: #( #byDate #byTag #compact )
]

{ #category : 'tests' }
NTSettingsTest >> testLoadFromBrokenFileKeepsGitDisabled [
	self writeFile: '[ this is not STON'.
	settings loadFrom: file.
	self deny: settings gitEnable
]

{ #category : 'tests' }
NTSettingsTest >> testLoadFromFileNotHoldingAMapKeepsDefaults [

	self writeFile: '[ true, 30 ]'.
	settings loadFrom: file.
	self deny: settings gitEnable
]

{ #category : 'tests' }
NTSettingsTest >> testLoadFromFileWithoutFolderUsesDefaultDocumentFolder [

	self writeFile: '{ ''gitEnable'' : true }'.
	settings loadFrom: file.
	self assert: settings currentFolder equals: (FileLocator documents / 'noteTaker') asFileReference
]

{ #category : 'tests' }
NTSettingsTest >> testLoadFromIgnoresUnknownSettings [

	self writeFile: '{ ''autoSave'' : true, ''gitEnable'' : true }'.
	settings loadFrom: file.
	self assert: settings gitEnable
]

{ #category : 'tests' }
NTSettingsTest >> testLoadFromIgnoresValuesOfTheWrongType [

	self writeFile: '{
	''currentFolder'' : 42,
	''gitEnable'' : ''yes'',
	''listMode'' : #unknownMode,
	''showsTags'' : 3,
	''autosaveSeconds'' : -5
}'.
	settings loadFrom: file.
	self assert: settings currentFolder equals: settings defaultDocumentFolder.
	self deny: settings gitEnable.
	self assert: settings listMode equals: #byDate.
	self assert: settings showsTags.
	self assert: settings autosaveSeconds equals: 10
]

{ #category : 'tests' }
NTSettingsTest >> testLoadFromMissingFileKeepsGitDisabled [
	settings loadFrom: file.
	self deny: settings gitEnable
]

{ #category : 'tests' }
NTSettingsTest >> testLoadFromReadsStonMap [

	self writeFile: '{
	''currentFolder'' : ''/Users/me/Notes'',
	''gitEnable'' : true,
	''listMode'' : #byTag,
	''showsTags'' : false,
	''autosaveSeconds'' : 30
}'.
	settings loadFrom: file.
	self assert: settings currentFolder fullName equals: '/Users/me/Notes'.
	self assert: settings gitEnable.
	self assert: settings listMode equals: #byTag.
	self deny: settings showsTags.
	self assert: settings autosaveSeconds equals: 30
]

{ #category : 'tests' }
NTSettingsTest >> testNewDoesNotReplaceDefault [
	| default |
	default := NTSettings default.
	NTSettings new.
	self assert: NTSettings default identicalTo: default
]

{ #category : 'tests' }
NTSettingsTest >> testPersistToLoadsExistingFile [
	| written |
	written := NTSettings new.
	written gitEnable: true.
	written saveTo: file.
	settings persistTo: file.
	self assert: settings gitEnable
]

{ #category : 'tests' }
NTSettingsTest >> testPersistToSavesWhenAutosaveSecondsChanges [

	settings persistTo: file.
	settings autosaveSeconds: 5.
	self assert: self loadedSettings autosaveSeconds equals: 5
]

{ #category : 'tests' }
NTSettingsTest >> testPersistToSavesWhenCurrentFolderChanges [
	settings persistTo: file.
	settings currentFolder: '/Users/me/Notes' asFileReference.
	self assert: self loadedSettings currentFolder fullName equals: '/Users/me/Notes'
]

{ #category : 'tests' }
NTSettingsTest >> testPersistToSavesWhenGitEnableChanges [
	settings persistTo: file.
	settings gitEnable: true.
	self assert: self loadedSettings gitEnable
]

{ #category : 'tests' }
NTSettingsTest >> testPersistToSavesWhenListModeChanges [

	settings persistTo: file.
	settings listMode: #compact.
	self assert: self loadedSettings listMode equals: #compact
]

{ #category : 'tests' }
NTSettingsTest >> testPersistToSavesWhenShowsTagsChanges [

	settings persistTo: file.
	settings showsTags: false.
	self deny: self loadedSettings showsTags
]

{ #category : 'tests' }
NTSettingsTest >> testSaveToSkipsFolderNotOnDisk [

	settings currentFolder: FileSystem memory root / 'notes'.
	settings saveTo: file.
	self deny: ((STON fromString: file contents) includesKey: 'currentFolder')
]

{ #category : 'tests' }
NTSettingsTest >> testSaveToThenLoadFromKeepsAutosaveSeconds [

	settings autosaveSeconds: 42.
	settings saveTo: file.
	self assert: self loadedSettings autosaveSeconds equals: 42
]

{ #category : 'tests' }
NTSettingsTest >> testSaveToThenLoadFromKeepsCurrentFolder [
	settings currentFolder: '/Users/me/Notes' asFileReference.
	settings saveTo: file.
	self assert: self loadedSettings currentFolder path equals: '/Users/me/Notes' asFileReference path
]

{ #category : 'tests' }
NTSettingsTest >> testSaveToThenLoadFromKeepsGitEnable [
	settings gitEnable: true.
	settings saveTo: file.
	self assert: self loadedSettings gitEnable
]

{ #category : 'tests' }
NTSettingsTest >> testSaveToThenLoadFromKeepsListMode [

	settings listMode: #byTag.
	settings saveTo: file.
	self assert: self loadedSettings listMode equals: #byTag
]

{ #category : 'tests' }
NTSettingsTest >> testSaveToThenLoadFromKeepsShowsTags [

	settings showsTags: false.
	settings saveTo: file.
	self deny: self loadedSettings showsTags
]

{ #category : 'tests' }
NTSettingsTest >> testSaveToWritesAStonMap [

	| map |
	settings
		currentFolder: '/Users/me/Notes' asFileReference;
		gitEnable: true;
		listMode: #compact;
		showsTags: false;
		autosaveSeconds: 25.
	settings saveTo: file.
	map := STON fromString: file contents.
	self assert: map equals: (Dictionary new
			 at: 'currentFolder' put: '/Users/me/Notes';
			 at: 'gitEnable' put: true;
			 at: 'listMode' put: #compact;
			 at: 'showsTags' put: false;
			 at: 'autosaveSeconds' put: 25;
			 yourself)
]

{ #category : 'helpers' }
NTSettingsTest >> writeFile: aString [
	"Write aString in the settings file, as Pharo settings persistence does"

	file parent ensureCreateDirectory.
	file writeStreamDo: [ :stream | stream nextPutAll: aString ]
]
