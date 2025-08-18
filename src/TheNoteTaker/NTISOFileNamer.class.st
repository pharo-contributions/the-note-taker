"
I represent a file name with the following structure:

- A first part with an iso date: 2025-08-16
- a list of parts separated by a separator where a part can only contain alpha numerical characters.
- finished with an extension

Here it is an example
```
2025-08-16_nenuphar_collection.md
```

"
Class {
	#name : 'NTISOFileNamer',
	#superclass : 'Object',
	#instVars : [
		'date'
	],
	#category : 'TheNoteTaker-Utilities',
	#package : 'TheNoteTaker',
	#tag : 'Utilities'
}

{ #category : 'accessing' }
NTISOFileNamer >> date [

	^ date ifNil: [ date := Date today ]
]

{ #category : 'accessing' }
NTISOFileNamer >> date: aDate [

	date := aDate
]

{ #category : 'accessing' }
NTISOFileNamer >> defaultEmptyName [

	^ 'unnamed'
]

{ #category : 'testing' }
NTISOFileNamer >> isDate: aString [

	[
		(DateParser readingFrom: aString readStream pattern: 'yyyy-mm-dd')
			parse ]
		on: DateError
		do: [ ^ false ].
	^ true
]

{ #category : 'instance creation' }
NTISOFileNamer >> newNameBasedOn: aString [
	"Answer a String representing the receiver's file name with extension."

	| splits |
	splits := (aString asFileReference fullPath withExtension: '') fullName splitOn:
		          self separatorString.

	^ String streamContents: [ :s |
			  (self isDate: splits first)
				  ifTrue: [
						  s nextPutAll: splits first.
						  splits := splits allButFirst ]
				  ifFalse: [ s nextPutAll: self date yyyymmdd ].
			  s nextPutAll: self separatorString.
			  splits
				  do: [ :each | self printCuratedParts: each on: s ]
				  separatedBy: [ s nextPutAll: self separatorString ].
			  s nextPutAll: '.md' ]
]

{ #category : 'initialization' }
NTISOFileNamer >> printCuratedParts: aCollection on: aStream [
	"Print a file name from parts of a name but where each part in only alphanumerical."

	(aCollection select: [ :part | part isAlphaNumeric ])
		ifEmpty: [ aStream nextPutAll: self defaultEmptyName ]
		ifNotEmpty: [ :parts | parts do: [ :part | aStream nextPut: part ] ]
]

{ #category : 'accessing' }
NTISOFileNamer >> separatorString [

	^ '_'
]
