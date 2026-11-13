"
I am the dialog to add and remove tags of one or several notes: a filter field above the list of all the tags, each with a checkbox icon.

## Responsibility:

- I show each tag with an icon: checked when it will be on all the notes, partly checked when it is on some of them, unchecked otherwise.
- A click on a tag checks or unchecks it; the filter shows the tags containing the typed text; Enter checks the typed tag, creating it when needed.
- My Apply button closes me and runs the `okAction`, Cancel closes me without changing anything.

## Collaborators:

- `NT3TagChoice`: my model, which I change and which knows the tags to add and remove.
- `NT3NoteTakerPresenter` opens me with `openDialog` and applies the choice in the `okAction`.

## Public API and Key Messages

- `NT3TagsPresenter newApplication: anApplication model: aTagChoice`, then `openDialog okAction: [ ... ]`.
- `filterText:`, `submitFilter`, `toggle:`, `iconNameFor:`, `tagList`.

```
NT3TagsPresenter example openDialog
```

## Internal Representation

- `filterInput`: a text input; `tagList`: an `SpEasyListViewPresenter` of tag names, activated on a single click.
"
Class {
	#name : 'NT3TagsPresenter',
	#superclass : 'SpPresenterWithModel',
	#instVars : [
		'filterInput',
		'tagList'
	],
	#category : 'TheNoteTaker-UI3',
	#package : 'TheNoteTaker-UI3'
}

{ #category : 'examples' }
NT3TagsPresenter class >> example [
	"Tags of two sample notes: pharo is on one of them only"

	<sampleInstance>
	| notes |
	notes := NT3Application sampleNotes.
	^ self newApplication: NT3Application new model: (NT3TagChoice
			   notes: ((notes first: 4) allButFirst: 2)
			   tagNames: (notes flatCollect: [ :note | note tags collect: [ :tag | tag tagName ] ]) asSet)
]

{ #category : 'examples' }
NT3TagsPresenter class >> scriptOpen [
	"Open the tags dialog on two sample notes and show the tags to add and remove when Apply is pressed"

	<example>
	| presenter |
	presenter := self example.
	presenter openDialog okAction: [
			self inform: ('Add: {1} - Remove: {2}' format: {
						 (', ' join: presenter model addedTagNames).
						 (', ' join: presenter model removedTagNames) }) ]
]

{ #category : 'initialization' }
NT3TagsPresenter >> connectPresenters [

	filterInput
		whenTextChangedDo: [ self updateList ];
		whenSubmitDo: [ :text | self submitFilter ].
	tagList whenActivatedDo: [ :selection | selection selectedItem ifNotNil: [ :tagName | self toggle: tagName ] ]
]

{ #category : 'layout' }
NT3TagsPresenter >> defaultLayout [

	^ SpBoxLayout newTopToBottom
		  spacing: 4;
		  add: filterInput expand: false;
		  add: tagList;
		  yourself
]

{ #category : 'accessing - presenters' }
NT3TagsPresenter >> filterInput [

	^ filterInput
]

{ #category : 'filtering' }
NT3TagsPresenter >> filterText [

	^ filterInput text
]

{ #category : 'filtering' }
NT3TagsPresenter >> filterText: aString [

	filterInput text: aString.
	self updateList
]

{ #category : 'accessing' }
NT3TagsPresenter >> iconNameFor: aTagName [
	"Answer the name of the icon showing whether the tag will be on all the notes, on some of them, or on none"

	^ {
		  (#all -> #checkedBox).
		  (#some -> #partialCheckedBox).
		  (#none -> #uncheckedBox) } asDictionary at: (self model stateOf: aTagName)
]

{ #category : 'initialization' }
NT3TagsPresenter >> initializeDialogWindow: aDialogWindowPresenter [

	aDialogWindowPresenter
		addButton: 'Cancel' do: [ :dialog |
				dialog
					triggerCancelAction;
					close ];
		addDefaultButton: 'Apply' do: [ :dialog |
			dialog
				beOk;
				triggerOkAction;
				close ]
]

{ #category : 'initialization' }
NT3TagsPresenter >> initializePresenters [

	filterInput := self newTextInput
		               placeholder: 'Filter, or Enter to add a tag';
		               yourself.
	tagList := self newEasyListView
		           activateOnSingleClick;
		           display: [ :tagName | tagName ];
		           displayIcon: [ :tagName | self iconNamed: (self iconNameFor: tagName) ];
		           yourself
]

{ #category : 'initialization' }
NT3TagsPresenter >> initializeWindow: aWindowPresenter [

	| count |
	super initializeWindow: aWindowPresenter.
	count := self model notes size.
	aWindowPresenter
		title: (count = 1
				 ifTrue: [ 'Tags of the note' ]
				 ifFalse: [ 'Tags of {1} notes' format: { count } ]);
		initialExtent: 300 @ 400
]

{ #category : 'initialization' }
NT3TagsPresenter >> modelChanged [

	self updateList
]

{ #category : 'actions' }
NT3TagsPresenter >> submitFilter [
	"Check the typed tag, creating it when no tag has that name, and show all the tags again"

	self filterText trimBoth ifEmpty: [ ^ self ].
	self model addTagNamed: self filterText.
	self filterText: ''
]

{ #category : 'accessing - presenters' }
NT3TagsPresenter >> tagList [

	^ tagList
]

{ #category : 'actions' }
NT3TagsPresenter >> toggle: aTagName [

	self model toggle: aTagName.
	self updateList
]

{ #category : 'updating' }
NT3TagsPresenter >> updateList [
	"Show the tags whose name contains the filter, ignoring case"

	| filter |
	filter := self filterText trimBoth asLowercase.
	tagList items: (self model tagNames select: [ :each | filter isEmpty or: [ each asLowercase includesSubstring: filter ] ])
]
