Class {
	#name : 'NTSpImportNoteCommandTest',
	#superclass : 'NTSpCommandTest',
	#category : 'TheNoteTaker-UI-Tests',
	#package : 'TheNoteTaker-UI-Tests'
}

{ #category : 'running' }
NTSpImportNoteCommandTest >> setUp [

	super setUp.

	command := NTSpImportNoteCommand new context: indexPresenter
]

{ #category : 'tests' }
NTSpImportNoteCommandTest >> testImportNote [

	| fileReference |
	self assert: indexPresenter items size equals: 3.

	(memoryFS / 'folder') ensureCreateDirectory.
	fileReference := memoryFS / 'folder' / 'aFileReference.md'.
	fileReference ensureCreateFile.

	SpWindowSimulateOpenModal
		value: [ :aDialogPresenter |
				aDialogPresenter presenter
					openFolder: memoryFS / 'folder';
					selectFiles: (OrderedCollection new
							 add: fileReference;
							 yourself);
					confirm ]
		during: [ command execute ].

	self assert: indexPresenter items size equals: 4.
]
