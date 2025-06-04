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
		title: aString;
		contents: contentsString;
		yourself
]

{ #category : 'instance creation' }
NTNoteObject class >> newFromFileReference: aFileReference [

	^ self new
		  fileReference: aFileReference;
		  title: aFileReference basename;
		  contents: aFileReference contents;
		  yourself
]

{ #category : 'accessing' }
NTNoteObject >> addMetaDataElements [

	| root newDoc |
	self fileReference ensureCreateFile.
	root := MicrodownParser parse: self fileReference contents.

	root hasMetaDataElement
		ifFalse: [
"pay attention MD is line based. so the } should be on another line."
			newDoc := MicrodownParser parse: '{ 
"author" : "addos" 
}'.
			root addChild: newDoc children first. 
			"yes the metadata element in the first one.
			The API of Microdown could be better."
			root metaDataElement
				atKey: 'author' 
				put: 'toto for now';
				
				atKey: 'title' 
				put: self title;
				
				atKey: 'lastModificationDate'
				put: self fileReference modificationTime asDate yyyymmdd ]
		ifTrue: [
			root metaDataElement
				atKey: 'lastModificationDate'
				put: self fileReference modificationTime asDate yyyymmdd ].
			
	^ (MicTextualMicrodownExporter new visit: root) contents
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
	self modificationDate: DateAndTime now
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

	^ self fileReference exists
]

{ #category : 'testing' }
NTNoteObject >> existsAsFile [
	"Answer <true> if the receiver is present as <FileReference> in the current directory"

	^ self hasTitle and: [ self nameForFile asFileReference exists ]
]

{ #category : 'testing' }
NTNoteObject >> fileName [

	^ fileName ifNil: [ fileName := fileNamer newNameBasedOn: self title ]
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

	^ fileReference ifNil: [
		  fileReference := FileSystem workingDirectory / self fileName ]
]

{ #category : 'accessing' }
NTNoteObject >> fileReference: aFileReference [

	fileReference := aFileReference.
	fileName := aFileReference basenameWithoutExtension.
]

{ #category : 'testing' }
NTNoteObject >> hasTitle [

	^ self title notNil.
]

{ #category : 'accessing' }
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

{ #category : 'accessing' }
NTNoteObject >> nameForFile [

	^ String streamContents: [ :stream |
		stream 
			<< self title asLowercase ]
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

{ #category : 'accessing' }
NTNoteObject >> save [

	self fileReference writeStreamDo: [ :str | 
		str nextPutAll: self addMetaDataElements.
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

	^ title ifNil: [ title := fileNamer defaultEmptyName ]
]

{ #category : 'accessing' }
NTNoteObject >> title: aString [

	"title := fileNamer curateString: aString"
	title := aString
]
