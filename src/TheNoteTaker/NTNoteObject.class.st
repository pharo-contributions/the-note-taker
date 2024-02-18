Class {
	#name : 'NTNoteObject',
	#superclass : 'Object',
	#instVars : [
		'title'
	],
	#category : 'TheNoteTaker-Core',
	#package : 'TheNoteTaker',
	#tag : 'Core'
}

{ #category : 'instance creation' }
NTNoteObject class >> named: aString [ 
	"Answer a new instance of the receiver with title aString"
	
	^ self new
		title: aString;
		yourself
]

{ #category : 'testing' }
NTNoteObject >> isNote [

	^ true
]

{ #category : 'accessing' }
NTNoteObject >> title [

	^ title
]

{ #category : 'accessing' }
NTNoteObject >> title: anObject [

	title := anObject
]
