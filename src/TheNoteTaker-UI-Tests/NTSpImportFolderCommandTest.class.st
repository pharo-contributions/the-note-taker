Class {
	#name : 'NTSpImportFolderCommandTest',
	#superclass : 'NTSpCommandTest',
	#category : 'TheNoteTaker-UI-Tests',
	#package : 'TheNoteTaker-UI-Tests'
}

{ #category : 'running' }
NTSpImportFolderCommandTest >> setUp [

	super setUp.

	command := NTSpImportFolderCommand new context: indexPresenter
]

{ #category : 'tests' }
NTSpImportFolderCommandTest >> testImportFolder [

	| folderReference fileReference1 fileReference2 fileReference3 |
	self assert: indexPresenter items size equals: 3.
	
	folderReference := FileLocator workingDirectory / 'note'.
	folderReference ensureCreateDirectory.

	fileReference1 := folderReference / 'aFileReference1.md'.
	fileReference1 ensureCreateFile.
	
	fileReference2 := folderReference / 'aFileReference2.md'.
	fileReference2 ensureCreateFile.
	
	fileReference3 := folderReference / 'aFileReference3.md'.
	fileReference3 ensureCreateFile.

	SpWindowSimulateOpenModal
		value: [ :aDialogPresenter |
				aDialogPresenter presenter
					selectFiles: (OrderedCollection new
							 add: folderReference;
							 yourself);
					confirm ]
		during: [ command execute ].

	self assert: indexPresenter items size equals: 4.
	
	fileReference1 ensureDelete.
	fileReference2 ensureDelete.
	fileReference3 ensureDelete.

	folderReference ensureDelete
]
