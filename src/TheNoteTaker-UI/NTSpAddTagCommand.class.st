Class {
	#name : 'NTSpAddTagCommand',
	#superclass : 'NTSpAbstractCommand',
	#category : 'TheNoteTaker-UI-Commands',
	#package : 'TheNoteTaker-UI',
	#tag : 'Commands'
}

{ #category : 'default' }
NTSpAddTagCommand class >> defaultDescription [

	^ 'Add a tag to a note'
]

{ #category : 'default' }
NTSpAddTagCommand class >> defaultName [

	^ 'Add Tag'
]

{ #category : 'executing' }
NTSpAddTagCommand >> execute [
	"Request a title to create a new note"

	| answer tag |
	answer := self application newRequest
		          title: 'tag name';
		          label: 'Please provide the name of the tag';
		          openModalWithParent: context window.
	
	tag := self facade tagNamed: answer.

	self selectedNotes do: [ :note | tag addNote: note ]
]
