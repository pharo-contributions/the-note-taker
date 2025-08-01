Class {
	#name : 'NTSpOpenNoteInOsFolder',
	#superclass : 'NTSpAbstractCommand',
	#category : 'TheNoteTaker-UI-Commands',
	#package : 'TheNoteTaker-UI',
	#tag : 'Commands'
}

{ #category : 'default' }
NTSpOpenNoteInOsFolder class >> defaultDescription [

	^ 'Open the note in browser of OS'
]

{ #category : 'default' }
NTSpOpenNoteInOsFolder class >> defaultName [

	^ 'Open note in OS Browser'
]

{ #category : 'converting' }
NTSpOpenNoteInOsFolder >> asSpecCommand [

	^ super asSpecCommand
		  iconName: #open;
		  shortcutKey: $O meta;
		  yourself
]

{ #category : 'converting' }
NTSpOpenNoteInOsFolder >> execute [
	
	self selectedNotes first fileReference openInOSFileBrowser.

	
]
