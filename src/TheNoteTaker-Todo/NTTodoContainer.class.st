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
		'tasks'
	],
	#category : 'TheNoteTaker-Todo',
	#package : 'TheNoteTaker-Todo'
}

{ #category : 'adding - notes' }
NTTodoContainer >> addTask: aNTTodo [

	self tasks add: aNTTodo
]

{ #category : 'adding - notes' }
NTTodoContainer >> getDefaultTask [

	self addTask: (NTTodo new
			 title: 'Chercher le pain').
	self addTask: (NTTodo new
			 title: 'Reviser';
			 isRecurrent: true).
	self addTask: (NTTodo new
			 title: 'Machin 1 ').
	self addTask: (NTTodo new
			 title: 'Machin 2 ').
	self addTask: (NTTodo new
			 title: 'Machin 3')
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

	^ self tasks select: [ :t | t limitDate asDate weeks equals: Date today weeks ]
]

{ #category : 'accessing - notes' }
NTTodoContainer >> initialize [

	tasks := OrderedCollection new.

	self getDefaultTask
]

{ #category : 'removing - notes' }
NTTodoContainer >> removetasks: aCollectionOfNTTodo [
	"Remove the note aNTNoteObject from the receiver's notes. Answer the receiver"
	
	self tasks removeAll: aCollectionOfNTTodo
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
