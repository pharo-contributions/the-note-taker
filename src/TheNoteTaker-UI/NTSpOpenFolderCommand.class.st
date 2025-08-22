"
Implements logic to add a single note to a note taking application. Particularily, it provides a user-request dialog to ask for note input information to be added.
"
Class {
	#name : 'NTSpOpenFolderCommand',
	#superclass : 'NTSpAbstractCommand',
	#category : 'TheNoteTaker-UI-Commands',
	#package : 'TheNoteTaker-UI',
	#tag : 'Commands'
}

{ #category : 'default' }
NTSpOpenFolderCommand class >> defaultDescription [

	^ 'Open folder of notes'
]

{ #category : 'default' }
NTSpOpenFolderCommand class >> defaultName [

	^ 'Open Folder'
]

{ #category : 'converting' }
NTSpOpenFolderCommand >> asSpecCommand [

	^ super asSpecCommand
		  iconName: #open;
		  shortcutKey: $T meta;
		  yourself
]

{ #category : 'executing' }
NTSpOpenFolderCommand >> execute [

	StOpenDirectoryPresenter new
		application: self application;
		openFolder: self application currentFolder;
		extent: 800 @ 800;
		okAction: [ :dir |
				self application currentFolder: dir.
				self application reset ];
		openModal
]
