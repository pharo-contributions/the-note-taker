"
Implements logic to add a single note to a note taking application. Particularily, it provides a user-request dialog to ask for note input information to be added.
"
Class {
	#name : 'NTSpImportFolderCommand',
	#superclass : 'NTSpAbstractCommand',
	#category : 'TheNoteTaker-UI-Commands',
	#package : 'TheNoteTaker-UI',
	#tag : 'Commands'
}

{ #category : 'default' }
NTSpImportFolderCommand class >> defaultDescription [

	^ 'Import folder of notes'
]

{ #category : 'default' }
NTSpImportFolderCommand class >> defaultName [

	^ 'Import Folder'
]

{ #category : 'converting' }
NTSpImportFolderCommand >> asSpecCommand [

	^ super asSpecCommand
		  iconName: #folder;
		  shortcutKey: $T meta;
		  yourself
]

{ #category : 'executing' }
NTSpImportFolderCommand >> execute [

	StOpenDirectoryPresenter new
		application: self application;
		openFolder: self application currentFolder;
		extent: 800 @ 800;
		okAction: [ :dir | self noteTakerContainer importFolder: dir ];
		openModal.
	self context updatePresenter
]
