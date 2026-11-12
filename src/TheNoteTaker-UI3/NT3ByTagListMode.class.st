"
I list the notes in one group per tag, tags alphabetically ignoring case; a note appears under each of its tags.

## Responsibility:

- I add a separator #tag and the notes of that tag, newest first.
- Without search, I end with the notes without tag under ""No tag"".
- With a search, I keep only the groups of the searched tags.

## Collaborators:

- `NT3ListMode`, my superclass; `NT3ListSeparator`.

## Public API and Key Messages

- `entriesFor:searchedTagNames:`

```
NT3ByTagListMode new entriesFor: NT3Application sampleNotes searchedTagNames: #()
```
"
Class {
	#name : 'NT3ByTagListMode',
	#superclass : 'NT3ListMode',
	#category : 'TheNoteTaker-UI3',
	#package : 'TheNoteTaker-UI3'
}

{ #category : 'private' }
NT3ByTagListMode >> addGroup: aLabel notes: aCollectionOfNotes to: entries [

	aCollectionOfNotes ifEmpty: [ ^ self ].
	entries add: (NT3ListSeparator label: aLabel).
	entries addAll: (self newestFirst: aCollectionOfNotes)
]

{ #category : 'entries' }
NT3ByTagListMode >> entriesFor: aCollectionOfNotes searchedTagNames: aCollectionOfStrings [
	"One group per tag, alphabetically ignoring case; a note appears under each of its tags.
	Without search, the notes without tag come last under 'No tag'"

	| entries tagNames |
	entries := OrderedCollection new.
	tagNames := (aCollectionOfNotes flatCollect: [ :note | note tags collect: [ :tag | tag tagName ] ]) asSet.
	aCollectionOfStrings ifNotEmpty: [ tagNames := tagNames select: [ :each | aCollectionOfStrings includes: each ] ].
	(tagNames asArray sort: [ :a :b | a asLowercase <= b asLowercase ]) do: [ :tagName |
			self
				addGroup: (self labelOfTagNamed: tagName)
				notes: (aCollectionOfNotes select: [ :note | note tags anySatisfy: [ :tag | tag tagName = tagName ] ])
				to: entries ].
	aCollectionOfStrings ifEmpty: [
		self addGroup: 'No tag' notes: (aCollectionOfNotes select: [ :note | note tags isEmpty ]) to: entries ].
	^ entries asArray
]

{ #category : 'accessing' }
NT3ByTagListMode >> help [

	^ 'By tag'
]

{ #category : 'accessing' }
NT3ByTagListMode >> iconName [

	^ #bookmark
]

{ #category : 'private' }
NT3ByTagListMode >> labelOfTagNamed: aString [
	"For example '#pharo'"

	^ String streamContents: [ :stream |
			  stream
				  nextPut: $#;
				  nextPutAll: aString ]
]
