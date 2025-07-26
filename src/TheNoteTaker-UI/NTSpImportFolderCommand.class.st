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

{ #category : 'adding' }
NTSpImportFolderCommand >> addNoteFromFileReference: aFileReference [

	self noteTakerContainer addNoteFromFileReference: aFileReference
]

{ #category : 'converting' }
NTSpImportFolderCommand >> asSpecCommand [

	^ super asSpecCommand
		  iconName: #into;
		  shortcutKey: $T meta;
		  yourself
]

{ #category : 'executing' }
NTSpImportFolderCommand >> execute [

	| selections |
	selections := StOpenDirectoryPresenter new
		              extent: 800 @ 800;
		              openModal.
	selections ifNil: [ ^ self ].
	selections do: [ :each | self processFolder: each ]
]

{ #category : 'executing' }
NTSpImportFolderCommand >> executeWithFolder: aFileReference [

	aFileReference exists ifFalse: [ ^ self ].
	self processFolder: aFileReference
]

{ #category : 'executing' }
NTSpImportFolderCommand >> processFolder: aFileReference [

	aFileReference allFiles
		select: [ :fileRef |
			self validNoteExtensions includes: fileRef extension asLowercase ]
		thenDo: [ :fileRef | "this test should be grouped somewhere else!"
			self addNoteFromFileReference: fileRef ].
	
	self context updatePresenter
]

{ #category : 'executing' }
NTSpImportFolderCommand >> validNoteExtensions [
	"Answer a <Collection> of <String> each one specifying a valid file extension for a note"

	^ { 'txt'. 'md' .'text' }
]
