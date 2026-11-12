"
I interpret the text of the tag search bar.

## Responsibility:

- I answer the searched tag names: the complete words, i.e. every word followed by a separator, and the last word when it is exactly an existing tag name.
- I answer the completions of the word being typed.
- I replace the word being typed by a chosen tag name.

## Collaborators:

- `NT3NoteListPresenter` creates me from its search text and the tag names of its notes.

## Public API and Key Messages

- `NT3TagQuery text: aString existingTagNames: aCollection`
- `searchedTagNames`, `isActive`
- `completions`, `textCompletedWith:`

```
(NT3TagQuery text: 'pharo spe' existingTagNames: #('pharo' 'spec')) completions ""#('spec')""
```

## Internal Representation

- `text`: the search text; `existingTagNames`: the tag names that exist.
"
Class {
	#name : 'NT3TagQuery',
	#superclass : 'Object',
	#instVars : [
		'text',
		'existingTagNames'
	],
	#category : 'TheNoteTaker-UI3',
	#package : 'TheNoteTaker-UI3'
}

{ #category : 'examples' }
NT3TagQuery class >> example [
	"Try example searchedTagNames (#('pharo')) and example completions (#('spec' 'spectacle'))"

	<sampleInstance>
	^ self text: 'pharo spe' existingTagNames: #( 'pharo' 'spec' 'spectacle' )
]

{ #category : 'instance creation' }
NT3TagQuery class >> text: aString existingTagNames: aCollection [

	^ self new
		  text: aString;
		  existingTagNames: aCollection;
		  yourself
]

{ #category : 'completion' }
NT3TagQuery >> completions [
	"Answer the existing tag names starting with the word being typed, except the ones already searched"

	| prefix searched |
	prefix := self lastWord.
	searched := self searchedTagNames.
	^ existingTagNames select: [ :each | (each beginsWith: prefix) and: [ (searched includes: each) not ] ]
]

{ #category : 'accessing' }
NT3TagQuery >> existingTagNames: aCollection [

	existingTagNames := aCollection
]

{ #category : 'testing' }
NT3TagQuery >> isActive [
	"Answer whether the query filters the notes"

	^ self searchedTagNames isNotEmpty
]

{ #category : 'completion' }
NT3TagQuery >> lastWord [
	"Answer the word being typed: empty when the text is empty or ends with a separator"

	(text isEmpty or: [ text last isSeparator ]) ifTrue: [ ^ '' ].
	^ text substrings last
]

{ #category : 'accessing' }
NT3TagQuery >> searchedTagNames [
	"Answer the complete words of the text: every word followed by a separator,
	and the last word when it is exactly an existing tag name. An unfinished last word is ignored"

	| words |
	words := text substrings.
	words ifEmpty: [ ^ #(  ) ].
	^ (text last isSeparator or: [ existingTagNames includes: words last ])
		  ifTrue: [ words ]
		  ifFalse: [ words allButLast ]
]

{ #category : 'accessing' }
NT3TagQuery >> text: aString [

	text := aString
]

{ #category : 'completion' }
NT3TagQuery >> textCompletedWith: aTagName [
	"Answer the text where the word being typed is replaced by aTagName followed by a space"

	^ String streamContents: [ :stream |
			  stream
				  nextPutAll: (text first: text size - self lastWord size);
				  nextPutAll: aTagName;
				  space ]
]
