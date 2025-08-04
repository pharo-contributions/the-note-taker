Class {
	#name : 'NTInBox',
	#superclass : 'NTTodoTag',
	#category : 'TheNoteTaker-Todo',
	#package : 'TheNoteTaker-Todo'
}

{ #category : 'initialization' }
NTInBox >> initialize [

	super initialize.
	self tagName: 'In Box'
]
