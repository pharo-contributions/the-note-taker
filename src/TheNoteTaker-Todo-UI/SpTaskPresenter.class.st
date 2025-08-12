Class {
	#name : 'SpTaskPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'task'
	],
	#category : 'TheNoteTaker-Todo-UI-Core',
	#package : 'TheNoteTaker-Todo-UI',
	#tag : 'Core'
}

{ #category : 'accessing' }
SpTaskPresenter >> defaultLayout [

	^ SpBoxLayout new beTopToBottom
		  add: task title;
		  add: task limitDate;
		  yourself
]

{ #category : 'accessing' }
SpTaskPresenter >> task [ 

	^ task
]

{ #category : 'accessing' }
SpTaskPresenter >> task: aTask [

	task := aTask 
]
