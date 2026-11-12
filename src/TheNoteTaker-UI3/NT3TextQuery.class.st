"
I am the text search of the note taker: words that a note must all contain, ignoring case.

## Responsibility:

- I split the search text into lowercase words, without duplicates.
- I tell whether a note (its title and contents) contains all my words.
- I give the ranges of a text where my words occur, for highlighting.

## Collaborators:

- `NTNote`: I search its `contents` (the title is the first line).
- `NT3NoteTakerPresenter` filters the list with me; `NT3NoteEditorPresenter` highlights my ranges.

## Public API and Key Messages

- `NT3TextQuery text: aString`
- `words`, `isActive`, `matches: aNote`, `rangesIn: aString`

```
(NT3TextQuery text: 'list spec') rangesIn: 'Spec: the list view'
```

## Internal Representation

- `text`: the search text; `words`: an `Array` of lowercase strings.
"
Class {
	#name : 'NT3TextQuery',
	#superclass : 'Object',
	#instVars : [
		'text',
		'words'
	],
	#category : 'TheNoteTaker-UI3',
	#package : 'TheNoteTaker-UI3'
}

{ #category : 'examples' }
NT3TextQuery class >> example [
	"A query finding the notes containing both words"

	<sampleInstance>
	^ self text: 'spec list'
]

{ #category : 'instance creation' }
NT3TextQuery class >> text: aString [

	^ self new
		  setText: aString;
		  yourself
]

{ #category : 'testing' }
NT3TextQuery >> isActive [

	^ words isNotEmpty
]

{ #category : 'testing' }
NT3TextQuery >> matches: aNote [
	"Answer whether the title or the contents of aNote contain all the words, ignoring case"

	| contents |
	contents := aNote contents asLowercase.
	^ words allSatisfy: [ :each | contents includesSubstring: each ]
]

{ #category : 'private' }
NT3TextQuery >> merged: aSortedCollectionOfIntervals [

	| merged |
	merged := OrderedCollection new.
	aSortedCollectionOfIntervals do: [ :each |
		(merged isNotEmpty and: [ each first <= (merged last last + 1) ])
			ifTrue: [ merged at: merged size put: (merged last first to: (merged last last max: each last)) ]
			ifFalse: [ merged add: each ] ].
	^ merged asArray
]

{ #category : 'matching' }
NT3TextQuery >> rangesIn: aString [
	"Answer the intervals of aString where the words occur, ignoring case, sorted and merged when they overlap"

	| lowercase ranges |
	lowercase := aString asLowercase.
	ranges := OrderedCollection new.
	words do: [ :word |
		| start |
		start := lowercase findString: word startingAt: 1.
		[ start > 0 ] whileTrue: [
			ranges add: (start to: start + word size - 1).
			start := lowercase findString: word startingAt: start + 1 ] ].
	^ self merged: (ranges asArray sort: [ :a :b | a first <= b first ])
]

{ #category : 'initialization' }
NT3TextQuery >> setText: aString [

	text := aString.
	words := (aString substrings collect: [ :each | each asLowercase ] as: OrderedCollection) removeDuplicates asArray
]

{ #category : 'accessing' }
NT3TextQuery >> text [

	^ text
]

{ #category : 'accessing' }
NT3TextQuery >> words [
	"Answer the lowercase words searched, without duplicates, in the order typed"

	^ words
]
