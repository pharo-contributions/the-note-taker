"
I am one row of the note list: a separator, or a note with its title and, unless the list is compact, a detail line.

## Responsibility:

- I show a separator label in bold and dimmed.
- I show the display title of a note (dimmed when the note has none, after a bullet when it is unsaved) and its detail line: relative date, first tags when shown, and start of the text.
- I show at most two tags, coloured with the `ntTag` style, then `+N` for the others; hovering `+N` shows all the tags of the note.
- I compute relative dates from `today`.

## Collaborators:

- `NT3NoteListPresenter` creates me through its `SpEasyListViewPresenter` and sets `showsDetails:` and `isUnsavedBlock:`.
- `NT3NotePreview` gives the detail line.

## Public API and Key Messages

- `model:` a note or an `NT3ListSeparator`.
- `showsDetails:`, `showsTags:`, `today:`, `isUnsavedBlock:`.
- `titleText`, `detailText`, `showsDetailLine`, `showsTagLabels`, `shownTagsLabel`, `hiddenTagsLabel`, `isSeparatorRow` (for tests).

```
NT3NoteRowPresenter example open
```

## Internal Representation

- `titleLabel`: a label; `detailLine`: a left-to-right layout of the labels `dateLabel`, `shownTagsLabel`, `hiddenTagsLabel` (its help lists all the tags) and `excerptLabel`, holding only those with something to show. My layout holds the title and, unless compact, the detail line.
- `showsDetails`, `showsTags`: Booleans; `today`: a `Date`; `isUnsavedBlock`: a block answering whether a note is unsaved.
"
Class {
	#name : 'NT3NoteRowPresenter',
	#superclass : 'SpEasyAbstractRowPresenter',
	#instVars : [
		'titleLabel',
		'showsDetails',
		'today',
		'isUnsavedBlock',
		'dateLabel',
		'shownTagsLabel',
		'hiddenTagsLabel',
		'excerptLabel',
		'detailLine',
		'showsTags'
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
	"Answer the text of the detail line as shown, its parts separated by a space"

	^ ' ' join: (detailLine children collect: [ :each | each label ])
]

{ #category : 'accessing - presenters' }
NT3NoteRowPresenter >> hiddenTagsLabel [

	^ hiddenTagsLabel
]

{ #category : 'initialization' }
NT3NoteRowPresenter >> initializePresenters [

	titleLabel := self newLabel.
	dateLabel := self newDetailLabel.
	excerptLabel := self newDetailLabel.
	shownTagsLabel := self newTagLabel.
	hiddenTagsLabel := self newTagLabel.
	detailLine := SpBoxLayout newLeftToRight
		              spacing: 0;
		              yourself.
	showsDetails := true.
	showsTags := false.
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

{ #category : 'initialization' }
NT3NoteRowPresenter >> newDetailLabel [

	^ self newLabel
		  addStyle: 'ntDetail';
		  addStyle: 'dim';
		  yourself
]

{ #category : 'initialization' }
NT3NoteRowPresenter >> newTagLabel [

	^ self newLabel
		  addStyle: 'ntTag';
		  yourself
]

{ #category : 'accessing - presenters' }
NT3NoteRowPresenter >> shownTagsLabel [

	^ shownTagsLabel
]

{ #category : 'testing' }
NT3NoteRowPresenter >> showsDetailLine [

	^ self layout children includes: detailLine
]

{ #category : 'accessing' }
NT3NoteRowPresenter >> showsDetails: aBoolean [
	"Set whether a note row shows the second line (date and start of the text)"

	showsDetails := aBoolean
]

{ #category : 'testing' }
NT3NoteRowPresenter >> showsTagLabels [

	^ self showsDetailLine and: [ detailLine children includes: shownTagsLabel ]
]

{ #category : 'accessing' }
NT3NoteRowPresenter >> showsTags [

	^ showsTags
]

{ #category : 'accessing' }
NT3NoteRowPresenter >> showsTags: aBoolean [
	"Set whether the detail line of a note row shows the first tags of the note"

	showsTags := aBoolean
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
NT3NoteRowPresenter >> updateDetailLine [
	"The detail line holds the relative date, the first tags and the count of the others (whose help lists all the tags), then the start of the text"

	| preview presenters excerpt |
	preview := NT3NotePreview note: self model today: today.
	presenters := OrderedCollection with: dateLabel.
	dateLabel label: preview relativeDate.
	(showsTags and: [ preview shownTagsText isNotEmpty ]) ifTrue: [
			dateLabel label: preview relativeDate , ' ·'.
			shownTagsLabel label: preview shownTagsText.
			presenters add: shownTagsLabel.
			preview hiddenTagsText ifNotEmpty: [ :hidden |
					hiddenTagsLabel
						label: hidden;
						help: preview allTagsText.
					presenters add: hiddenTagsLabel ] ].
	excerpt := preview excerpt.
	excerpt ifNotEmpty: [
			excerptLabel label: '· ' , excerpt.
			presenters add: excerptLabel ].
	detailLine removeAll.
	presenters do: [ :each | detailLine add: each expand: false ]
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
	self updateDetailLine.
	self layout: (self layoutWith: {
				 titleLabel.
				 detailLine })
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
