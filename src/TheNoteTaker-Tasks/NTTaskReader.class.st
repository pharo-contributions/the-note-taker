"
I read the text of a task file and answer an `NTTask`.

The format is a metadata block followed by checkbox lines:

```
{
  ""title"" : ""Pharo 14 release"",
  ""section"" : ""Pharo"",
  ""status"" : ""open""
}

- [x] Freeze API @done(2026-11-02)
- [ ] Write release notes @due(2026-11-15) #release
  Mention the new compiler.
```

## Responsibility:

- I parse the optional metadata block (JSON) into the task fields, keeping unknown entries.
- I parse each item line: done state, title, `@key(value)`, `@key` and `#tag` annotations, and the indented description lines below it.
- I signal an `NTTaskParseError` naming the line when a non-blank line is neither metadata, an item nor a description.

## Collaborators: 

- `NTTask`, `NTTaskItem`, `NTItemKey`, `NTItemTag`: what I build.
- `NTTaskWriter`: writes back what I read; together we guarantee round trips.
- `STONJSON`: parses the metadata block.

## Public API and Key Messages

- `NTTaskReader read: aString` answers an `NTTask`.
- `NTTaskReader new readItemLine: aString` answers an `NTTaskItem` (used by editors).

```
NTTaskReader read: '- [ ] Call Bob @due(2026-11-12) #admin'
```

See `NTTaskReader class >> #exampleReader`.

## Internal Representation

- `lines`: the lines of the text, `index`: the current line, `task`: the task being built.

### Implementation Points

- Annotations start at a word beginning with `@` or `#`; words between annotations that are not annotations are appended to the title.
- This reader will be replaced by a Microdown visitor once Microdown understands `[x]` and `@key(...)`; `NTTaskWriter` round-trip tests are the contract.
- After reading, the task status is updated from the items (items win over a stale status, except `#abandoned`).
"
Class {
	#name : 'NTTaskReader',
	#superclass : 'Object',
	#instVars : [
		'lines',
		'index',
		'task'
	],
	#category : 'TheNoteTaker-Tasks-Format',
	#package : 'TheNoteTaker-Tasks',
	#tag : 'Format'
}

