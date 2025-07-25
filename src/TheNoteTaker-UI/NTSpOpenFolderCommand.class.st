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
		  iconName: #into;
		  shortcutKey: $T meta;
		  yourself
]

{ #category : 'executing' }
NTSpOpenFolderCommand >> execute [

	| selectedDir |
	selectedDir := StOpenDirectoryPresenter new
		               extent: 800 @ 800;
		               openModal.
	selectedDir ifNil: [ ^ self ].
	self application currentFolder: selectedDir first.
	self application reset
]
