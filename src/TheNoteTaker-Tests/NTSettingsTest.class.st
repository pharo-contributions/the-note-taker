"
I test `NTSettings`: saving and loading the settings file, persisting changes, and that `NTSettings new` leaves `NTSettings default` alone.

The settings file lives in a memory file system, so I never touch the real preferences.
"
Class {
	#name : 'NTSettingsTest',
	#superclass : 'TestCase',
	#instVars : [
		'settings',
		'file'
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
	file := FileSystem memory root / 'TheNoteTaker' / 'settings.config'.
	settings := NTSettings new
]

{ #category : 'tests' }
NTSettingsTest >> testLoadFromBrokenFileKeepsGitDisabled [
	self writeFile: '[ this is not STON'.
	settings loadFrom: file.
	self deny: settings gitEnable
]

{ #category : 'tests' }
NTSettingsTest >> testLoadFromFileWithoutFolderUsesDefaultDocumentFolder [
	self writeFile: '[
	StoredSetting {
		#settingNodeIdentifier : ''#tnt_note#gitEnable'',
		#realValue : true
	}
]'.
	settings loadFrom: file.
	self assert: settings currentFolder equals: (FileLocator documents / 'noteTaker') asFileReference
]

{ #category : 'tests' }
NTSettingsTest >> testLoadFromIgnoresUnknownSettings [
	self writeFile: '[
	StoredSetting {
		#settingNodeIdentifier : ''#tnt_note#AutoSave'',
		#realValue : true
	},
	StoredSetting {
		#settingNodeIdentifier : ''#tnt_note#gitEnable'',
		#realValue : true
	}
]'.
	settings loadFrom: file.
	self assert: settings gitEnable
]

{ #category : 'tests' }
NTSettingsTest >> testLoadFromMissingFileKeepsGitDisabled [
	settings loadFrom: file.
	self deny: settings gitEnable
]

{ #category : 'tests' }
NTSettingsTest >> testLoadFromReadsPharoSettingsFormat [
	self writeFile: '[
	AbsolutePathStoredSetting {
		#settingNodeIdentifier : ''#tnt_note#currentFolder'',
		#realValue : [ ''Users'', ''me'', ''Notes'' ]
	},
	StoredSetting {
		#settingNodeIdentifier : ''#tnt_note#gitEnable'',
		#realValue : true
	}
]'.
	settings loadFrom: file.
	self assert: settings currentFolder fullName equals: '/Users/me/Notes'.
	self assert: settings gitEnable
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
NTSettingsTest >> testSaveToSkipsFolderNotOnDisk [
	settings currentFolder: FileSystem memory root / 'notes'.
	settings saveTo: file.
	self
		assert: (self loadedSettings storedSettings collect: [ :each | each settingNodeIdentifier ] as: Array)
		equals: #( '#tnt_note#gitEnable' )
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

{ #category : 'helpers' }
NTSettingsTest >> writeFile: aString [
	"Write aString in the settings file, as Pharo settings persistence does"

	file parent ensureCreateDirectory.
	file writeStreamDo: [ :stream | stream nextPutAll: aString ]
]
