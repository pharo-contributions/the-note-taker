"
Represents a singleton pattern implementation for managing a centralized instance of `NTNoteObject` notes container.

The singleton ensures that there is only one instance of the container throughout the application's lifecycle, providing global access to the collection of notes. It is useful for scenarios where a single instance of a class needs to be shared and accessed globally across multiple parts of the application.

## Usage

To access the unique instance of the Notes container, use the class method 'uniqueInstance'. For example:

```
| notesContainer |
notesContainer := NTSingleton uniqueInstance.
```

### Responsibilities

- Providing a centralized and globally accessible instance of Notes.
- Ensuring that only one instance of the notes container exists within the application.

Note: It is recommended to use the `uniqueInstance` method to access the singleton rather than instantiating it directly.

"
Class {
	#name : 'TaskManager',
	#superclass : 'Object',
	#instVars : [
		'tasks',
		'tags'
	],
	#category : 'TheNoteTaker-Todo',
	#package : 'TheNoteTaker-Todo'
}

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

{ #category : 'adding - notes' }
TaskManager >> getDefaultTask [

	| maison machin reviser machin1 machin2 machin3 |
	
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
	machin addTask: machin3.
]

{ #category : 'accessing' }
TaskManager >> getDoneTask [

	^ self tasks select: [ :t | t isDone ]
]

{ #category : 'accessing' }
TaskManager >> getInBoxTask [

	^ self tasks select: [ :t | t tags isEmpty ]
]

{ #category : 'accessing' }
TaskManager >> getLateTask [

	^ self tasks select: [ :t | t limitDate < DateAndTime now ]
]

{ #category : 'accessing' }
TaskManager >> getTaskForTag: aTag [

	^ aTag tasks
]

{ #category : 'accessing' }
TaskManager >> getTodayTask [

	^ self tasks select: [ :t | t limitDate asDate equals: Date today ]
]

{ #category : 'accessing' }
TaskManager >> getTrashTask [

	^ self tasks select: [ :t |
		  t isTrash ]
]

{ #category : 'accessing' }
TaskManager >> getWeekTask [

	^ self tasks select: [ :t | t limitDate asDate weeks = Date today weeks ]
]

{ #category : 'accessing - notes' }
TaskManager >> initialize [

	tasks := OrderedCollection new.
	tags := OrderedCollection new.

	"self getDefaultTask"
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
	"Answer a <Collection> with <NoteObject> objects whose title matched named aString"

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
	"Answer a <Collection> with <NoteObject> objects whose title matched named aString"

	| pattern |
	pattern := '*' , aString , '*'.
	^ self tasks select: [ :t | pattern match: t title ]
]
