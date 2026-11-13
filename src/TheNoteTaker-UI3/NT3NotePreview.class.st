"
I compute the texts describing a note: the detail line in the list and the information line of the editor.

## Responsibility:

- I give the modification date relative to today, without time: today, yesterday, 3 days ago, then Thu 5.
- I give the start of the text after the title line, without Markdown markup, on one line, cut with an ellipsis.
- I join both into the detail line, and give the information line: unsaved bullet, tags, modification date and time, creation date.

## Collaborators:

- `NTNote`: its contents and modification date.
- `NT3NoteRowPresenter` and `NT3NoteEditorPresenter` use me.

## Public API and Key Messages

- `NT3NotePreview note: aNote today: aDate`
- `relativeDate`, `excerpt`, `detailLine`, `infoLineUnsaved:`

```
(NT3NotePreview note: NT3Application sampleNotes first today: Date today) detailLine
```

## Internal Representation

- `note`: an `NTNote`; `today`: a `Date`.
"
Class {
	#name : 'NT3NotePreview',
	#superclass : 'Object',
	#instVars : [
		'note',
		'today'
	],
	#category : 'TheNoteTaker-UI3',
	#package : 'TheNoteTaker-UI3'
}

{ #category : 'examples' }
NT3NotePreview class >> example [
	"Try example detailLine"

	<sampleInstance>
	^ self note: NT3Application sampleNotes first today: Date today
]

{ #category : 'accessing' }
NT3NotePreview class >> maximumExcerptSize [
	"Number of characters of the excerpt, ellipsis included"

	^ 80
]

{ #category : 'instance creation' }
NT3NotePreview class >> note: aNote today: aDate [

	^ self new
		  note: aNote;
		  today: aDate;
		  yourself
]

{ #category : 'private' }
NT3NotePreview >> dayMonthYearOf: aDateAndTime [

	^ String streamContents: [ :stream |
		  stream
			  print: aDateAndTime dayOfMonth;
			  space;
			  nextPutAll: (aDateAndTime monthName first: 3);
			  space;
			  print: aDateAndTime year ]
]

{ #category : 'texts' }
NT3NotePreview >> detailLine [
	"Answer the second line of a note row: the relative date, then the excerpt when there is one"

	| excerpt |
	excerpt := self excerpt.
	excerpt ifEmpty: [ ^ self relativeDate ].
	^ String streamContents: [ :stream |
			  stream
				  nextPutAll: self relativeDate;
				  nextPutAll: ' · ';
				  nextPutAll: excerpt ]
]

{ #category : 'texts' }
NT3NotePreview >> excerpt [
	"Answer the start of the note text after its title line, as plain text on one line,
	cut with an ellipsis when longer than the maximum excerpt size"

	| lines text maximum |
	lines := note contents lines asOrderedCollection.
	[ lines isNotEmpty and: [ lines first isAllSeparators ] ] whileTrue: [ lines removeFirst ].
	lines ifNotEmpty: [ lines removeFirst ].
	text := ' ' join: ((lines collect: [ :each | self plainTextOf: each ]) reject: [ :each | each isEmpty ]).
	maximum := self class maximumExcerptSize.
	text size > maximum ifFalse: [ ^ text ].
	^ String streamContents: [ :stream |
			  stream
				  nextPutAll: (text first: maximum - 1);
				  nextPut: $… ]
]

{ #category : 'private' }
NT3NotePreview >> hoursAndMinutesOf: aDateAndTime [

	^ String streamContents: [ :stream |
		  stream
			  nextPutAll: (aDateAndTime hour printPaddedWith: $0 to: 2);
			  nextPut: $:;
			  nextPutAll: (aDateAndTime minute printPaddedWith: $0 to: 2) ]
]

{ #category : 'accessing' }
NT3NotePreview >> infoLineUnsaved: isUnsaved [
	"Answer the line shown above the editor: a bullet when the note is unsaved, its tags,
	when it was modified (relative date and time) and when it was created"

	| tagNames |
	tagNames := (note tags collect: [ :each | each tagName ] as: Array) sort: [ :a :b | a asLowercase <= b asLowercase ].
	^ String streamContents: [ :stream |
		  isUnsaved ifTrue: [ stream nextPutAll: '• ' ].
		  tagNames do: [ :each | stream nextPut: $#; nextPutAll: each ] separatedBy: [ stream space ].
		  tagNames ifNotEmpty: [ stream nextPutAll: ' · ' ].
		  stream
			  nextPutAll: 'modified ';
			  nextPutAll: self relativeDate;
			  space;
			  nextPutAll: (self hoursAndMinutesOf: note modificationDate);
			  nextPutAll: ' · created ';
			  nextPutAll: (self dayMonthYearOf: note creationDate) ]
]

{ #category : 'private' }
NT3NotePreview >> isInnerCharacterAt: anIndex of: aString [
	"Answer whether the character at anIndex is between two letters or digits"

	anIndex = 1 ifTrue: [ ^ false ].
	anIndex = aString size ifTrue: [ ^ false ].
	^ (aString at: anIndex - 1) isAlphaNumeric and: [ (aString at: anIndex + 1) isAlphaNumeric ]
]

{ #category : 'accessing' }
NT3NotePreview >> note [

	^ note
]

{ #category : 'accessing' }
NT3NotePreview >> note: aNote [

	note := aNote
]

{ #category : 'private' }
NT3NotePreview >> plainTextOf: aLine [
	"Answer aLine without its Markdown markup: block markers (headings, quotes, list bullets),
	emphasis and code marks, and links reduced to their text"

	| line |
	line := aLine trimBoth.
	[ line isNotEmpty and: [ '#>-+*' includes: line first ] ] whileTrue: [ line := line allButFirst trimLeft ].
	line := line
		        copyWithRegex: '!?\[[^]]*\]\([^)]*\)'
		        matchesTranslatedUsing: [ :link | link copyFrom: (link indexOf: $[) + 1 to: (link indexOf: $]) - 1 ].
	line := self withoutEmphasisUnderscores: (line reject: [ :each | '*`~' includes: each ]).
	^ ' ' join: line substrings
]

{ #category : 'texts' }
NT3NotePreview >> relativeDate [
	"Answer when the note was last modified, relative to today, without time:
	'today', 'yesterday', '3 days ago', then for example 'Thu 5' after a week"

	| date days |
	date := note modificationDate asDate.
	days := today subtractDate: date.
	days < 1 ifTrue: [ ^ 'today' ].
	days = 1 ifTrue: [ ^ 'yesterday' ].
	^ String streamContents: [ :stream |
			  days < 7
				  ifTrue: [
						  stream
							  print: days;
							  nextPutAll: ' days ago' ]
				  ifFalse: [
						  stream
							  nextPutAll: (date dayOfWeekName first: 3);
							  space;
							  print: date dayOfMonth ] ]
]

{ #category : 'accessing' }
NT3NotePreview >> today [

	^ today
]

{ #category : 'accessing' }
NT3NotePreview >> today: aDate [

	today := aDate
]

{ #category : 'private' }
NT3NotePreview >> withoutEmphasisUnderscores: aString [
	"Remove the underscores used for emphasis: the ones not between two letters or digits (snake_case keeps its own)"

	^ String streamContents: [ :stream |
			  aString doWithIndex: [ :each :index |
				  (each = $_ and: [ (self isInnerCharacterAt: index of: aString) not ]) ifFalse: [ stream nextPut: each ] ] ]
]