{ #category : 'reading' }
NTTaskReader class >> dateFromIso: aString [
	"Answer the Date written as yyyy-mm-dd in aString, or nil when aString is not such a date."

	| parts |
	(aString isString and: [ aString matchesRegex: '\d\d\d\d-\d\d-\d\d' ]) ifFalse: [ ^ nil ].
	parts := (aString substrings: '-') collect: [ :each | each asNumber ].
	^ [ Date year: parts first month: parts second day: parts third ]
		  on: Error
		  do: [ nil ]
]

{ #category : 'examples' }
NTTaskReader class >> exampleReader [

	<sampleInstance>
	^ self new
]

{ #category : 'reading' }
NTTaskReader class >> read: aString [

	^ self new read: aString
]

{ #category : 'script' }
NTTaskReader class >> scriptReadTask [
	"Read a small task file and inspect the resulting task, its items and their annotations."

	<script>
	(self read: '{
  "title" : "Pharo 14 release",
  "section" : "Pharo"
}

- [x] Freeze API @done(2026-11-02)
- [ ] Write release notes @due(2026-11-15) @prio(high) #release
  Mention the new compiler.
- [ ] Sign-off @waitingOthers(Marcus)
') inspect
]

{ #category : 'private - items' }
NTTaskReader >> addDescriptionLine: aLine to: anItem [
	"Descriptions are indented by two spaces in the file; the indentation is not part of the description."

	| text |
	text := (aLine beginsWith: '  ')
		        ifTrue: [ aLine allButFirst: 2 ]
		        ifFalse: [ aLine trimLeft ].
	anItem description: (anItem description ifEmpty: [ text ] ifNotEmpty: [ :previous | previous , String cr , text ])
]

{ #category : 'private - items' }
NTTaskReader >> atAnnotationStart: aStream char: aCharacter [
	"Answer whether the stream is at aCharacter followed by a letter or digit, which starts a key (@) or a tag (#)."

	| pair |
	aStream peek = aCharacter ifFalse: [ ^ false ].
	pair := aStream next: 2.
	aStream skip: pair size negated.
	^ pair size = 2 and: [ pair second isAlphaNumeric ]
]

{ #category : 'private - metadata' }
NTTaskReader >> atMetadata [

	^ index <= lines size and: [ (lines at: index) trimBoth = '{' ]
]

{ #category : 'private - metadata' }
NTTaskReader >> dateAndTimeFrom: aString [

	^ [ DateAndTime fromString: aString ]
		  on: Error
		  do: [ nil ]
]

{ #category : 'private' }
NTTaskReader >> errorAt: aLineNumber reason: aString [

	^ NTTaskParseError signalLine: aLineNumber text: (lines at: aLineNumber) reason: aString
]

{ #category : 'private' }
NTTaskReader >> errorOn: aLine reason: aString [

	^ NTTaskParseError signalLine: index text: aLine reason: aString
]

{ #category : 'initialization' }
NTTaskReader >> initialize [

	super initialize.
	lines := #(  ).
	index := 1
]

{ #category : 'private - items' }
NTTaskReader >> isItemLine: aString [

	^ aString size >= 5 and: [
			  (aString beginsWith: '- [') and: [
				  (' xX' includes: (aString at: 4)) and: [ (aString at: 5) = $] and: [ aString size = 5 or: [ (aString at: 6) isSeparator ] ] ] ] ]
]

{ #category : 'private - metadata' }
NTTaskReader >> metadataAt: aKey put: aValue startingAt: aLineNumber [

	aKey = 'title' ifTrue: [ ^ task title: aValue ].
	aKey = 'section' ifTrue: [ ^ task section: aValue ].
	aKey = 'status' ifTrue: [
			(NTTask statuses includes: aValue asSymbol) ifFalse: [
				self errorAt: aLineNumber reason: 'unknown status ' , aValue printString ].
			^ task status: aValue ].
	aKey = 'finishedDate' ifTrue: [ ^ task finishedDate: (self class dateFromIso: aValue) ].
	aKey = 'creationDate' ifTrue: [ ^ task creationDate: (self dateAndTimeFrom: aValue) ].
	aKey = 'lastModificationDate' ifTrue: [ ^ task lastModificationDate: (self dateAndTimeFrom: aValue) ].
	task otherMetadata at: aKey put: aValue
]

{ #category : 'reading' }
NTTaskReader >> read: aString [
	"Answer the task written in aString. Signal an NTTaskParseError on a line that cannot be read."

	lines := aString lines.
	index := 1.
	task := NTTask new.
	self skipBlankLines.
	self atMetadata ifTrue: [ self readMetadata ].
	self readItems.
	task updateStatus.
	^ task
]

{ #category : 'private - items' }
NTTaskReader >> readAnnotationsFrom: aStream into: anItem on: aLine [
	"Read the words of an item line after its checkbox. Words starting with @ or # are annotations added to anItem; the other words make the title, which is answered."

	| titleWords |
	titleWords := OrderedCollection new.
	[
		aStream skipSeparators.
		aStream atEnd ] whileFalse: [
			(self atAnnotationStart: aStream char: $@)
				ifTrue: [ self readKeyFrom: aStream into: anItem on: aLine ]
				ifFalse: [
						(self atAnnotationStart: aStream char: $#)
							ifTrue: [
									aStream next.
									anItem addTag: (self readWordFrom: aStream) ]
							ifFalse: [ titleWords add: (self readWordFrom: aStream) ] ] ].
	^ String space join: titleWords
]

{ #category : 'reading' }
NTTaskReader >> readItemLine: aString [
	"Answer the item written on one checkbox line, such as '- [ ] Call Bob @due(2026-11-12) #admin'."

	| item stream |
	(self isItemLine: aString) ifFalse: [ self errorOn: aString reason: 'item line "- [ ] title" expected' ].
	item := NTTaskItem new.
	item isDone: (aString at: 4) ~= Character space.
	stream := (aString allButFirst: 5) trimBoth readStream.
	item title: (self readAnnotationsFrom: stream into: item on: aString).
	item title ifEmpty: [ self errorOn: aString reason: 'item title expected' ].
	^ item
]

{ #category : 'private - items' }
NTTaskReader >> readItems [
	"Read the item lines and the indented description lines that follow each of them."

	| item |
	item := nil.
	index to: lines size do: [ :lineIndex |
			| line |
			index := lineIndex.
			line := lines at: lineIndex.
			line isAllSeparators ifFalse: [
					line first isSeparator
						ifTrue: [
								item ifNil: [ self errorOn: line reason: 'description without an item above it' ].
								self addDescriptionLine: line to: item ]
						ifFalse: [ item := task addItem: (self readItemLine: line) ] ] ]
]

{ #category : 'private - items' }
NTTaskReader >> readKeyFrom: aStream into: anItem on: aLine [
	"Read @name or @name(value); the value runs up to the first closing parenthesis."

	| name value rest closing |
	aStream next.
	name := String streamContents: [ :out |
		        [ aStream atEnd not and: [ aStream peek isAlphaNumeric ] ] whileTrue: [ out nextPut: aStream next ] ].
	value := nil.
	aStream peek = $( ifTrue: [
			aStream next.
			rest := aStream upToEnd.
			closing := rest indexOf: $).
			closing = 0 ifTrue: [ self errorOn: aLine reason: ('key @{1} has no closing parenthesis' format: { name }) ].
			value := rest first: closing - 1.
			aStream skip: (rest size - closing) negated ].
	anItem keyAt: name put: value
]

{ #category : 'private - metadata' }
NTTaskReader >> readMetadata [
	"Read the metadata block, from the line '{' to the line '}', as ordered JSON entries."

	| start text entries |
	start := index.
	[ index <= lines size and: [ (lines at: index) trimBoth ~= '}' ] ] whileTrue: [ index := index + 1 ].
	index > lines size ifTrue: [ self errorAt: start reason: 'metadata block not closed by "}"' ].
	text := String lf join: (lines copyFrom: start to: index).
	index := index + 1.
	entries := OrderedDictionary new.
	[ (STONReader on: text readStream) parseMapDo: [ :key :value | entries at: key put: value ] ]
		on: Error
		do: [ :error | self errorAt: start reason: 'invalid metadata: ' , error messageText ].
	entries keysAndValuesDo: [ :key :value | self metadataAt: key put: value startingAt: start ]
]

{ #category : 'private - items' }
NTTaskReader >> readWordFrom: aStream [

	^ String streamContents: [ :out |
		  [ aStream atEnd not and: [ aStream peek isSeparator not ] ] whileTrue: [ out nextPut: aStream next ] ]
]

{ #category : 'private' }
NTTaskReader >> skipBlankLines [

	[ index <= lines size and: [ (lines at: index) isAllSeparators ] ] whileTrue: [ index := index + 1 ]
]
