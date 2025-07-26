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
		'folderReference',
		'fileNamer',
		'fileName',
		'tagsString'
	],
	#category : 'TheNoteTaker-Core',
	#package : 'TheNoteTaker',
	#tag : 'Core'
}

{ #category : 'instance creation' }
NTNoteObject class >> named: aString [
	"Answer a new instance of the receiver with title aString"

	| note |
	note := self new.

	^ note
		  contents: aString;
		  modificationDate: note creationDate;
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
		  folderReference: aFileReference parent;
		  fileName: aFileReference basename;
		  loadFileContents: aFileReference contents;
		  yourself
]

{ #category : 'accessing - tags' }
NTNoteObject >> addTag: aNTTag [

	self tags
		detect: [ :tag | tag tagName = aNTTag tagName ]
		ifNone: [ self tags add: aNTTag ]
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

	^ folderReference ifNil: [ ^ false ] ifNotNil: [ self fileReference exists]
]

{ #category : 'accessing' }
NTNoteObject >> fileName [

	fileNamer date: creationDate asDate.
	^ fileName ifNil: [
			  self title ifNotEmpty: [
					  fileName := fileNamer newNameBasedOn: self title
						              "(NTFileNamer new newNameBasedOn: self title)" ] ]
]

{ #category : 'accessing' }
NTNoteObject >> fileName: aString [

	"fileName := aString"
	fileName := fileNamer newNameBasedOn: aString
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

	^ folderReference / (self fileName)
]

{ #category : 'accessing' }
NTNoteObject >> fileReferenceContents [

	| fileContentsPart aString |
	
	aString := self fileReference contents.
	(self fileReference contents beginsWith: '{')
		ifTrue: [
				fileContentsPart := aString substrings: '}'.
				^ fileContentsPart second withoutPrefix: String crlf , String crlf].
		^ aString
]

{ #category : 'accessing' }
NTNoteObject >> folderReference: aFileReference [

	folderReference := aFileReference.
]

{ #category : 'generate' }
NTNoteObject >> generateMetaDataElements [

	| meta |
	meta := MicMetaDataBlock new.
	meta body: Dictionary new.
	meta
		atKey: 'creationDate' put: self creationDate asString;
		atKey: 'lastModificationDate' put: self modificationDate asString.
	self tags ifNotEmpty: [ meta atKey: 'tags' put: self tagsNameString ].

	^ (MicTextualMicrodownExporter new visit: meta) contents
]

{ #category : 'generate' }
NTNoteObject >> generateTitle [
	"create a new title which corresponds to the first line of the contents"

	| nameOfNewNote collectionOfContents |
	collectionOfContents := contents substrings: String crlf.
	nameOfNewNote := String streamContents: [ :stt |
			                 collectionOfContents isNotEmpty
				                 ifTrue: [
				                 stt nextPutAll: collectionOfContents first ]
				                 ifFalse: [ stt nextPutAll: 'unnamed' ] ].

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

	^ (contents = self fileReferenceContents) not
]

{ #category : 'testing' }
NTNoteObject >> isNote [

	^ true
]

{ #category : 'loading' }
NTNoteObject >> loadFileContents: aString [

	| fileContentsPart |
	(aString beginsWith: '{')
		ifTrue: [
				fileContentsPart := aString substrings: '}'.
				self contents:
					(fileContentsPart second withoutPrefix: String crlf , String crlf).
				self loadMetaData: fileContentsPart first ]
		ifFalse: [self contents: aString]
]

{ #category : 'loading' }
NTNoteObject >> loadMetaData: aString [

	| metaData |
	metaData := (MicrodownParser parse: aString) metaDataElement.
	self creationDate:
		(metaData at: 'creationDate' ifAbsent: DateAndTime now)
			asDateAndTime.
	self modificationDate:
		(metaData at: 'lastModificationDate' ifAbsent: self creationDate)
			asDateAndTime.
	tagsString := metaData at: 'tags' ifAbsent: [ ^ self ]
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

	self tags remove: aNTTag ifAbsent: [ ^ self ].
	aNTTag removeNote: self
]

{ #category : 'saving' }
NTNoteObject >> save [

	folderReference ifNil: [  folderReference := FileSystem workingDirectory ].

	self exists ifTrue: [ self fileReference delete ].

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

{ #category : 'accessing - tags' }
NTNoteObject >> tagsNameString [
	"Answer a <String> to be displayed"

	| tagsNameList |
	self tags ifEmpty: [ ^ '' ].

	tagsNameList := self tags collect: [ :each | each tagName ].
	^ (tagsNameList asOrderedCollection sorted: [ :a :b | a < b ])
		  joinUsing: ','
]

{ #category : 'accessing' }
NTNoteObject >> tagsString [

	^ tagsString 
]

{ #category : 'sorting' }
NTNoteObject >> threeWayCompareTo: aNTNoteObject [ 
	^ self creationDate > aNTNoteObject creationDate
]

{ #category : 'accessing' }
NTNoteObject >> title [
	
	title ifNotNil: [ ^ title ].
	self generateTitle.
	^ title
]

{ #category : 'accessing' }
NTNoteObject >> title: aString [

	title := aString
]
