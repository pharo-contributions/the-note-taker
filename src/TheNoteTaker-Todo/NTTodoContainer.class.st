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
	#name : 'NTTodoContainer',
	#superclass : 'Object',
	#instVars : [
		'tasks',
		'tags'
	],
	#category : 'TheNoteTaker-Todo',
	#package : 'TheNoteTaker-Todo'
}

{ #category : 'accessing - notes' }
NTTodoContainer >> addTagNamed: aString [
	"Add a new empty note with title aString to the receiver's notes."

	| tag |
	tag := NTTodoTag newNamed: aString.
	self tags add: tag.
	^ tag
]

{ #category : 'adding - notes' }
NTTodoContainer >> addTask: aNTTodo [

	self tasks add: aNTTodo.
	^ aNTTodo
]

{ #category : 'accessing - notes' }
NTTodoContainer >> ensureTagNamed: aString [
	"Answer the first <NTNoteObject> matching aString in its name"

	^ self tags
		  detect: [ :n | n tagName = aString ]
		  ifNone: [ self addTagNamed: aString ]
]

{ #category : 'adding - notes' }
NTTodoContainer >> getDefaultTask [

	| maison machin reviser machin1 machin2 machin3 |
	
	maison := self ensureTagNamed: 'Maison'.
	machin := self ensureTagNamed: 'Machin'.
	
	self addTask: (NTTodo new title: 'Chercher le pain').
	reviser := self addTask: (NTTodo new
			 title: 'Reviser';
			 isRecurrent: true).
	machin1 := self addTask: (NTTodo new title: 'Machin 1 ').
	machin2 := self addTask: (NTTodo new title: 'Machin 2 ').
	machin3 := self addTask: (NTTodo new title: 'Machin 3').
	
	maison addTask: reviser.
	machin addTask: machin1.
	machin addTask: machin2.
	machin addTask: machin3.
]

{ #category : 'accessing' }
NTTodoContainer >> getDoneTask [

	^ self tasks select: [ :t | t isDone ]
]

{ #category : 'accessing' }
NTTodoContainer >> getInBoxTask [

	^ self tasks select: [ :t | t tags isEmpty ]
]

{ #category : 'accessing' }
NTTodoContainer >> getLateTask [

	^ self tasks select: [ :t | t limitDate < DateAndTime now ]
]

{ #category : 'accessing' }
NTTodoContainer >> getTaskForTag: aTag [

	^ aTag tasks
]

{ #category : 'accessing' }
NTTodoContainer >> getTodayTask [

	^ self tasks select: [ :t | t limitDate asDate equals: Date today ]
]

{ #category : 'accessing' }
NTTodoContainer >> getTrashTask [

	^ self tasks select: [ :t |
		  t isTrash ]
]

{ #category : 'accessing' }
NTTodoContainer >> getWeekTask [

	^ self tasks select: [ :t | t limitDate asDate weeks = Date today weeks ]
]

{ #category : 'accessing - notes' }
NTTodoContainer >> initialize [

	tasks := OrderedCollection new.
	tags := OrderedCollection new.

	self getDefaultTask
]

{ #category : 'removing - notes' }
NTTodoContainer >> removetasks: aCollectionOfNTTodo [
	"Remove the note aNTNoteObject from the receiver's notes. Answer the receiver"
	
	self tasks removeAll: aCollectionOfNTTodo
]

{ #category : 'accessing' }
NTTodoContainer >> tags [
	"Answer the receiver's <Collection> of <NTNoteObject>"

	^ tags
]

{ #category : 'accessing' }
NTTodoContainer >> tags: aCollection [

	tags := aCollection
]

{ #category : 'accessing - notes' }
NTTodoContainer >> tagsNameMatching: aString [
	"Answer a <Collection> with <NoteObject> objects whose title matched named aString"

	| pattern |
	pattern := '*' , aString , '*'.
	^ self tags select: [ :n | pattern match: n tagName ]
]

{ #category : 'accessing - notes' }
NTTodoContainer >> tasks [
	"Answer the receiver's <Collection> of <NTNoteObject>"

	^ tasks
]

{ #category : 'accessing - notes' }
NTTodoContainer >> tasks: aCollection [ 
	tasks := aCollection
]

{ #category : 'accessing - notes' }
NTTodoContainer >> tasksTitleMatching: aString [
	"Answer a <Collection> with <NoteObject> objects whose title matched named aString"

	| pattern |
	pattern := '*' , aString , '*'.
	^ self tasks select: [ :t | pattern match: t title ]
]
