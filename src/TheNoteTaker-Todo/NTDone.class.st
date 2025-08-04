Class {
	#name : 'NTDone',
	#superclass : 'NTTodoTag',
	#category : 'TheNoteTaker-Todo',
	#package : 'TheNoteTaker-Todo'
}

{ #category : 'initialization' }
NTDone >> initialize [

	super initialize.
	self tagName: 'Done'
]
