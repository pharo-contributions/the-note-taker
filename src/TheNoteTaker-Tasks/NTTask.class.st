"
I represent a task: a titled list of items, saved as one file.

```
{
  ""title"" : ""Pharo 14 release"",
  ""section"" : ""Pharo"",
  ""status"" : ""open"",
  ...
}

- [x] Freeze API @done(2026-11-02)
- [ ] Write release notes @due(2026-11-15)
```

## Responsibility:

- I know my title, my section, my status (`#open`, `#finished` or `#abandoned`), my dates and my ordered items.
- I apply the status rules: I am finished when I have items and all are done; I go back to open when an item is added or unticked; `#abandoned` is only set by hand and never changed by me.
- I keep the metadata entries I do not understand, so they are written back unchanged.

## Collaborators: 

- `NTTaskItem`: my items.
- `NTTaskReader` / `NTTaskWriter`: read me from and write me to text.
- `NTTaskRepository`: loads, saves and names my file.

## Public API and Key Messages

- `NTTask title: 'Pharo 14 release'`
- `addItem:`, `addItemTitled:on:` (adds `@created`), `removeItem:`, `moveItem:to:`
- `updateStatusOn: aDate` (also `updateStatus`), `abandon`, `reopen`
- `isOpen`, `isFinished`, `isAbandoned`, `isClosed`, `sectionName` ('Unsorted' when no section)
- `doneCount`, `itemCount`

```
| task |
task := NTTask title: 'Move office'.
(task addItemTitled: 'Book movers' on: Date today) markDoneOn: Date today.
task updateStatus.
task isFinished  ""true""
```

See `NTTask class >> #examplePharoRelease`.

## Internal Representation

- `status`: a Symbol; `finishedDate`: a Date or nil.
- `creationDate`, `lastModificationDate`: DateAndTime or nil.
- `items`: an OrderedCollection of `NTTaskItem`.
- `otherMetadata`: an OrderedDictionary of metadata entries I do not interpret.
- `fileReference`: my file, set by the repository, nil for a task never saved.
"
Class {
	#name : 'NTTask',
	#superclass : 'Object',
	#instVars : [
		'title',
		'section',
		'status',
		'finishedDate',
		'creationDate',
		'lastModificationDate',
		'items',
		'otherMetadata',
		'fileReference'
	],
	#category : 'TheNoteTaker-Tasks-Model',
	#package : 'TheNoteTaker-Tasks',
	#tag : 'Model'
}

