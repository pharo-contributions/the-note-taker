"
I show the tags of a note and let the user add tags (with completion) and remove them.
"
Class {
	#name : 'NT2TagFieldPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'note',
		'tagInput',
		'tagList',
		'removeButton',
		'changedBlock'
	],
	#category : 'TheNoteTaker-UI2',
	#package : 'TheNoteTaker-UI2'
}

{ #category : 'actions' }
NT2TagFieldPresenter >> addTagNamed: aString [
	"Commas separate tags in the note metadata, so they cannot be part of a tag name"

	| name |
	name := (aString copyWithout: $,) trimBoth.
	(note isNil or: [ name isEmpty ]) ifTrue: [ ^ self ].
	self application addTagNamed: name to: note.
	tagInput text: ''.
	self refresh.
	changedBlock ifNotNil: [ changedBlock value ]
]

{ #category : 'initialization' }
NT2TagFieldPresenter >> connectPresenters [

	tagInput whenSubmitDo: [ :text | self addTagNamed: text asString ]
]

{ #category : 'layout' }
NT2TagFieldPresenter >> defaultLayout [

	^ SpBoxLayout newTopToBottom
		  spacing: 4;
		  add: (SpBoxLayout newLeftToRight
				   spacing: 4;
				   add: tagInput;
				   add: removeButton expand: false;
				   yourself)
		  expand: false;
		  add: tagList height: 60;
		  yourself
]

{ #category : 'initialization' }
NT2TagFieldPresenter >> initializePresenters [

	tagInput := self newTextInput
		            placeholder: 'Add a tag and press Enter';
		            entryCompletion: self tagCompletion;
		            yourself.
	tagList := self newList
		           display: [ :tag | tag tagName ];
		           yourself.
	removeButton := self newButton
		                label: 'Remove tag';
		                action: [ tagList selectedItem ifNotNil: [ :tag | self removeTag: tag ] ];
		                yourself
]

{ #category : 'accessing' }
NT2TagFieldPresenter >> note: aNTNote [

	note := aNTNote.
	self refresh
]

{ #category : 'refreshing' }
NT2TagFieldPresenter >> refresh [

	tagList items: (note ifNil: [ #(  ) ] ifNotNil: [ note tags asArray sort: [ :a :b | a tagName < b tagName ] ])
]

{ #category : 'actions' }
NT2TagFieldPresenter >> removeTag: aNTTag [

	note ifNil: [ ^ self ].
	self application removeTag: aNTTag from: note.
	self refresh.
	changedBlock ifNotNil: [ changedBlock value ]
]

{ #category : 'initialization' }
NT2TagFieldPresenter >> tagCompletion [

	^ EntryCompletion new
		  dataSourceBlock: [ :text | (self application container tags collect: [ :tag | tag tagName ]) asSortedCollection asArray ];
		  filterBlock: [ :each :text | each beginsWith: text caseSensitive: false ];
		  yourself
]

{ #category : 'events' }
NT2TagFieldPresenter >> whenTagsChangedDo: aBlock [

	changedBlock := aBlock
]
