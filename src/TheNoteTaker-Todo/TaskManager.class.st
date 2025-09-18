"
I represent a task manager for the application.
I hold a tasks list and a tags list, for ensure tags are not duplicated.

I have the tags and task filter matching, for search tags or tasks by their name.

I have some filter for the application like:

- GetDoneTask
- getInBoxTask
- getLateTask
- getTodayTask
- getTrashTask
- getWeekTask
"
Class {
	#name : 'TaskManager',
	#superclass : 'Object',
	#instVars : [
		'tasks',
		'tags',
		'fileReference'
	],
	#category : 'TheNoteTaker-Todo',
	#package : 'TheNoteTaker-Todo'
}

{ #category : 'ston-core' }
TaskManager class >> stonAllInstVarNames [

	^ self allInstVarNames copyWithout: #fileReference
]

{ #category : 'accessing - notes' }
TaskManager >> addTagNamed: aString [
	"Add a new empty note with title aString to the receiver's notes."

	| tag |
	tag := TodoTag newNamed: aString.
	self tags add: tag.
	^ tag
]

{ #category : 'adding - notes' }
TaskManager >> addTask: aNTTodo [

	self tasks add: aNTTodo.
	^ aNTTodo
]

{ #category : 'accessing - notes' }
TaskManager >> ensureTagNamed: aString [
	"Answer the first <NTNoteObject> matching aString in its name"

	^ self tags
		  detect: [ :n | n tagName = aString ]
		  ifNone: [ self addTagNamed: aString ]
]

{ #category : 'removing - notes' }
TaskManager >> fileName [

	^ 'taskManager.txt'
]

{ #category : 'removing - notes' }
TaskManager >> fileReference [

	^ fileReference
]

{ #category : 'removing - notes' }
TaskManager >> folderReference: aFileReference [

	fileReference := aFileReference / self fileName
]

{ #category : 'adding - notes' }
TaskManager >> getDefaultTask [

	"This was a test method, i use it for generate test manually
	He not used anymore"

	| maison machin reviser machin1 machin2 machin3 |
	self flag: #ToDelete.
	maison := self ensureTagNamed: 'Maison'.
	machin := self ensureTagNamed: 'Machin'.

	self addTask: (Task new title: 'Chercher le pain').
	reviser := self addTask: (Task new
			            title: 'Reviser';
			            isRecurrent: true).
	machin1 := self addTask: (Task new title: 'Machin 1 ').
	machin2 := self addTask: (Task new title: 'Machin 2 ').
	machin3 := self addTask: (Task new title: 'Machin 3').

	maison addTask: reviser.
	machin addTask: machin1.
	machin addTask: machin2.
	machin addTask: machin3
]

{ #category : 'accessing' }
TaskManager >> getDoneTask [

	^ self tasks select: [ :t | t isDone and: t isTrash not ]
]

{ #category : 'accessing' }
TaskManager >> getInBoxTask [

	^ self tasks select: [ :t | t tags isEmpty and: t isTrash not ]
]

{ #category : 'accessing' }
TaskManager >> getLateTask [

	^ self tasks select: [ :t | (t limitDate < DateAndTime now) and: t isTrash not ]
]

{ #category : 'accessing' }
TaskManager >> getTaskForTag: aTag [

	^ aTag tasks
]

{ #category : 'accessing' }
TaskManager >> getTodayTask [

	^ self tasks select: [ :t | (t limitDate asDate equals: Date today) and: t isTrash not ]
]

{ #category : 'accessing' }
TaskManager >> getTrashTask [

	^ self tasks select: [ :t |
		  t isTrash ]
]

{ #category : 'accessing' }
TaskManager >> getWeekTask [
self flag: #Unused.
	^ self tasks select: [ :t |
		  t limitDate asDate weeks = Date today weeks and: t isTrash not ]
]

{ #category : 'accessing - notes' }
TaskManager >> initialize [

	tasks := OrderedCollection new.
	tags := OrderedCollection new.
	fileReference := FileLocator workingDirectory / self fileName

	"self getDefaultTask"
]

{ #category : 'removing - notes' }
TaskManager >> load [

	| loadTaskManager |
	fileReference exists ifFalse: [ ^ self ].
	loadTaskManager := [ STON fromString: fileReference contents ]
		                   on: STONReaderError
		                   do: [ ^ self ].
	(loadTaskManager isKindOf: self class) ifFalse: [ ^ self ].
	self tags: loadTaskManager tags.
	self tasks: loadTaskManager tasks
]

{ #category : 'removing - notes' }
TaskManager >> removeTask: aTask [
	"Remove the note aNTNoteObject from the receiver's notes. Answer the receiver"
	
	aTask isTrash ifTrue:  [ self tasks remove: aTask ] ifFalse: [aTask isTrash: true].
]

{ #category : 'removing - notes' }
TaskManager >> removetasks: aCollectionOfNTTodo [
	"Remove the note aNTNoteObject from the receiver's notes. Answer the receiver"
	
	self tasks removeAll: aCollectionOfNTTodo
]

{ #category : 'removing - notes' }
TaskManager >> save [

	fileReference writeStreamDo: [ :str | str << (STON toString: self) ]
]

{ #category : 'accessing' }
TaskManager >> tags [
	"Answer the receiver's <Collection> of <NTNoteObject>"

	^ tags
]

{ #category : 'accessing' }
TaskManager >> tags: aCollection [

	tags := aCollection
]

{ #category : 'accessing - notes' }
TaskManager >> tagsNameMatching: aString [
	"Answer a <Collection> with <TodoTag> objects whose title matched named aString"

	| pattern |
	pattern := '*' , aString , '*'.
	^ self tags select: [ :n | pattern match: n tagName ]
]

{ #category : 'accessing - notes' }
TaskManager >> tasks [
	"Answer the receiver's <Collection> of <NTNoteObject>"

	^ tasks
]

{ #category : 'accessing - notes' }
TaskManager >> tasks: aCollection [ 
	tasks := aCollection
]

{ #category : 'accessing - notes' }
TaskManager >> tasksTitleMatching: aString [
	"Answer a <Collection> with <Task> objects whose title matched named aString"

	| pattern |
	pattern := '*' , aString , '*'.
	^ self tasks select: [ :t | pattern match: t title ]
]
