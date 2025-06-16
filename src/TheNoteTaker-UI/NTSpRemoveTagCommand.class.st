Class {
	#name : 'NTSpRemoveTagCommand',
	#superclass : 'NTSpAbstractCommand',
	#category : 'TheNoteTaker-UI-Commands',
	#package : 'TheNoteTaker-UI',
	#tag : 'Commands'
}

{ #category : 'default' }
NTSpRemoveTagCommand class >> defaultDescription [

	^ 'Remove a tag to a note'
]

{ #category : 'default' }
NTSpRemoveTagCommand class >> defaultName [

	^ 'Remove Tag'
]

{ #category : 'executing' }
NTSpRemoveTagCommand >> execute [
	"Request a title to create a new note"

	| answer tag |
	answer := self application newRequest
		          title: 'tag name';
		          label: 'Please provide the name of the tag';
		          openModalWithParent: context window.

	tag := self facade tagNamed: answer.

	self selectedNotes do: [ :note | note removeTag: tag ]
]
