"
Implements logic to add a tag to selected note taking application.
"
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
NTSpAddTagCommand >> asSpecCommand [

	^ super asSpecCommand
		  iconName: #add;
		  shortcutKey: $T meta;
		  yourself
]

{ #category : 'executing' }
NTSpAddTagCommand >> execute [
	"execute"

	(NTSpTagSelectionDialog newApplication: self application)
		allowTagCreation;
		title: 'tag name';
		items:
			(self noteTakerContainer tags asOrderedCollection collect: [ :each |
					 each tagName ]);
		display: #asString;
		onAccept: [ :dialog |
				dialog presenter selectedItems do: [ :tagName |
							| tag |
							tag := self noteTakerContainer tagNamed: tagName.
							self selectedNotes do: [ :note |
										tag addNote: note.
										note save.
										self context owner statusBar pushMessage:
												(self application log add: note tag: tag) ] ] ];
		openModalWithParent: context window.

	self context updatePresenter
]
