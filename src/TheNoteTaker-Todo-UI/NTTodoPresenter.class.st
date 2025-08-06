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

	^ SpBoxLayout new beTopToBottom
		  add: task title;
		  add: task limitDate;
		  yourself
]

{ #category : 'accessing' }
NTTodoPresenter >> task [ 

	^ task
]

{ #category : 'accessing' }
NTTodoPresenter >> task: aTask [

	task := aTask 
]
