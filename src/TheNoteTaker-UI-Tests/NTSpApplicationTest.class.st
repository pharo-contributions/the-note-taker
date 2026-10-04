Class {
	#name : 'NTSpApplicationTest',
	#superclass : 'NTSpTestCase',
	#category : 'TheNoteTaker-UI-Tests',
	#package : 'TheNoteTaker-UI-Tests'
}

{ #category : 'tests' }
NTSpApplicationTest >> contentsOfConfigFile [

	^ '[
	StoredSetting {
		#settingNodeIdentifier : ''#tnt_note#GithubPathString'',
		#realValue : ''''
	},
	StoredSetting {
		#settingNodeIdentifier : ''#tnt_note#gitEnable'',
		#realValue : false
	},
	AbsolutePathStoredSetting {
		#settingNodeIdentifier : ''#tnt_note#currentFolder'',
		#realValue : [
			''Users'',
			''ducasse'',
			''Library'',
			''Preferences'',
			''TheNoteTaker'',
			''TNTSettings.config''
		]
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
	preferenceFile writeStreamDo: [ :stream |
		stream nextPutAll: self contentsOfConfigFile ].
	app preferencesFile: preferenceFile.
	app importSettings.
	
	self 
		assert: app currentFolder fullName 
		equals: '/Users/ducasse/Documents/noteTaker' 
]