{ #category : 'examples' }
NTTask class >> exampleFinished [

	<sampleInstance>
	| task day |
	day := Date year: 2026 month: 10 day: 12.
	task := self title: 'Move office'.
	task section: 'Admin'.
	(task addItemTitled: 'Book movers' on: day) markDoneOn: day.
	(task addItemTitled: 'Pack books' on: day) markDoneOn: day + 9 days.
	task updateStatusOn: day + 9 days.
	^ task
]

{ #category : 'examples' }
NTTask class >> examplePharoRelease [

	<sampleInstance>
	| task day |
	day := Date year: 2026 month: 11 day: 4.
	task := self title: 'Pharo 14 release'.
	task section: 'Pharo'.
	task creationDate: day asDateAndTime.
	(task addItemTitled: 'Freeze API' on: day) markDoneOn: day + 1 day.
	(task addItemTitled: 'Write release notes' on: day)
		due: day + 11 days;
		prio: 'high';
		addTag: 'release'.
	(task addItemTitled: 'Sign-off' on: day) waitingOthers: 'Marcus'.
	^ task
]

{ #category : 'accessing' }
NTTask class >> statuses [
	"Answer the statuses a task can have, as written in the file."

	^ #( #open #finished #abandoned )
]

{ #category : 'instance creation' }
NTTask class >> title: aString [

	^ self new
		  title: aString;
		  yourself
]

{ #category : 'accessing' }
NTTask class >> unsortedSectionName [

	^ 'Unsorted'
]

{ #category : 'status' }
NTTask >> abandon [
	"Mark me as dropped. Only a person does this; status rules never change it."

	status := #abandoned.
	finishedDate := nil
]

{ #category : 'items' }
NTTask >> addItem: anItem [

	items add: anItem.
	^ anItem
]

{ #category : 'items' }
NTTask >> addItemTitled: aString [

	^ self addItemTitled: aString on: Date today
]

{ #category : 'items' }
NTTask >> addItemTitled: aString on: aDate [
	"Add a new item, recording its creation date with @created."

	^ self addItem: ((NTTaskItem title: aString)
			   createdDate: aDate;
			   yourself)
]

{ #category : 'accessing' }
NTTask >> allTags [

	^ (items flatCollect: [ :each | each tags ] as: OrderedCollection)
		  removeDuplicates;
		  yourself
]

{ #category : 'status' }
NTTask >> areAllItemsDone [

	^ items isNotEmpty and: [ items allSatisfy: [ :each | each isDone ] ]
]

{ #category : 'accessing' }
NTTask >> creationDate [

	^ creationDate
]

{ #category : 'accessing' }
NTTask >> creationDate: aDateAndTime [

	creationDate := aDateAndTime
]

{ #category : 'accessing' }
NTTask >> doneCount [

	^ items count: [ :each | each isDone ]
]

{ #category : 'accessing' }
NTTask >> fileReference [

	^ fileReference
]

{ #category : 'accessing' }
NTTask >> fileReference: aFileReference [

	fileReference := aFileReference
]

{ #category : 'accessing' }
NTTask >> finishedDate [

	^ finishedDate
]

{ #category : 'accessing' }
NTTask >> finishedDate: aDateOrNil [

	finishedDate := aDateOrNil ifNotNil: [ :date | date asDate ]
]

{ #category : 'initialization' }
NTTask >> initialize [

	super initialize.
	title := ''.
	status := #open.
	items := OrderedCollection new.
	otherMetadata := OrderedDictionary new
]

{ #category : 'testing' }
NTTask >> isAbandoned [

	^ status = #abandoned
]

{ #category : 'testing' }
NTTask >> isClosed [

	^ self isOpen not
]

{ #category : 'testing' }
NTTask >> isFinished [

	^ status = #finished
]

{ #category : 'testing' }
NTTask >> isOpen [

	^ status = #open
]

{ #category : 'accessing' }
NTTask >> itemCount [

	^ items size
]

{ #category : 'accessing' }
NTTask >> items [

	^ items
]

{ #category : 'accessing' }
NTTask >> lastModificationDate [

	^ lastModificationDate
]

{ #category : 'accessing' }
NTTask >> lastModificationDate: aDateAndTime [

	lastModificationDate := aDateAndTime
]

{ #category : 'status' }
NTTask >> latestDoneDate [

	| dates |
	dates := items collect: [ :each | each doneDate ] thenSelect: [ :each | each isNotNil ].
	^ dates ifEmpty: [ nil ] ifNotEmpty: [ dates max ]
]

{ #category : 'items' }
NTTask >> moveItem: anItem to: anIndex [
	"Move anItem to position anIndex; the order of items is their order in the file."

	items remove: anItem.
	items add: anItem beforeIndex: anIndex
]

{ #category : 'accessing' }
NTTask >> otherMetadata [

	^ otherMetadata
]

{ #category : 'printing' }
NTTask >> printOn: aStream [

	super printOn: aStream.
	aStream
		nextPutAll: ' (';
		nextPutAll: title;
		space;
		print: self doneCount;
		nextPut: $/;
		print: self itemCount;
		space;
		nextPutAll: status;
		nextPut: $)
]

{ #category : 'items' }
NTTask >> removeItem: anItem [

	^ items remove: anItem
]

{ #category : 'status' }
NTTask >> reopen [

	status := #open.
	finishedDate := nil
]

{ #category : 'accessing' }
NTTask >> section [

	^ section
]

{ #category : 'accessing' }
NTTask >> section: aStringOrNil [

	section := aStringOrNil
]

{ #category : 'accessing' }
NTTask >> sectionName [
	"Answer the section shown in the UI: tasks without a section go to 'Unsorted'."

	^ (section isNil or: [ section isEmpty ])
		  ifTrue: [ self class unsortedSectionName ]
		  ifFalse: [ section ]
]

{ #category : 'accessing' }
NTTask >> status [

	^ status
]

{ #category : 'accessing' }
NTTask >> status: aSymbol [

	status := aSymbol asSymbol
]

{ #category : 'accessing' }
NTTask >> title [

	^ title
]

{ #category : 'accessing' }
NTTask >> title: aString [

	title := aString
]

{ #category : 'status' }
NTTask >> updateStatus [

	self updateStatusOn: Date today
]

{ #category : 'status' }
NTTask >> updateStatusOn: aDate [
	"Apply the status rules: finished when there are items and all are done, open otherwise. An abandoned task is never changed. aDate is the finished date used when no item has a @done date."

	self isAbandoned ifTrue: [ ^ self ].
	self areAllItemsDone
		ifTrue: [
				status := #finished.
				finishedDate ifNil: [ finishedDate := (self latestDoneDate ifNil: [ aDate ]) asDate ] ]
		ifFalse: [
				status := #open.
				finishedDate := nil ]
]
