Class {
	#name : 'NTNotePresenter',
	#superclass : 'SpPresenterWithModel',
	#category : 'TheNoteTaker-UI',
	#package : 'TheNoteTaker-UI'
}

{ #category : 'layout' }
NTNotePresenter >> defaultLayout [

	^ SpBoxLayout newTopToBottom
		  add: self note title;
		  add: self note creationDate asDate asString;
		  add: self displayNoteTags;
		  yourself
]

{ #category : 'layout' }
NTNotePresenter >> displayNoteTags [
	"Answer a <String> to be displayed"

	| orderedTags |
	self note tags ifEmpty: [ ^ '' ].
	
	orderedTags := self note tags asOrderedCollection sorted: [:a :b | a tagName < b tagName].
	^ (orderedTags collect: [ :each | each tagName ]) asArray joinUsing: ','
]

{ #category : 'layout' }
NTNotePresenter >> initializePresenter [ 

	self note: NTNoteObject new
]

{ #category : 'layout' }
NTNotePresenter >> modelChanged [

	layout := self defaultLayout
]

{ #category : 'layout' }
NTNotePresenter >> note [

	^ self model
]

{ #category : 'layout' }
NTNotePresenter >> note: aNTNoteObject [ 

	self setModel: aNTNoteObject.
]
