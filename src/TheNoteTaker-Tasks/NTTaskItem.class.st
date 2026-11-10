"
I represent one item of a task: a single checkbox line of a task file, with its description.

```
- [ ] Write release notes @due(2026-11-15) @prio(high) #release
  Mention the new compiler.
```

## Responsibility:

- I know my title, my description, whether I am done, and my annotations (`@key(value)`, `@key` and `#tag`), in the order they were written.
- I keep every annotation, even the ones the app does not understand, so that a task file is written back without loss.
- I give typed access to the keys the app understands: `due`, `start`, `doneDate`, `createdDate`, `prio`, `waitingOthers`, `note`, `url`, `every`.

## Collaborators: 

- `NTItemKey` and `NTItemTag`: my annotations.
- `NTTask`: owns me and computes its status from my done state.
- `NTTaskReader` / `NTTaskWriter`: create me from text and write me back.

## Public API and Key Messages

- `NTTaskItem title: 'Write release notes'`
- `markDoneOn: aDate` / `markUndone`: tick and untick (adds or removes `@done`).
- `keyAt: 'due'`, `keyAt: 'due' put: '2026-11-15'`, `removeKey: 'due'`, `hasKey: 'waitingOthers'`
- `addTag: 'release'`, `tags`, `hasTag: 'release'`
- `due`, `due: aDate`, `isHighPriority`, `isWaitingOthers`, `isVisibleOn: aDate`

```
(NTTaskItem title: 'Send slides')
	due: (Date year: 2026 month: 11 day: 15);
	addTag: 'work';
	yourself
```

See `NTTaskItem class >> #exampleReleaseNotes`.

## Internal Representation

- `title`: a String, `description`: a String (lines separated by `Character cr`), possibly empty.
- `isDone`: a Boolean.
- `annotations`: an OrderedCollection of `NTItemKey` and `NTItemTag`, in file order.

### Implementation Points

- Key values are kept as the strings found in the file; typed accessors convert them (ISO dates `yyyy-mm-dd`).
- A key without a value (`@waitingOthers`) has a nil value.
"
Class {
	#name : 'NTTaskItem',
	#superclass : 'Object',
	#instVars : [
		'title',
		'description',
		'isDone',
		'annotations'
	],
	#category : 'TheNoteTaker-Tasks-Model',
	#package : 'TheNoteTaker-Tasks',
	#tag : 'Model'
}

