Class {
	#name : 'NTTodo',
	#superclass : 'Object',
	#instVars : [
		'title',
		'description',
		'tags',
		'limitDate',
		'isRecurrent',
		'state'
	],
	#category : 'TheNoteTaker-Todo',
	#package : 'TheNoteTaker-Todo'
}

{ #category : 'accessing' }
NTTodo >> description [

	^ description
]

{ #category : 'accessing' }
NTTodo >> description: anObject [

	description := anObject
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
NTTodo >> limitDate [

	^ limitDate
]

{ #category : 'accessing' }
NTTodo >> limitDate: anObject [

	limitDate := anObject
]

{ #category : 'accessing' }
NTTodo >> state [

	^ state
]

{ #category : 'accessing' }
NTTodo >> state: anObject [

	state := anObject
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
