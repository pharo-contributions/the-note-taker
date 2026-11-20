"
I am the dialog to rename and remove tags across all the notes of an `NT3Application`: a list of all the tags, each with the number of notes having it, and the buttons Rename… and Remove….

## Life cycle: who creates me and who uses me

1. The user clicks the edit button of the note list: `NT3NoteListPresenter>>#openTagManager` creates me with `instantiate:` on its application and opens me with `openModal`.
2. Rename… and Remove… ask a tag name in a request dialog, then change the notes through the application (`NT3Application>>#renameTagNamed:to:`, `NT3Application>>#removeTagNamed:`), which saves them and tells the note taker window to show them again.
3. When I am closed, `NT3NoteListPresenter>>#openTagManager` refreshes the list.

## Responsibility:

- I list the tags of all the notes, alphabetically ignoring case, with their number of notes.
- Rename… gives the selected tag a new name on all its notes; renaming to an existing tag merges both tags.
- Remove… takes the selected tag off all its notes and, when a tag name is typed, puts that tag instead. A tag name is one word.
- While a name is typed, I suggest the other tags containing it, ignoring case; choosing one puts it in the field, to merge with it.

## Collaborators:

- `NT3Application`: knows the tags and the notes, and renames, removes and saves.
- `SpRequestDialog` (`newRequest`): asks the new name or the replacing tag, with an `EntryCompletion` of the other tags (`entryCompletion:`, the only completion API of Spec text inputs).
- `NT3NoteListPresenter`: opens me.

## Public API and Key Messages

- `NT3TagManagerPresenter newApplication: anNT3Application`, then `openModal`.
- `renameSelectedTag`, `removeSelectedTag`, `labelFor:`.
- `tagList`, `renameButton`, `removeButton`.

## Examples

```
NT3TagManagerPresenter scriptOpen
```

## Internal Representation

- `tagList`: an `SpEasyListViewPresenter` of tag names.
- `renameButton`, `removeButton`: enabled only when a tag is selected.
"
Class {
	#name : 'NT3TagManagerPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'tagList',
		'renameButton',
		'removeButton'
	],
	#category : 'TheNoteTaker-UI3',
	#package : 'TheNoteTaker-UI3'
}

