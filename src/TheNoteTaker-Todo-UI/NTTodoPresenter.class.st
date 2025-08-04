Class {
	#name : 'NTTodoPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'task'
	],
	#category : 'TheNoteTaker-Todo-UI-Core',
	#package : 'TheNoteTaker-Todo-UI',
	#tag : 'Core'
}

{ #category : 'accessing' }
NTTodoPresenter >> defaultLayout [

	^ SpBoxLayout new beLeftToRight add: task title; yourself
]

{ #category : 'accessing' }
NTTodoPresenter >> task [ 

	^ task
]

{ #category : 'accessing' }
NTTodoPresenter >> task: aTask [

	task := aTask 
]
