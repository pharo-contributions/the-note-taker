"
Represent the log file of folder open in TheNoteTaker
"
Class {
	#name : 'NTLog',
	#superclass : 'Object',
	#instVars : [
		'logFileReference'
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

{ #category : 'actions' }
NTLog >> write: aString [

	logFileReference exists ifFalse: [ logFileReference ensureCreateFile ].
	logFileReference writeStreamDo: [ :str |
			str
				setToEnd;
				nextPutAll: DateAndTime now printString;
				nextPutAll: ', ';
				nextPutAll: aString;
				nextPut: Character cr ].
	^ aString
]
