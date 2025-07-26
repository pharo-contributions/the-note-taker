"
Implements logic to remove a tag to selected note taking application.
"
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

{ #category : 'converting' }
NTSpRemoveTagCommand >> asSpecCommand [

	^ super asSpecCommand
		  iconName: #delete;
		  shortcutKey: $D meta;
		  yourself
]

{ #category : 'executing' }
NTSpRemoveTagCommand >> execute [
	"Request a title to create a new note"

	| tagList |
	tagList := Set new.
	self selectedNotes do: [ :notes | tagList addAll: notes tags ].

	(NTSpTagSelectionDialog newApplication: self application)
		title: 'tag name';
		items: (tagList asArray collect: [ :each | each tagName ]);
		display: #asString;
		onAccept: [ :dialog |
				dialog presenter selectedItems do: [ :tagName | |tag|
					tag := self noteTakerContainer tagNamed: tagName.
							self selectedNotes do: [ :note |
										note removeTag: tag.
										note save.
										self context owner statusBar pushMessage:
												(self application log remove: note tag: tag) ] ] ];
		openModalWithParent: context window.
	self context updatePresenter
]
