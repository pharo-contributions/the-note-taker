"
I list the notes newest first, under a separator per month, e.g. November 2026.

## Responsibility:

- I sort by modification date and add a separator when the month changes.
- I keep only the notes having one of the searched tags.

## Collaborators:

- `NT3ListMode`, my superclass; `NT3ListSeparator`.

## Public API and Key Messages

- `entriesFor:searchedTagNames:`

```
NT3ByDateListMode new entriesFor: NT3Application sampleNotes searchedTagNames: #()
```
"
Class {
	#name : 'NT3ByDateListMode',
	#superclass : 'NT3ListMode',
	#category : 'TheNoteTaker-UI3',
	#package : 'TheNoteTaker-UI3'
}

{ #category : 'entries' }
NT3ByDateListMode >> entriesFor: aCollectionOfNotes searchedTagNames: aCollectionOfStrings [

	| notes |
	notes := self newestFirst: (self notes: aCollectionOfNotes havingAnyTagNamedIn: aCollectionOfStrings).
	^ Array streamContents: [ :stream |
			  notes doWithIndex: [ :note :index |
					  (index = 1 or: [ (notes at: index - 1) modificationDate asDate month ~= note modificationDate asDate month ]) ifTrue: [
						  stream nextPut: (NT3ListSeparator label: (self labelOfMonth: note modificationDate asDate month)) ].
					  stream nextPut: note ] ]
]

{ #category : 'accessing' }
NT3ByDateListMode >> help [

	^ 'By date'
]

{ #category : 'accessing' }
NT3ByDateListMode >> iconName [

	^ #calendar
]

{ #category : 'private' }
NT3ByDateListMode >> labelOfMonth: aMonth [
	"For example 'November 2026'"

	^ String streamContents: [ :stream |
			  stream
				  nextPutAll: aMonth name;
				  space;
				  print: aMonth year ]
]