{ #category : 'examples' }
NT3TagManagerPresenter class >> example [
	"The tag manager on the sample notes, kept in memory"

	<sampleInstance>
	^ self newApplication: NT3Application example
]

{ #category : 'examples' }
NT3TagManagerPresenter class >> scriptOpen [
	"Open the tag manager on the sample notes, kept in memory: renaming or removing a tag changes these notes only"

	<example>
	self example open
]

{ #category : 'initialization' }
NT3TagManagerPresenter >> connectPresenters [

	tagList whenSelectionChangedDo: [ self updateButtons ].
	renameButton action: [ self renameSelectedTag ].
	removeButton action: [ self removeSelectedTag ]
]

{ #category : 'layout' }
NT3TagManagerPresenter >> defaultLayout [

	^ SpBoxLayout newTopToBottom
		  spacing: 4;
		  add: tagList;
		  add: (SpBoxLayout newLeftToRight
				   spacing: 4;
				   add: renameButton;
				   add: removeButton;
				   yourself)
		  expand: false;
		  yourself
]

{ #category : 'initialization' }
NT3TagManagerPresenter >> initializeDialogWindow: aDialogWindowPresenter [

	aDialogWindowPresenter addDefaultButton: 'Close' do: [ :dialog | dialog close ]
]

{ #category : 'initialization' }
NT3TagManagerPresenter >> initializePresenters [

	tagList := self newEasyListView
		           display: [ :tagName | self labelFor: tagName ];
		           yourself.
	renameButton := self newButton
		                label: 'Rename…';
		                help: 'Rename the tag on all its notes; an existing name merges both tags';
		                yourself.
	removeButton := self newButton
		                label: 'Remove…';
		                help: 'Remove the tag from all its notes, optionally putting another tag instead';
		                yourself.
	self updateList
]

{ #category : 'initialization' }
NT3TagManagerPresenter >> initializeWindow: aWindowPresenter [

	super initializeWindow: aWindowPresenter.
	aWindowPresenter
		title: 'Tags';
		initialExtent: 300 @ 400
]

{ #category : 'accessing' }
NT3TagManagerPresenter >> labelFor: aTagName [
	"Answer the text of the row of aTagName: the name and how many notes have the tag"

	^ '{1} ({2})' format: {
			  aTagName.
			  (self application notesTagged: aTagName) size }
]

{ #category : 'accessing' }
NT3TagManagerPresenter >> removeButton [

	^ removeButton
]

{ #category : 'actions' }
NT3TagManagerPresenter >> removeSelectedTag [
	"Remove the selected tag from all its notes, putting the tag typed in the dialog instead when there is one"

	| tagName replacement |
	tagName := tagList selectedItem ifNil: [ ^ self ].
	replacement := (self
		                requestTitled: 'Remove tag'
		                message: ('Remove the tag {1}. Tag to put instead (leave empty to only remove it):' format: { tagName })
		                text: ''
		                suggestingAllBut: tagName) ifNil: [ ^ self ].
	replacement
		ifEmpty: [ self application removeTagNamed: tagName ]
		ifNotEmpty: [ self application renameTagNamed: tagName to: replacement ].
	self showTagsSelecting: (NTTag cleanName: replacement)
]

{ #category : 'accessing' }
NT3TagManagerPresenter >> renameButton [

	^ renameButton
]

{ #category : 'actions' }
NT3TagManagerPresenter >> renameSelectedTag [
	"Ask the new name of the selected tag and rename it on all its notes"

	| tagName newName |
	tagName := tagList selectedItem ifNil: [ ^ self ].
	newName := (self
		            requestTitled: 'Rename tag'
		            message: ('New name of the tag {1} (an existing tag merges both):' format: { tagName })
		            text: tagName
		            suggestingAllBut: tagName) ifNil: [ ^ self ].
	self application renameTagNamed: tagName to: newName.
	self showTagsSelecting: (NTTag cleanName: newName)
]

{ #category : 'private' }
NT3TagManagerPresenter >> requestTitled: aTitle message: aMessage text: aString suggestingAllBut: aTagName [
	"Ask for a tag name in a dialog suggesting the other tags matching what is typed. Answer it trimmed, empty when nothing was typed, or nil when cancelled.
	A tag name is one word: tags are separated by spaces when typed"

	| request |
	request := self application newRequest.
	^ request
		  title: aTitle;
		  message: aMessage;
		  text: aString;
		  entryCompletion: (self tagCompletionFor: request suggestingAllBut: aTagName);
		  validateAnswer: [ :answer | answer substrings size <= 1 ];
		  errorText: 'A tag name is one word';
		  openModal
]

{ #category : 'updating' }
NT3TagManagerPresenter >> showTagsSelecting: aTagName [
	"Show the tags again, selecting aTagName when it is listed"

	self updateList.
	(tagList items includes: aTagName) ifTrue: [ tagList selectItem: aTagName ]
]

{ #category : 'private' }
NT3TagManagerPresenter >> tagCompletionFor: aRequest suggestingAllBut: aTagName [
	"Suggest the tags containing the typed text, ignoring case, other than aTagName; a chosen tag replaces the text of aRequest"

	^ EntryCompletion new
		  dataSourceBlock: [ :text | self tagNamesMatching: text suggestingAllBut: aTagName ];
		  filterBlock: [ :tagName :text | true ];
		  chooseBlock: [ :tagName | aRequest text: tagName ];
		  yourself
]

{ #category : 'accessing' }
NT3TagManagerPresenter >> tagList [

	^ tagList
]

{ #category : 'private' }
NT3TagManagerPresenter >> tagNamesMatching: aString suggestingAllBut: aTagName [
	"Answer the listed tags containing aString ignoring case, other than aTagName"

	| typed |
	typed := aString trimBoth asLowercase.
	^ tagList items select: [ :each | each ~= aTagName and: [ each asLowercase includesSubstring: typed ] ]
]

{ #category : 'updating' }
NT3TagManagerPresenter >> updateButtons [

	| hasSelection |
	hasSelection := tagList selectedItem isNotNil.
	renameButton enabled: hasSelection.
	removeButton enabled: hasSelection
]

{ #category : 'updating' }
NT3TagManagerPresenter >> updateList [
	"Show the tags of all the notes, alphabetically ignoring case"

	tagList items: (self application tagNames asArray sort: [ :a :b | a asLowercase <= b asLowercase ]).
	self updateButtons
]
