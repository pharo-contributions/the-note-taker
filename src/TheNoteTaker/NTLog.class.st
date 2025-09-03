"
I represent a log of actions for tracing the tool behavior. 
Here are the actions that are logged:

- addition of a tag to a note
- note creation
- removal of a note
- removal of a tag
- save of a note

In addition my contents can be save into file.
"
Class {
	#name : 'NTLog',
	#superclass : 'Object',
	#traits : 'TObservable',
	#classTraits : 'TObservable classTrait',
	#instVars : [
		'#logFileReference',
		'#lastLogString => ObservableSlot'
	],
	#category : 'TheNoteTaker',
	#package : 'TheNoteTaker'
}

{ #category : 'instance creation' }
NTLog class >> newWithFolder: aFileReference [

	^ self new logFileReference:
		aFileReference
]

{ #category : 'actions' }
NTLog >> add: aNTNoteObjet tag: aNTTag [

	^self write: 'tag ' , aNTTag tagName , ' has been add to the note '
		, aNTNoteObjet fileName
]

{ #category : 'actions' }
NTLog >> create: aNTNoteObjet [

	^ self write: 'file ' , aNTNoteObjet fileName , ' has been created'
]

{ #category : 'initialization' }
NTLog >> initialize [

	self class initializeSlots: self.
	super initialize.
	lastLogString := ''
]

{ #category : 'accessing' }
NTLog >> logFileReference [

	^ logFileReference
]

{ #category : 'accessing' }
NTLog >> logFileReference: aFileReference [

	logFileReference := aFileReference / 'TheNoteTaker.log'
]

{ #category : 'actions' }
NTLog >> remove: aNTNoteObjet [

	^ self write: 'file ' , aNTNoteObjet fileName , ' has been deleted'
]

{ #category : 'actions' }
NTLog >> remove: aNTNoteObjet tag: aNTTag [

	^ self write:
		'tag ' , aNTTag tagName , ' has been removed to the note '
		, aNTNoteObjet fileName
]

{ #category : 'actions' }
NTLog >> save: aNTNoteObjet [

	^ self write: 'file ' , aNTNoteObjet fileName , ' has been saved'
]

{ #category : 'events' }
NTLog >> whenWriteDo: aBlock [

	self
		property: #lastLogString
		whenChangedDo: [ aBlock cull: lastLogString ]
]

{ #category : 'actions' }
NTLog >> write: aString [

	logFileReference writeStreamDo: [ :str |
			str
				setToEnd;
				nextPutAll: DateAndTime now printString;
				nextPutAll: ', ';
				nextPutAll: aString;
				nextPut: Character cr ].
	lastLogString := aString.
	^ aString
]
