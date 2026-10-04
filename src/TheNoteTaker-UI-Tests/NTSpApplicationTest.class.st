Class {
	#name : 'NTSpApplicationTest',
	#superclass : 'NTSpTestCase',
	#category : 'TheNoteTaker-UI-Tests',
	#package : 'TheNoteTaker-UI-Tests'
}

{ #category : 'tests' }
NTSpApplicationTest >> contentsOfConfigFile [

	^ '[
	AbsolutePathStoredSetting {
		#settingNodeIdentifier : ''#tnt_note#currentFolder'',
		#realValue : [
			''Users'',
			''ducasse'',
			''Documents'',
			''TheNoteTaker''
		]
	},
	StoredSetting {
		#settingNodeIdentifier : ''#tnt_note#gitEnable'',
		#realValue : false
	},
	StoredSetting {
		#settingNodeIdentifier : ''#tnt_note#AutoSave'',
		#realValue : true
	}
]'
]

{ #category : 'tests' }
NTSpApplicationTest >> contentsOfConfigFile2 [

	^ '[
	AbsolutePathStoredSetting {
		#settingNodeIdentifier : ''#tnt_note#currentFolder'',
		#realValue : [
			''Users'',
			''ducasse'',
			''Documents'',
			''NewTheNoteTaker''
		]
	},
	StoredSetting {
		#settingNodeIdentifier : ''#tnt_note#gitEnable'',
		#realValue : false
	},
	StoredSetting {
		#settingNodeIdentifier : ''#tnt_note#AutoSave'',
		#realValue : true
	}
]'
]

{ #category : 'tests' }
NTSpApplicationTest >> testChangeCurrentFolderImportIt [

	| noteFile |
	(memoryFS / 'test') ensureCreateDirectory.
	noteFile := memoryFS / 'test' / '2024-06-12_newNote.md'.
	noteFile writeStreamDo: [ :stream |
		stream nextPutAll: 'This is just a new note' ].
	
	self assertEmpty: noteContainer notes.
	
	app currentFolder: (memoryFS / 'test').
	
	self assert: noteContainer notesCount equals: 1.
	self assert: (noteContainer notesContentsMatching: 'This is just a new note') size equals: 1
]

{ #category : 'tests' }
NTSpApplicationTest >> testPreferenceFile [

	| preferenceFile |
	(memoryFS / 'test') ensureCreateDirectory.
	preferenceFile := memoryFS / 'test' / 'settings.config'.
	preferenceFile writeStreamDo: [ :stream | stream nextPutAll: self contentsOfConfigFile ].
	(memoryFS / 'ducasse') ensureCreateDirectory.
	(memoryFS / 'ducasse' / 'Documents') ensureCreateDirectory.
	(memoryFS / 'ducasse' / 'Documents' /'TheNoteTaker') ensureCreateDirectory.
	
	app preferencesFile: preferenceFile.
	app importSettings2.

	self assert: app currentFolder fullName equals: '/Users/ducasse/Documents/TheNoteTaker'
]

{ #category : 'tests' }
NTSpApplicationTest >> testPreferenceFile2 [

	| preferenceFile |
	(memoryFS / 'test') ensureCreateDirectory.
	preferenceFile := memoryFS / 'test' / 'settings.config'.
	preferenceFile writeStreamDo: [ :stream | stream nextPutAll: self contentsOfConfigFile2 ].
	(memoryFS / 'ducasse') ensureCreateDirectory.
	(memoryFS / 'ducasse' / 'Documents') ensureCreateDirectory.
	(memoryFS / 'ducasse' / 'Documents' / 'TheNoteTaker') ensureCreateDirectory.

	app preferencesFile: preferenceFile.
	app importSettings2.

	self assert: app currentFolder fullName equals: '/Users/ducasse/Documents/NewTheNoteTaker'
]
