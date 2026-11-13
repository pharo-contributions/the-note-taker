"
I am one row of the note list: a separator, or a note with its title and, unless the list is compact, a detail line.

## Responsibility:

- I show a separator label in bold and dimmed.
- I show the display title of a note (dimmed when the note has none, after a bullet when it is unsaved) and its detail line: relative date and start of the text.
- I compute relative dates from `today`.

## Collaborators:

- `NT3NoteListPresenter` creates me through its `SpEasyListViewPresenter` and sets `showsDetails:` and `isUnsavedBlock:`.
- `NT3NotePreview` gives the detail line.

## Public API and Key Messages

- `model:` a note or an `NT3ListSeparator`.
- `showsDetails:`, `today:`, `isUnsavedBlock:`.
- `titleText`, `detailText`, `showsDetailLine`, `isSeparatorRow` (for tests).

```
NT3NoteRowPresenter example open
```

## Internal Representation

- `titleLabel`, `detailLabel`: labels; my layout holds one or both.
- `showsDetails`: a Boolean; `today`: a `Date`; `isUnsavedBlock`: a block answering whether a note is unsaved.
"
Class {
	#name : 'NT3NoteRowPresenter',
	#superclass : 'SpEasyAbstractRowPresenter',
	#instVars : [
		'titleLabel',
		'detailLabel',
		'showsDetails',
		'today',
		'isUnsavedBlock'
	],
	#category : 'TheNoteTaker-UI3',
	#package : 'TheNoteTaker-UI3'
}

{ #category : 'examples' }
NT3NoteRowPresenter class >> example [
	"A row showing the first sample note with its detail line"

	<sampleInstance>
	^ self new
		  model: NT3Application sampleNotes first;
		  yourself
]

{ #category : 'layout' }
NT3NoteRowPresenter >> defaultLayout [

	^ self layoutWith: { titleLabel }
]

{ #category : 'accessing' }
NT3NoteRowPresenter >> detailText [

	^ detailLabel label
]

{ #category : 'initialization' }
NT3NoteRowPresenter >> initializePresenters [

	titleLabel := self newLabel.
	detailLabel := self newLabel
		               addStyle: 'ntDetail';
		               addStyle: 'dim';
		               yourself.
	showsDetails := true.
	isUnsavedBlock := [ :note | false ].
	today := Date today
]

{ #category : 'testing' }
NT3NoteRowPresenter >> isSeparatorRow [

	^ self model isNotNil and: [ self model isNote not ]
]

{ #category : 'accessing' }
NT3NoteRowPresenter >> isUnsavedBlock: aBlock [
	"Set the block telling whether a note has unsaved edits; its title then starts with a bullet"

	isUnsavedBlock := aBlock
]

{ #category : 'layout' }
NT3NoteRowPresenter >> layoutWith: aCollectionOfPresenters [

	| box |
	box := SpBoxLayout newTopToBottom
		          borderWidth: 2;
		          yourself.
	aCollectionOfPresenters do: [ :each | box add: each expand: false ].
	^ box
]

{ #category : 'testing' }
NT3NoteRowPresenter >> showsDetailLine [

	^ self layout presenters includes: detailLabel
]

{ #category : 'accessing' }
NT3NoteRowPresenter >> showsDetails: aBoolean [
	"Set whether a note row shows the second line (date and start of the text)"

	showsDetails := aBoolean
]

{ #category : 'accessing' }
NT3NoteRowPresenter >> titleText [

	^ titleLabel label
]

{ #category : 'accessing' }
NT3NoteRowPresenter >> today: aDate [
	"Set the day relative dates are computed from"

	today := aDate
]

{ #category : 'updating' }
NT3NoteRowPresenter >> updateNoteRow [
	"A note row shows its title, dimmed when the note has none and after a bullet when it is unsaved,
	then the detail line unless the list is compact"

	| title |
	title := self model displayTitle.
	titleLabel
		label: ((isUnsavedBlock value: self model)
				 ifTrue: [ '• ' , title ]
				 ifFalse: [ title ]);
		removeStyle: 'ntSeparator'.
	title = 'unnamed'
		ifTrue: [ titleLabel addStyle: 'dim' ]
		ifFalse: [ titleLabel removeStyle: 'dim' ].
	showsDetails ifFalse: [ ^ self layout: (self layoutWith: { titleLabel }) ].
	detailLabel label: (NT3NotePreview note: self model today: today) detailLine.
	self layout: (self layoutWith: {
				 titleLabel.
				 detailLabel })
]

{ #category : 'initialization' }
NT3NoteRowPresenter >> updatePresenter [

	self model ifNil: [ ^ self ].
	self model isNote
		ifTrue: [ self updateNoteRow ]
		ifFalse: [ self updateSeparatorRow ]
]

{ #category : 'private' }
NT3NoteRowPresenter >> updateSeparatorRow [
	"A separator is a group header: bold and dimmed so that it stands apart from the note titles"

	titleLabel
		label: self model label;
		addStyle: 'ntSeparator';
		addStyle: 'dim'.
	self layout: (self layoutWith: { titleLabel })
]
