"
Open a Log presenter windows with all change of the open note directory.
"
Class {
	#name : 'NTSpLogCommand',
	#superclass : 'NTSpAbstractCommand',
	#category : 'TheNoteTaker-UI-Commands',
	#package : 'TheNoteTaker-UI',
	#tag : 'Commands'
}

{ #category : 'default' }
NTSpLogCommand class >> defaultDescription [

	^ 'Open a log browser'
]

{ #category : 'default' }
NTSpLogCommand class >> defaultName [

	^ 'Open log'
]

{ #category : 'executing' }
NTSpLogCommand >> asSpecCommand [

	^ super asSpecCommand
		  iconName: #recentMessages;
		  shortcutKey: $L meta;
		  beDisplayedOnRightSide;
		  yourself
]

{ #category : 'executing' }
NTSpLogCommand >> execute [

	| aFileReference |
	aFileReference := self application currentFolder
	                  / 'TheNoteTaker.log'.
	aFileReference exists ifFalse: [ aFileReference ensureCreateFile ].

	self context newText
		text: aFileReference contents;
		editable: false;
		openModal
]
