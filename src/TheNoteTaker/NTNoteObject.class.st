"
It represents a single note. A note is composed of a title and its content, both of them a `String`.
"
Class {
	#name : 'NTNoteObject',
	#superclass : 'Object',
	#instVars : [
		'title',
		'content',
		'creationDate',
		'modificationDate',
		'tags'
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

{ #category : 'accessing' }
NTNoteObject >> content [

	^ content
]

{ #category : 'accessing' }
NTNoteObject >> content: anObject [

	content := anObject
]

{ #category : 'accessing' }
NTNoteObject >> creationDate [

	^ creationDate
]

{ #category : 'accessing' }
NTNoteObject >> creationDate: anObject [

	creationDate := anObject
]

{ #category : 'initialization' }
NTNoteObject >> initialize [

	super initialize.
	content := String empty.
	creationDate := DateAndTime now.
	tags := OrderedCollection new.
]

{ #category : 'testing' }
NTNoteObject >> isNote [

	^ true
]

{ #category : 'accessing' }
NTNoteObject >> modificationDate [

	^ modificationDate
]

{ #category : 'accessing' }
NTNoteObject >> modificationDate: anObject [

	modificationDate := anObject
]

{ #category : 'printing' }
NTNoteObject >> printOn: aStream [

	super printOn: aStream.
	aStream 
		<< '[';
		<< self title;
		<< ']'
]

{ #category : 'accessing' }
NTNoteObject >> tags [

	^ tags
]

{ #category : 'accessing' }
NTNoteObject >> tags: anObject [

	tags := anObject
]

{ #category : 'accessing' }
NTNoteObject >> title [

	^ title
]

{ #category : 'accessing' }
NTNoteObject >> title: anObject [

	title := anObject
]
