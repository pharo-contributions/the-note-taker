"
I represent a task. I have:

- a name
- a description
- a limitDate
- a tags list
- isDone, a boolean for represent a finish task
- isTrash, a boolean for represent a task in a trash
- isRecurrent, a boolean for represent if a task need to be done everyday
( the isReccurent can be changed for a period, like day, weeks or another)
"
Class {
	#name : 'Task',
	#superclass : 'Object',
	#instVars : [
		'title',
		'description',
		'tags',
		'limitDate',
		'isRecurrent',
		'isDone',
		'isTrash'
	],
	#category : 'TheNoteTaker-Todo',
	#package : 'TheNoteTaker-Todo'
}

{ #category : 'accessing' }
Task >> addTag: aTag [

	tags add: aTag 
]

{ #category : 'accessing' }
Task >> description [

	^ description
]

{ #category : 'accessing' }
Task >> description: anObject [

	description := anObject
]

{ #category : 'accessing' }
Task >> initialize [

	isRecurrent := false.
	limitDate := Date tomorrow.
	isDone := false.
	tags := Set new.
	isTrash := false.
	title := ''.
	description := ''
]

{ #category : 'accessing' }
Task >> isDone [

	^ isDone
]

{ #category : 'accessing' }
Task >> isDone: anObject [

	isDone := anObject
]

{ #category : 'accessing' }
Task >> isRecurrent [

	^ isRecurrent
]

{ #category : 'accessing' }
Task >> isRecurrent: anObject [

	isRecurrent := anObject
]

{ #category : 'accessing' }
Task >> isTrash [

	^ isTrash
]

{ #category : 'accessing' }
Task >> isTrash: aBoolean [

	isTrash := aBoolean
]

{ #category : 'accessing' }
Task >> limitDate [

	^ limitDate
]

{ #category : 'accessing' }
Task >> limitDate: anObject [

	limitDate := anObject
]

{ #category : 'accessing' }
Task >> tags [

	^ tags
]

{ #category : 'accessing' }
Task >> tags: anObject [

	tags := anObject
]

{ #category : 'accessing' }
Task >> title [

	^ title
]

{ #category : 'accessing' }
Task >> title: anObject [

	title := anObject
]
