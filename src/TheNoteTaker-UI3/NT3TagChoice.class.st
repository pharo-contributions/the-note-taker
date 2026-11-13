"
I am the choice of tags made for several notes at once in the tags dialog: for each tag, whether it will be on all the notes, on none of them, or left as it is on each one.

## Responsibility:

- I know the notes and, for each offered tag, its state: `#all` (on every note), `#none` (on no note) or `#some` (on some notes only, left untouched).
- I toggle a tag between checked and unchecked, and add a typed tag (checked), reusing an existing tag that has the same name ignoring case.
- I answer the tags to add to every note and the tags to remove from every note: only the tags whose state changed.

## Collaborators:

- `NTNote` and `NTTag`: I read the tags of the notes, I never change them.
- `NT3TagsPresenter` shows and changes me; `NT3Application>>#tagNotes:adding:removing:` applies me.

## Public API and Key Messages

- `NT3TagChoice notes: notes tagNames: tagNames` (the tags of the notes are offered too).
- `tagNames`, `stateOf:`, `toggle:`, `addTagNamed:`.
- `addedTagNames`, `removedTagNames`, `notes`.

```
| choice |
choice := NT3TagChoice notes: (NT3Application sampleNotes first: 2) tagNames: #( 'todo' ).
choice toggle: 'todo'.
choice addedTagNames. ""#('todo')""
```

## Internal Representation

- `notes`: an `Array` of `NTNote`.
- `initialStates`, `states`: `Dictionary`s from tag name to `#all`, `#some` or `#none`, when created and now.

### Implementation Points

Toggling a `#some` tag checks it: like a mixed checkbox, it never goes back to `#some`.
"
Class {
	#name : 'NT3TagChoice',
	#superclass : 'Object',
	#instVars : [
		'notes',
		'initialStates',
		'states'
	],
	#category : 'TheNoteTaker-UI3',
	#package : 'TheNoteTaker-UI3'
}

{ #category : 'examples' }
NT3TagChoice class >> example [
	"A choice for the first two sample notes where todo is checked: it will be added to both"

	<sampleInstance>
	^ (self notes: (NT3Application sampleNotes first: 2) tagNames: #( 'todo' ))
		  toggle: 'todo';
		  yourself
]

{ #category : 'instance creation' }
NT3TagChoice class >> notes: aCollectionOfNotes tagNames: aCollectionOfStrings [
	"Answer a choice of tags for the notes, offering the tags named in aCollectionOfStrings and the tags of the notes"

	^ self new
		  setNotes: aCollectionOfNotes tagNames: aCollectionOfStrings;
		  yourself
]

{ #category : 'choosing' }
NT3TagChoice >> addTagNamed: aString [
	"Check the tag named aString, offering it when it is new. Commas separate tags in the note files, so they are dropped"

	| name |
	name := (aString copyWithout: $,) trimBoth.
	name ifEmpty: [ ^ self ].
	name := states keys detect: [ :each | each asLowercase = name asLowercase ] ifNone: [ name ].
	states at: name put: #all
]

{ #category : 'result' }
NT3TagChoice >> addedTagNames [
	"Answer the names of the tags to add to every note, alphabetically ignoring case"

	^ self tagNames select: [ :each | (states at: each) = #all and: [ (initialStates at: each ifAbsent: [ #none ]) ~= #all ] ]
]

{ #category : 'private' }
NT3TagChoice >> initialStateOf: aTagName [
	"Answer #all when every note has the tag, #none when no note has it, #some otherwise"

	| count |
	count := notes count: [ :note | note tags anySatisfy: [ :tag | tag tagName = aTagName ] ].
	count = 0 ifTrue: [ ^ #none ].
	count = notes size ifTrue: [ ^ #all ].
	^ #some
]

{ #category : 'accessing' }
NT3TagChoice >> notes [

	^ notes
]

{ #category : 'result' }
NT3TagChoice >> removedTagNames [
	"Answer the names of the tags to remove from every note, alphabetically ignoring case"

	^ self tagNames select: [ :each | (states at: each) = #none and: [ (initialStates at: each ifAbsent: [ #none ]) ~= #none ] ]
]

{ #category : 'initialization' }
NT3TagChoice >> setNotes: aCollectionOfNotes tagNames: aCollectionOfStrings [

	notes := aCollectionOfNotes asArray.
	initialStates := Dictionary new.
	aCollectionOfStrings , (notes flatCollect: [ :note | note tags collect: [ :tag | tag tagName ] ]) do: [ :each |
		initialStates at: each put: (self initialStateOf: each) ].
	states := initialStates copy
]

{ #category : 'accessing' }
NT3TagChoice >> stateOf: aTagName [
	"Answer #all when the tag will be on every note, #none when on no note, #some when kept as it is on each note"

	^ states at: aTagName
]

{ #category : 'accessing' }
NT3TagChoice >> tagNames [
	"Answer the names of the offered tags, alphabetically ignoring case"

	^ states keys sort: [ :a :b | a asLowercase <= b asLowercase ]
]

{ #category : 'choosing' }
NT3TagChoice >> toggle: aTagName [
	"Check a tag that is not on every note, uncheck a tag that is"

	states at: aTagName put: ((states at: aTagName) = #all
			 ifTrue: [ #none ]
			 ifFalse: [ #all ])
]
