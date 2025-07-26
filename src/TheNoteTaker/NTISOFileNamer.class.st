"
I will name file following the give pattern

- Iso date e.g. 2024-05-18
- a separator
- a body (alpha numeric only)
- an extension
"
Class {
	#name : 'NTISOFileNamer',
	#superclass : 'NTFileNamer',
	#instVars : [
		'date'
	],
	#category : 'TheNoteTaker-Utilities',
	#package : 'TheNoteTaker',
	#tag : 'Utilities'
}

{ #category : 'naming' }
NTISOFileNamer >> basicDecoratedName: aString [

	| ymd |
	ymd := self date yyyymmdd.
	^ ymd , self separatorString , (self addExtensionIfNeeded:( super newNameBasedOn: aString)).
]

{ #category : 'naming' }
NTISOFileNamer >> buildNameFromParts: aCollection [
	"Answer a String representing the receiver's file name"

	(DateParser
		 readingFrom: aCollection first readStream
		 pattern: 'yyyy-mm-dd') parse.
	^ aCollection first , self separatorString
	  , (self curateParts: aCollection allButFirst)
]

{ #category : 'naming' }
NTISOFileNamer >> date [

	^ date ifNil: [ date := Date today ]
]

{ #category : 'naming' }
NTISOFileNamer >> date: aDate [

	date := aDate
]

{ #category : 'naming' }
NTISOFileNamer >> extractBaseNameFrom: aString [
	"Answer a String representing the receiver's file name"

	| splits |
	splits := (aString withoutSuffix: '.md') splitOn:
		          self separatorString.
	"let us see if it is raising an error"
	^ self titleFromParts: splits allButFirst
]

{ #category : 'naming' }
NTISOFileNamer >> extractBaseNameFromParts: aCollection [
	"Answer a String representing the receiver's file name"

	"let us see if it is raising an error"

	(DateParser
		 readingFrom: aCollection first readStream
		 pattern: 'yyyy-mm-dd') parse.
	^ (self curateParts: aCollection allButFirst)
]

{ #category : 'naming' }
NTISOFileNamer >> fullnameFromParts: aCollection [
	"Answer a String representing the receiver's file name"

	(DateParser
		 readingFrom: aCollection first readStream
		 pattern: 'yyyy-mm-dd') parse.
	^ aCollection first , self separatorString , (self curateParts: aCollection allButFirst)
]

{ #category : 'naming' }
NTISOFileNamer >> newNameBasedOn: aString [
	"Answer a String representing the receiver's file name with extension."

	| splits withoutExtension |
	withoutExtension := aString withoutSuffix: '.md'.
	splits := withoutExtension splitOn: self separatorString.
	^ self addExtensionIfNeeded: (splits size = 1
			   ifTrue: [ self basicDecoratedName: aString ]
			   ifFalse: [ self fullnameFromParts: splits ])
]

{ #category : 'naming' }
NTISOFileNamer >> titleFromParts: aCollection [
	"Answer a String representing the receiver's file name"

	^ self curateParts: aCollection
]
