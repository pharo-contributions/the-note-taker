Class {
	#name : 'NTTodo',
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
NTTodo >> addTag: aTag [

	tags add: aTag 
]

{ #category : 'accessing' }
NTTodo >> description [

	^ description
]

{ #category : 'accessing' }
NTTodo >> description: anObject [

	description := anObject
]

{ #category : 'accessing' }
NTTodo >> initialize [

	isRecurrent := false.
	limitDate := Date tomorrow.
	isDone := false.
	tags := Set new.
	isTrash := false
]

{ #category : 'accessing' }
NTTodo >> isDone [

	^ isDone
]

{ #category : 'accessing' }
NTTodo >> isDone: anObject [

	isDone := anObject
]

{ #category : 'accessing' }
NTTodo >> isRecurrent [

	^ isRecurrent
]

{ #category : 'accessing' }
NTTodo >> isRecurrent: anObject [

	isRecurrent := anObject
]

{ #category : 'accessing' }
NTTodo >> isTrash [

	^ isTrash
]

{ #category : 'accessing' }
NTTodo >> isTrash: aBoolean [

	isTrash := aBoolean
]

{ #category : 'accessing' }
NTTodo >> limitDate [

	^ limitDate
]

{ #category : 'accessing' }
NTTodo >> limitDate: anObject [

	limitDate := anObject
]

{ #category : 'accessing' }
NTTodo >> tags [

	^ tags
]

{ #category : 'accessing' }
NTTodo >> tags: anObject [

	tags := anObject
]

{ #category : 'accessing' }
NTTodo >> title [

	^ title
]

{ #category : 'accessing' }
NTTodo >> title: anObject [

	title := anObject
]
