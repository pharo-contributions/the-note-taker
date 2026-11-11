"
I write an `NTTask` as the text of its task file.
When Microdown will be upgraded to support - [] and @syntax the writer should use the microdownBuilder

## Responsibility:

- I write the metadata block with a fixed key order (`title`, `section`, `status`, `finishedDate`, `creationDate`, `lastModificationDate`), followed by unknown metadata entries in their original order.
- I write one checkbox line per item: `- [ ]` or `- [x]`, the title, then the annotations in their order, then the description lines indented by two spaces.
- I use `Character lf` as line separator, so files diff cleanly in git.

## Collaborators: 

- `NTTask`, `NTTaskItem`, `NTItemKey`, `NTItemTag`: what I write.
- `NTTaskReader`: reads back what I write.
- `STONJSON`: escapes metadata strings.

## Public API and Key Messages

- `NTTaskWriter write: aTask` answers a String.
- `NTTaskWriter new itemLine: anItem` answers the checkbox line of one item.

```
NTTaskWriter write: NTTask examplePharoRelease
```

See `NTTaskWriter class >> #exampleWriter`.

## Internal Representation

- `stream`: the WriteStream being filled.
"
Class {
	#name : 'NTTaskWriter',
	#superclass : 'Object',
	#instVars : [
		'stream'
	],
	#category : 'TheNoteTaker-Tasks-In-Out',
	#package : 'TheNoteTaker-Tasks',
	#tag : 'In-Out'
}

{ #category : 'examples' }
NTTaskWriter class >> exampleWriter [

	<sampleInstance>
	^ self new
]

{ #category : 'script' }
NTTaskWriter class >> scriptWriteTask [
	"Write the example Pharo release task and show the text of its file."

	<script>
	(self write: NTTask examplePharoRelease) inspect
]

{ #category : 'writing' }
NTTaskWriter class >> write: aTask [

	^ self new write: aTask
]

{ #category : 'writing' }
NTTaskWriter >> itemLine: anItem [
	"Answer the checkbox line of anItem, without its description."

	^ String streamContents: [ :out |
			  out
				  nextPutAll: (anItem isDone
						   ifTrue: [ '- [x] ' ]
						   ifFalse: [ '- [ ] ' ]);
				  nextPutAll: anItem title.
			  anItem annotations do: [ :each |
					  out space.
					  each printFileSyntaxOn: out ] ]
]

{ #category : 'private' }
NTTaskWriter >> metadataEntriesOf: aTask [
	"Answer the metadata of aTask as key -> JSON value, known keys first in a fixed order, then the other entries in their order."

	| entries |
	entries := OrderedCollection new.
	entries add: 'title' -> aTask title.
	(aTask section isNotNil and: [ aTask section isNotEmpty ]) ifTrue: [ entries add: 'section' -> aTask section ].
	entries add: 'status' -> aTask status asString.
	aTask finishedDate ifNotNil: [ :date | entries add: 'finishedDate' -> date yyyymmdd ].
	aTask creationDate ifNotNil: [ :date | entries add: 'creationDate' -> date printString ].
	aTask lastModificationDate ifNotNil: [ :date | entries add: 'lastModificationDate' -> date printString ].
	aTask otherMetadata associationsDo: [ :each | entries add: each ].
	^ entries
]

{ #category : 'private' }
NTTaskWriter >> newLine [

	stream nextPut: Character lf
]

{ #category : 'writing' }
NTTaskWriter >> write: aTask [
	"Answer the text of the file of aTask."

	stream := WriteStream on: String new.
	self writeMetadataOf: aTask.
	aTask items ifNotEmpty: [ :items |
			self newLine.
			items do: [ :each | self writeItem: each ] ].
	^ stream contents
]

{ #category : 'private' }
NTTaskWriter >> writeItem: anItem [

	stream nextPutAll: (self itemLine: anItem).
	self newLine.
	anItem description lines do: [ :each |
			stream
				nextPutAll: '  ';
				nextPutAll: each.
			self newLine ]
]

{ #category : 'private' }
NTTaskWriter >> writeMetadataOf: aTask [

	stream nextPut: ${.
	self newLine.
	(self metadataEntriesOf: aTask)
		do: [ :each |
				stream
					nextPutAll: '  ';
					nextPutAll: (STONJSON toString: each key);
					nextPutAll: ' : ';
					nextPutAll: (STONJSON toString: each value) ]
		separatedBy: [
				stream nextPut: $,.
				self newLine ].
	self newLine.
	stream nextPut: $}.
	self newLine
]
