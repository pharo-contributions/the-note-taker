"
Implements logic to add a single note to a note taking application. Particularily, it provides a user-request dialog to ask for note input information to be added.
"
Class {
	#name : 'NTSpImportNoteCommand',
	#superclass : 'NTSpAbstractCommand',
	#category : 'TheNoteTaker-UI-Commands',
	#package : 'TheNoteTaker-UI',
	#tag : 'Commands'
}

{ #category : 'default' }
NTSpImportNoteCommand class >> defaultDescription [

	^ 'Import notes'
]

{ #category : 'default' }
NTSpImportNoteCommand class >> defaultName [

	^ 'Import Notes'
]

{ #category : 'converting' }
NTSpImportNoteCommand >> asSpecCommand [

	^ super asSpecCommand
		  iconName: #into;
		  shortcutKey: $I meta;
		  yourself
]

{ #category : 'executing' }
NTSpImportNoteCommand >> execute [

	| selections |
	selections := (StOpenFilePresenter new
		               extent: 800 @ 800;
		               extensions: { 'txt'. 'mic'. 'md' };
		               yourself) openModal.
	selections do: [ :each | self noteTakerContainer addNoteFromFileReference: each ].
	self context updatePresenter
]
