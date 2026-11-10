"
I represent one key annotation of a task item: `@due(2026-11-15)`, or a key without value such as `@waitingOthers`.

## Responsibility:

- I know a key name and its value as written in the file (a String, or nil when there is no value).
- I print myself in the file syntax, `@name(value)` or `@name`.
- I am kept by an `NTTaskItem` in file order, together with `NTItemTag`s.

## Collaborators: 

- `NTTaskItem`: holds me in its annotations.
- `NTTaskWriter`: asks me to print myself.

## Public API and Key Messages

- `NTItemKey name: 'due' value: '2026-11-15'`
- `name`, `value`, `value:`, `hasValue`, `isKey`, `isTag`
- `printFileSyntaxOn: aStream`

```
(NTItemKey name: 'prio' value: 'high') fileSyntax  ""'@prio(high)'""
```

See `NTItemKey class >> #exampleDue`.

## Internal Representation

- `name`: a String without the leading `@`.
- `value`: a String or nil.
"
Class {
	#name : 'NTItemKey',
	#superclass : 'Object',
	#instVars : [
		'name',
		'value'
	],
	#category : 'TheNoteTaker-Tasks-Model',
	#package : 'TheNoteTaker-Tasks',
	#tag : 'Model'
}

{ #category : 'examples' }
NTItemKey class >> exampleDue [

	<sampleInstance>
	^ self name: 'due' value: '2026-11-15'
]

{ #category : 'examples' }
NTItemKey class >> exampleWithoutValue [

	<sampleInstance>
	^ self name: 'waitingOthers' value: nil
]

{ #category : 'instance creation' }
NTItemKey class >> name: aName value: aValue [

	^ self new
		  name: aName;
		  value: aValue;
		  yourself
]

{ #category : 'printing' }
NTItemKey >> fileSyntax [

	^ String streamContents: [ :stream | self printFileSyntaxOn: stream ]
]

{ #category : 'testing' }
NTItemKey >> hasValue [

	^ value isNotNil
]

{ #category : 'testing' }
NTItemKey >> isKey [

	^ true
]

{ #category : 'testing' }
NTItemKey >> isTag [

	^ false
]

{ #category : 'accessing' }
NTItemKey >> name [

	^ name
]

{ #category : 'accessing' }
NTItemKey >> name: aString [

	name := aString
]

{ #category : 'printing' }
NTItemKey >> printFileSyntaxOn: aStream [
	"Print myself as written in a task file: @name(value), or @name when I have no value."

	aStream
		nextPut: $@;
		nextPutAll: name.
	self hasValue ifTrue: [
			aStream
				nextPut: $(;
				nextPutAll: value;
				nextPut: $) ]
]

{ #category : 'printing' }
NTItemKey >> printOn: aStream [

	super printOn: aStream.
	aStream space.
	self printFileSyntaxOn: aStream
]

{ #category : 'evaluating' }
NTItemKey >> value [

	^ value
]

{ #category : 'accessing' }
NTItemKey >> value: aStringOrNil [

	value := aStringOrNil
]
