"
I am the abstract mode of the note list: I turn notes into the rows of the list.

## Responsibility:

- I answer the rows, notes and `NT3ListSeparator`s, for notes and searched tag names.
- I say whether note rows show a detail line.
- I give the icon and tooltip of my mode button.

## Collaborators:

- My subclasses `NT3ByDateListMode`, `NT3ByTagListMode`, `NT3CompactListMode` build the rows.
- `NT3NoteListPresenter` uses me.

## Public API and Key Messages

- `entriesFor: notes searchedTagNames: tagNames`
- `showsDetails`, `iconName`, `help`
- `NT3ListMode modes` answers one instance of each mode, in button order.

```
NT3ByDateListMode new entriesFor: NT3Application sampleNotes searchedTagNames: #()
```
"
Class {
	#name : 'NT3ListMode',
	#superclass : 'Object',
	#category : 'TheNoteTaker-UI3',
	#package : 'TheNoteTaker-UI3'
}

{ #category : 'examples' }
NT3ListMode class >> example [
	"Try example entriesFor: NT3Application sampleNotes searchedTagNames: #()"

	<sampleInstance>
	^ self modes first
]

{ #category : 'accessing' }
NT3ListMode class >> modes [
	"Answer one instance of each mode, in the order of the mode buttons"

	^ {
		  NT3ByDateListMode new.
		  NT3ByTagListMode new.
		  NT3CompactListMode new }
]

{ #category : 'entries' }
NT3ListMode >> entriesFor: aCollectionOfNotes searchedTagNames: aCollectionOfStrings [
	"Answer the rows of the list: notes and `NT3ListSeparator`s, in display order.
	When aCollectionOfStrings is not empty, keep only the notes having one of these tags"

	^ self subclassResponsibility
]

{ #category : 'accessing' }
NT3ListMode >> help [
	"Answer the tooltip of the mode button"

	^ self subclassResponsibility
]

{ #category : 'accessing' }
NT3ListMode >> iconName [
	"Answer the name of the theme icon of the mode button"

	^ self subclassResponsibility
]

{ #category : 'private' }
NT3ListMode >> newestFirst: aCollectionOfNotes [

	^ aCollectionOfNotes asArray sort: [ :a :b | a modificationDate > b modificationDate ]
]

{ #category : 'private' }
NT3ListMode >> notes: aCollectionOfNotes havingAnyTagNamedIn: aCollectionOfStrings [
	"Answer the notes having at least one of the tags; all of them when no tag is given"

	aCollectionOfStrings ifEmpty: [ ^ aCollectionOfNotes ].
	^ aCollectionOfNotes select: [ :note | note tags anySatisfy: [ :tag | aCollectionOfStrings includes: tag tagName ] ]
]

{ #category : 'testing' }
NT3ListMode >> showsDetails [
	"Answer whether a note row shows a second line with its date and the start of its text"

	^ true
]
