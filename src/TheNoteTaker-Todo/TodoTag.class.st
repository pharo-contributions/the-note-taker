"
A task tag object contains the necessary attributes and methods to represent a tag associated with tasks.
(Similar to NTTag, who is the same object for the note, maybe refactor by make a generic object Tag for all object)  

## Attributes

- tagName: A string representing the name or label of the tag.
- tasks: A collection (list, set, or other data structure) of tasks associated with the tag.

## Main methods

- Add Task: To associate a task with the tag.
- Remove Task To disassociate a task from the tag.
- Rename Tag: To change the name of the tag.
- Delete Tag: To remove the tag entirely.
- Get Tasks: To retrieve all tasks associated with the tag.
- Accesss tag name: To retrieve the name of the tag.

"
Class {
	#name : 'TodoTag',
	#superclass : 'Object',
	#instVars : [
		'tasks',
		'tagName'
	],
	#category : 'TheNoteTaker-Todo',
	#package : 'TheNoteTaker-Todo'
}

{ #category : 'instance creation' }
TodoTag class >> newNamed: aString [
	"Answer a new tag named aString"
	
	^ self new 
		tagName: aString;
		yourself
]

{ #category : 'adding' }
TodoTag >> addTask: aTask [

	self tasks add: aTask.
	aTask addTag: self
]

{ #category : 'accessing' }
TodoTag >> hasTask: aTask [

	^ tasks includes: aTask
]

{ #category : 'initialization' }
TodoTag >> initialize [

	super initialize.
	self tasks: Set new
]

{ #category : 'removing' }
TodoTag >> removeTask: aTask [

	self tasks remove: aTask ifAbsent: [ ]
]

{ #category : 'accessing' }
TodoTag >> tagName [
	"Answer a <String> representing the receiver's name"
	
	^ tagName
]

{ #category : 'accessing' }
TodoTag >> tagName: anObject [

	tagName := anObject
]

{ #category : 'accessing' }
TodoTag >> tasks [

	^ tasks
]

{ #category : 'accessing' }
TodoTag >> tasks: aTask [

	tasks := aTask
]
