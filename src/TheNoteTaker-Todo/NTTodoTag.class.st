"
A note tag object contains the necessary attributes and methods to represent a tag associated with notes.

## Attributes

- tagName: A string representing the name or label of the tag.
- notes: A collection (list, set, or other data structure) of notes associated with the tag.

## Main methods

- Add Note: To associate a note with the tag.
- Remove Note: To disassociate a note from the tag.
- Rename Tag: To change the name of the tag.
- Delete Tag: To remove the tag entirely.
- Get Notes: To retrieve all notes associated with the tag.
- Accesss tag name: To retrieve the name of the tag.

"
Class {
	#name : 'NTTodoTag',
	#superclass : 'Object',
	#instVars : [
		'tasks',
		'tagName'
	],
	#category : 'TheNoteTaker-Todo',
	#package : 'TheNoteTaker-Todo'
}

{ #category : 'instance creation' }
NTTodoTag class >> newNamed: aString [
	"Answer a new tag named aString"
	
	^ self new 
		tagName: aString;
		yourself
]

{ #category : 'adding' }
NTTodoTag >> addTask: aTask [

	self tasks add: aTask.
	aTask addTag: self
]

{ #category : 'accessing' }
NTTodoTag >> hasTask: aTask [

	^ tasks includes: aTask
]

{ #category : 'initialization' }
NTTodoTag >> initialize [

	super initialize.
	self tasks: Set new
]

{ #category : 'removing' }
NTTodoTag >> removeNote: aNTNoteObject [

	self notes remove: aNTNoteObject ifAbsent: [ ]
]

{ #category : 'removing' }
NTTodoTag >> removeTask: aTask [

	self tasks remove: aTask ifAbsent: [ ]
]

{ #category : 'accessing' }
NTTodoTag >> tagName [
	"Answer a <String> representing the receiver's name"
	
	^ tagName
]

{ #category : 'accessing' }
NTTodoTag >> tagName: anObject [

	tagName := anObject
]

{ #category : 'accessing' }
NTTodoTag >> tasks [

	^ tasks
]

{ #category : 'accessing' }
NTTodoTag >> tasks: aTask [

	tasks := aTask
]
