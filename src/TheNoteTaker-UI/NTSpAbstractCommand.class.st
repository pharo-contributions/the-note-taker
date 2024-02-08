Class {
	#name : 'NTSpAbstractCommand',
	#superclass : 'CmCommand',
	#category : 'TheNoteTaker-UI-Commands',
	#package : 'TheNoteTaker-UI',
	#tag : 'Commands'
}

{ #category : 'accessing' }
NTSpAbstractCommand >> application [

	^ self context application
]

{ #category : 'accessing' }
NTSpAbstractCommand >> applicationClass [

	^ self application class
]

{ #category : 'accessing' }
NTSpAbstractCommand >> notesIndex [

	^ self context notesIndex
]
