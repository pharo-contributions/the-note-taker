Class {
	#name : 'NTToday',
	#superclass : 'NTTodoTag',
	#category : 'TheNoteTaker-Todo',
	#package : 'TheNoteTaker-Todo'
}

{ #category : 'initialization' }
NTToday >> initialize [

	super initialize.
	self tagName: 'Today'
]
