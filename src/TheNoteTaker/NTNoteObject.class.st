"
It represents a single note. A note is composed of a title and its content, both of them a `String`.
"
Class {
	#name : 'NTNoteObject',
	#superclass : 'Object',
	#instVars : [
		'title',
		'creationDate',
		'modificationDate',
		'tags',
		'contents',
		'fileReference',
		'fileNamer',
		'fileName'
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

{ #category : 'instance creation' }
NTNoteObject class >> named: aString contents: contentsString [
	"Answer a new instance of the receiver with title aString"
	
	^ self new
		fileName: aString;
		contents: contentsString;
		yourself
]

{ #category : 'instance creation' }
NTNoteObject class >> newFromFileReference: aFileReference [

	^ self new
		  folderReference: aFileReference;
		  fileName: aFileReference basenameWithoutExtension;
		  contents: aFileReference contents;
		  yourself
]

{ #category : 'accessing - tags' }
NTNoteObject >> addTag: aNTTag [ 

	self tags add: aNTTag
]

{ #category : 'accessing' }
NTNoteObject >> contents [

	^ contents
]

{ #category : 'accessing' }
NTNoteObject >> contents: anObject [

	contents := anObject.
	self modificationDate: DateAndTime now.
	self generateTitle
]

{ #category : 'accessing' }
NTNoteObject >> creationDate [

	^ creationDate
]

{ #category : 'accessing' }
NTNoteObject >> creationDate: anObject [

	creationDate := anObject
]

{ #category : 'testing' }
NTNoteObject >> exists [

	^ self fileReference ifNil: [ ^ false ] ifNotNil: [ self fileReference exists]
]

{ #category : 'accessing' }
NTNoteObject >> fileName [

	^ fileName ifNil: [ fileName := fileNamer newNameBasedOn: self title ]
]

{ #category : 'accessing' }
NTNoteObject >> fileName: aString [

	fileName := aString
]

{ #category : 'accessing' }
NTNoteObject >> fileNamer [

	^ fileNamer
]

{ #category : 'accessing' }
NTNoteObject >> fileNamer: anObject [

	fileNamer := anObject
]

{ #category : 'accessing' }
NTNoteObject >> fileReference [ 

	^ fileReference
]

{ #category : 'accessing' }
NTNoteObject >> folderReference: aFileReference [

	fileReference := aFileReference.
]

{ #category : 'generate' }
NTNoteObject >> generateDefaultFileReference [
	
	self folderReference: FileReference / (NTSettings projectPathString ) / 'notes'
]

{ #category : 'generate' }
NTNoteObject >> generateMetaDataElements [

	| meta |
	meta := MicMetaDataBlock new.
	meta body: Dictionary new.
	meta
		atKey: 'author' put: 'toto for now';
		atKey: 'title' put: self title;
		atKey: 'lastModificationDate'
		put: self modificationDate asDate yyyymmdd.

	^ (MicTextualMicrodownExporter new visit: meta) contents
]

{ #category : 'generate' }
NTNoteObject >> generateTitle [

"create a new title which corresponds to the first word of the contents.
	If the contents has more than three words, the title correponds to its first three words. "

	| nameOfNewNote collectionOfContents |
	collectionOfContents := contents substrings.
	nameOfNewNote := String streamContents: [ :stt |
		(collectionOfContents size > 3
			ifTrue: [ collectionOfContents copyFrom: 1 to: 3 ]
			ifFalse: [ collectionOfContents ]) 
				do: [ :each | stt nextPutAll: each, String space ] ].
			
	self title: nameOfNewNote
]

{ #category : 'testing' }
NTNoteObject >> hasTitle [

	^ self title notNil.
]

{ #category : 'initialization' }
NTNoteObject >> initialize [

	super initialize.
	contents := String empty.
	creationDate := DateAndTime now.
	modificationDate := creationDate.
	tags := Set new.
	fileNamer := NTISOFileNamer new.
]

{ #category : 'testing' }
NTNoteObject >> isDirty [ 

	^ (contents equals: fileReference contents) not
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
		<< (self hasTitle
			ifFalse: [ 'no title' ]
			ifTrue: [ self title asString ]);
		<< ']'
]

{ #category : 'accessing - tags' }
NTNoteObject >> removeTag: aNTTag [ 

	self tags 
		remove: aNTTag 
		ifAbsent: [ ].
	aNTTag removeNote: self
]

{ #category : 'saving' }
NTNoteObject >> save [
	
	fileReference ifNil: [ self generateDefaultFileReference ].
	fileReference := fileReference / (self fileName).
	
	self fileReference writeStreamDo: [ :str | 
		str nextPutAll: self generateMetaDataElements.
		str nextPutAll: String crlf.
		str nextPutAll: String crlf.
		str nextPutAll: contents ]
]

{ #category : 'accessing - tags' }
NTNoteObject >> tags [

	^ tags
]

{ #category : 'accessing - tags' }
NTNoteObject >> tags: anObject [

	tags := anObject
]

{ #category : 'sorting' }
NTNoteObject >> threeWayCompareTo: aNTNoteObject [ 
	^ self creationDate > aNTNoteObject creationDate
]

{ #category : 'accessing' }
NTNoteObject >> title [

	^ title ifNil: [ self generateTitle ]
]

{ #category : 'accessing' }
NTNoteObject >> title: aString [

	title := aString
]
