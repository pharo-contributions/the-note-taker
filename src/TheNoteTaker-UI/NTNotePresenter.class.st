Class {
	#name : 'NTNotePresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'note'
	],
	#category : 'TheNoteTaker-UI',
	#package : 'TheNoteTaker-UI'
}

{ #category : 'layout' }
NTNotePresenter >> defaultLayout [

	^ SpBoxLayout newTopToBottom
		  add: note title;
		  add: note creationDate asDate asString;
		  add: self displayNoteTags;
		  yourself
]

{ #category : 'layout' }
NTNotePresenter >> displayNoteTags [
	"Answer a <String> to be displayed"

	| orderedTags |
	note tags ifEmpty: [ ^ '' ].
	
	orderedTags := note tags asOrderedCollection sorted: [:a :b | a tagName < b tagName].
	^ (orderedTags collect: [ :each | each tagName ]) asArray joinUsing: ','
]

{ #category : 'layout' }
NTNotePresenter >> initializePresenter [ 

	note := NTNoteObject new
]

{ #category : 'layout' }
NTNotePresenter >> note [

	^ note
]

{ #category : 'layout' }
NTNotePresenter >> note: aNTNoteObject [ 

	note := aNTNoteObject.
	layout := self defaultLayout
]
