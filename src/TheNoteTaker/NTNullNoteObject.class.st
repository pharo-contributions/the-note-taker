"
Used when we need to represent null note object behavior
"
Class {
	#name : 'NTNullNoteObject',
	#superclass : 'Object',
	#category : 'TheNoteTaker-Core',
	#package : 'TheNoteTaker',
	#tag : 'Core'
}

{ #category : 'instance creation' }
NTNullNoteObject >> newFromPresenter: aNTSpNoteContentPresenter [ 

]

{ #category : 'accessing' }
NTNullNoteObject >> title [

	^ String empty
]
