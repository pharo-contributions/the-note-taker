"
I list only the note titles, newest first, without separators, to show many notes.

## Responsibility:

- I sort the notes by modification date.
- I keep only the notes having one of the searched tags.
- I hide the detail line of the rows.

## Collaborators:

- `NT3ListMode`, my superclass.

## Public API and Key Messages

- `entriesFor:searchedTagNames:`, `showsDetails`

```
NT3CompactListMode new entriesFor: NT3Application sampleNotes searchedTagNames: #('pharo')
```
"
Class {
	#name : 'NT3CompactListMode',
	#superclass : 'NT3ListMode',
	#category : 'TheNoteTaker-UI3',
	#package : 'TheNoteTaker-UI3'
}

{ #category : 'entries' }
NT3CompactListMode >> entriesFor: aCollectionOfNotes searchedTagNames: aCollectionOfStrings [

	^ self newestFirst: (self notes: aCollectionOfNotes havingAnyTagNamedIn: aCollectionOfStrings)
]

{ #category : 'accessing' }
NT3CompactListMode >> help [

	^ 'Titles only'
]

{ #category : 'accessing' }
NT3CompactListMode >> iconName [

	^ #smallJustified
]

{ #category : 'testing' }
NT3CompactListMode >> showsDetails [

	^ false
]
