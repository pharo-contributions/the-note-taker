"
I represent one tag annotation of a task item, written `#release` in a task file.

## Responsibility:

- I know the tag name, without the leading `#`.
- I print myself in the file syntax, `#name`.
- I am kept by an `NTTaskItem` in file order, together with `NTItemKey`s.

## Collaborators: 

- `NTTaskItem`: holds me in its annotations.
- `NTTaskWriter`: asks me to print myself.

## Public API and Key Messages

- `NTItemTag name: 'release'`
- `name`, `isKey`, `isTag`, `printFileSyntaxOn: aStream`

```
(NTItemTag name: 'work') fileSyntax  ""'#work'""
```

See `NTItemTag class >> #exampleWork`.

## Internal Representation

- `name`: a String.
"
Class {
	#name : 'NTItemTag',
	#superclass : 'Object',
	#instVars : [
		'name'
	],
	#category : 'TheNoteTaker-Tasks-Model',
	#package : 'TheNoteTaker-Tasks',
	#tag : 'Model'
}

{ #category : 'examples' }
NTItemTag class >> exampleWork [

	<sampleInstance>
	^ self name: 'work'
]

{ #category : 'instance creation' }
NTItemTag class >> name: aName [

	^ self new
		  name: aName;
		  yourself
]

{ #category : 'printing' }
NTItemTag >> fileSyntax [

	^ String streamContents: [ :stream | self printFileSyntaxOn: stream ]
]

{ #category : 'testing' }
NTItemTag >> isKey [

	^ false
]

{ #category : 'testing' }
NTItemTag >> isTag [

	^ true
]

{ #category : 'accessing' }
NTItemTag >> name [

	^ name
]

{ #category : 'accessing' }
NTItemTag >> name: aString [

	name := aString
]

{ #category : 'printing' }
NTItemTag >> printFileSyntaxOn: aStream [
	"Print myself as written in a task file: #name."

	aStream
		nextPut: $#;
		nextPutAll: name
]

{ #category : 'printing' }
NTItemTag >> printOn: aStream [

	super printOn: aStream.
	aStream space.
	self printFileSyntaxOn: aStream
]