{ #category : 'examples' }
NTTaskItem class >> exampleDone [

	<sampleInstance>
	^ (self title: 'Freeze API')
		  markDoneOn: (Date year: 2026 month: 11 day: 2);
		  yourself
]

{ #category : 'examples' }
NTTaskItem class >> exampleReleaseNotes [

	<sampleInstance>
	^ (self title: 'Write release notes')
		  due: (Date year: 2026 month: 11 day: 15);
		  prio: 'high';
		  addTag: 'release';
		  description: 'Mention the new compiler.';
		  yourself
]

{ #category : 'examples' }
NTTaskItem class >> exampleWaitingOthers [

	<sampleInstance>
	^ (self title: 'Sign-off')
		  waitingOthers: 'Marcus';
		  yourself
]

{ #category : 'instance creation' }
NTTaskItem class >> title: aString [

	^ self new
		  title: aString;
		  yourself
]

{ #category : 'accessing - tags' }
NTTaskItem >> addTag: aName [

	(self hasTag: aName) ifFalse: [ annotations add: (NTItemTag name: aName) ]
]

{ #category : 'accessing' }
NTTaskItem >> annotations [

	^ annotations
]

{ #category : 'accessing - known keys' }
NTTaskItem >> createdDate [

	^ self dateAt: 'created'
]

{ #category : 'accessing - known keys' }
NTTaskItem >> createdDate: aDateOrNil [

	self dateAt: 'created' put: aDateOrNil
]

{ #category : 'private' }
NTTaskItem >> dateAt: aName [
	"Answer the date stored in the key as yyyy-mm-dd, or nil when the key is absent or is not such a date."

	^ NTTaskReader dateFromIso: (self keyAt: aName)
]

{ #category : 'private' }
NTTaskItem >> dateAt: aName put: aDateOrNil [
	"Store the day of aDateOrNil (a Date, a DateAndTime or a Timespan) as yyyy-mm-dd, or remove the key when nil."

	aDateOrNil ifNil: [ self removeKey: aName ] ifNotNil: [ self keyAt: aName put: aDateOrNil asDate yyyymmdd ]
]

{ #category : 'accessing' }
NTTaskItem >> description [

	^ description
]

{ #category : 'accessing' }
NTTaskItem >> description: aString [

	description := aString
]

{ #category : 'printing' }
NTTaskItem >> displayAnnotations [
	"Answer my annotations as written in the file, without @done (shown by a checkbox) and @created (bookkeeping)."

	^ String space join: (annotations
			   reject: [ :each | each isKey and: [ #( 'done' 'created' ) includes: each name ] ]
			   thenCollect: [ :each | each fileSyntax ])
]

{ #category : 'accessing - known keys' }
NTTaskItem >> doneDate [

	^ self dateAt: 'done'
]

{ #category : 'accessing - known keys' }
NTTaskItem >> due [

	^ self dateAt: 'due'
]

{ #category : 'accessing - known keys' }
NTTaskItem >> due: aDateOrNil [

	self dateAt: 'due' put: aDateOrNil
]

{ #category : 'accessing - known keys' }
NTTaskItem >> every [

	^ self keyAt: 'every'
]

{ #category : 'accessing - known keys' }
NTTaskItem >> every: aString [

	self keyAt: 'every' put: aString
]

{ #category : 'accessing - keys' }
NTTaskItem >> hasKey: aName [

	^ (self keyNamed: aName) isNotNil
]

{ #category : 'accessing - tags' }
NTTaskItem >> hasTag: aName [

	^ annotations anySatisfy: [ :each | each isTag and: [ each name = aName ] ]
]

{ #category : 'initialization' }
NTTaskItem >> initialize [

	super initialize.
	title := ''.
	description := ''.
	isDone := false.
	annotations := OrderedCollection new
]

{ #category : 'accessing' }
NTTaskItem >> isDone [

	^ isDone
]

{ #category : 'accessing' }
NTTaskItem >> isDone: aBoolean [

	isDone := aBoolean
]

{ #category : 'testing' }
NTTaskItem >> isHighPriority [

	^ self prio = 'high'
]

{ #category : 'testing' }
NTTaskItem >> isLateOn: aDate [

	isDone ifTrue: [ ^ false ].
	^ self due ifNil: [ false ] ifNotNil: [ :dueDate | dueDate < aDate ]
]

{ #category : 'testing' }
NTTaskItem >> isLowPriority [

	^ self prio = 'low'
]

{ #category : 'testing' }
NTTaskItem >> isVisibleOn: aDate [
	"Answer whether views show me on aDate: an item with a later @start is hidden until then."

	^ self start ifNil: [ true ] ifNotNil: [ :startDate | startDate <= aDate ]
]

{ #category : 'testing' }
NTTaskItem >> isWaitingOthers [

	^ self hasKey: 'waitingOthers'
]

{ #category : 'accessing - keys' }
NTTaskItem >> keyAt: aName [
	"Answer the value of the key as written in the file, or nil when the key is absent or has no value."

	^ (self keyNamed: aName) ifNotNil: [ :key | key value ]
]

{ #category : 'accessing - keys' }
NTTaskItem >> keyAt: aName put: aStringOrNil [
	"Set the value of the key, keeping its position when it already exists, appending it otherwise. A nil value gives a key without value, such as @waitingOthers."

	(self keyNamed: aName)
		ifNil: [ annotations add: (NTItemKey name: aName value: aStringOrNil) ]
		ifNotNil: [ :key | key value: aStringOrNil ]
]

{ #category : 'accessing - keys' }
NTTaskItem >> keyNamed: aName [
	"Answer my key annotation with that name, or nil."

	^ annotations detect: [ :each | each isKey and: [ each name = aName ] ] ifNone: [ nil ]
]

{ #category : 'accessing - keys' }
NTTaskItem >> keys [

	^ annotations select: [ :each | each isKey ]
]

{ #category : 'actions' }
NTTaskItem >> markDone [

	self markDoneOn: Date today
]

{ #category : 'actions' }
NTTaskItem >> markDoneOn: aDate [
	"Tick me. The @done date records when, unless one is already there."

	isDone := true.
	(self hasKey: 'done') ifFalse: [ self dateAt: 'done' put: aDate ]
]

{ #category : 'actions' }
NTTaskItem >> markUndone [

	isDone := false.
	self removeKey: 'done'
]

{ #category : 'accessing - known keys' }
NTTaskItem >> note [

	^ self keyAt: 'note'
]

{ #category : 'accessing - known keys' }
NTTaskItem >> note: aNoteFileName [

	self keyAt: 'note' put: aNoteFileName
]

{ #category : 'printing' }
NTTaskItem >> printOn: aStream [

	super printOn: aStream.
	aStream
		nextPutAll: ' (';
		nextPutAll: (isDone
				 ifTrue: [ '[x] ' ]
				 ifFalse: [ '[ ] ' ]);
		nextPutAll: title;
		nextPut: $)
]

{ #category : 'accessing - known keys' }
NTTaskItem >> prio [

	^ self keyAt: 'prio'
]

{ #category : 'accessing - known keys' }
NTTaskItem >> prio: aString [
	"aString is 'high' or 'low'; nil means normal priority."

	aString ifNil: [ self removeKey: 'prio' ] ifNotNil: [ self keyAt: 'prio' put: aString ]
]

{ #category : 'accessing - keys' }
NTTaskItem >> removeKey: aName [

	annotations removeAllSuchThat: [ :each | each isKey and: [ each name = aName ] ]
]

{ #category : 'accessing - tags' }
NTTaskItem >> removeTag: aName [

	annotations removeAllSuchThat: [ :each | each isTag and: [ each name = aName ] ]
]

{ #category : 'accessing - known keys' }
NTTaskItem >> start [

	^ self dateAt: 'start'
]

{ #category : 'accessing - known keys' }
NTTaskItem >> start: aDateOrNil [

	self dateAt: 'start' put: aDateOrNil
]

{ #category : 'accessing - tags' }
NTTaskItem >> tags [

	^ annotations select: [ :each | each isTag ] thenCollect: [ :each | each name ]
]

{ #category : 'accessing' }
NTTaskItem >> title [

	^ title
]

{ #category : 'accessing' }
NTTaskItem >> title: aString [

	title := aString
]

{ #category : 'accessing - known keys' }
NTTaskItem >> url [

	^ self keyAt: 'url'
]

{ #category : 'accessing - known keys' }
NTTaskItem >> url: aString [

	self keyAt: 'url' put: aString
]

{ #category : 'accessing - known keys' }
NTTaskItem >> waitingOthers [
	"Answer the person I am waiting on, or nil when no one is named."

	^ self keyAt: 'waitingOthers'
]

{ #category : 'accessing - known keys' }
NTTaskItem >> waitingOthers: aStringOrNil [
	"Mark me as waiting on someone; aStringOrNil names the person."

	self keyAt: 'waitingOthers' put: aStringOrNil
]
