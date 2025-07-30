"
It represents a single note. A note is composed of a title and its content, both of them a `String`.
"
Class {
	#name : 'NTNote',
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
NTNote class >> content: aString [
	"Answer a new instance of the receiver with title aString"

	| note |
	note := self new.

	^ note
		  contents: aString;
		  modificationDate: note creationDate;
		  yourself
]

{ #category : 'instance creation' }
NTNote class >> newFromFileReference: aFileReference [

	^ self new
		  folderReference: aFileReference parent;
		  fileName: aFileReference basename;
		  loadFileContents: aFileReference contents;
		  yourself
]

{ #category : 'accessing - tags' }
NTNote >> addTag: aNTTag [

	self tags detect: [ :tag | tag tagName = aNTTag tagName ] ifNone: [
			self tags add: aNTTag.
			aNTTag addNote: self ]
]

{ #category : 'accessing' }
NTNote >> contents [

	^ contents
]

{ #category : 'accessing' }
NTNote >> contents: anObject [

	contents := anObject.
	self modificationDate: DateAndTime now.
	self generateTitle
]

{ #category : 'accessing' }
NTNote >> creationDate [

	^ creationDate
]

{ #category : 'accessing' }
NTNote >> creationDate: aDateAndTime [

	creationDate := aDateAndTime.
	fileNamer date: creationDate asDate.
]

{ #category : 'testing' }
NTNote >> exists [

	^ folderReference ifNil: [ ^ false ] ifNotNil: [ self fileReference exists]
]

{ #category : 'accessing' }
NTNote >> fileName [

	^ fileName ifNil: [
			  self title ifNotEmpty: [
					  fileName := fileNamer newNameBasedOn: self title
					  "(NTFileNamer new newNameBasedOn: self title)" ] ]
]

{ #category : 'accessing' }
NTNote >> fileName: aString [

	"fileName := aString"
	fileName := fileNamer newNameBasedOn: aString
]

{ #category : 'accessing' }
NTNote >> fileNamer [

	^ fileNamer
]

{ #category : 'accessing' }
NTNote >> fileNamer: anObject [

	fileNamer := anObject
]

{ #category : 'accessing' }
NTNote >> fileReference [ 

	^ folderReference / (self fileName)
]

{ #category : 'accessing' }
NTNote >> fileReferenceContents [

	| fileContentsPart aString |
	
	aString := self fileReference contents.
	(self fileReference contents beginsWith: '{')
		ifTrue: [
				fileContentsPart := aString substrings: '}'.
				^ fileContentsPart second withoutPrefix: String crlf , String crlf].
		^ aString
]

{ #category : 'accessing' }
NTNote >> folderReference: aFileReference [

	folderReference := aFileReference.
]

{ #category : 'generate' }
NTNote >> generateMetaDataElements [

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
NTNote >> generateTitle [
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
NTNote >> hasTitle [

	^ self title notNil.
]

{ #category : 'initialization' }
NTNote >> initialize [

	super initialize.
	fileNamer := NTISOFileNamer new.
	contents := String empty.
	creationDate := DateAndTime now.
	modificationDate := creationDate.
	tags := Set new
]

{ #category : 'testing' }
NTNote >> isDirty [ 

	^ (contents = self fileReferenceContents) not
]

{ #category : 'testing' }
NTNote >> isNote [

	^ true
]

{ #category : 'loading' }
NTNote >> loadFileContents: aString [

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
NTNote >> loadMetaData: aString [

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
NTNote >> modificationDate [

	^ modificationDate
]

{ #category : 'accessing' }
NTNote >> modificationDate: aDateAndTime [

	modificationDate := aDateAndTime
]

{ #category : 'printing' }
NTNote >> printOn: aStream [

	super printOn: aStream.
	aStream 
		<< '[';
		<< (self hasTitle
			ifFalse: [ 'no title' ]
			ifTrue: [ self title asString ]);
		<< ']'
]

{ #category : 'accessing - tags' }
NTNote >> removeTag: aNTTag [

	self tags remove: aNTTag ifAbsent: [ ^ self ].
	aNTTag removeNote: self
]

{ #category : 'saving' }
NTNote >> save [

	folderReference ifNil: [
		folderReference := FileSystem workingDirectory ].

	self fileReference ensureDelete.

	self fileReference writeStreamDo: [ :str |
			str nextPutAll: self generateMetaDataElements.
			str nextPutAll: String crlf.
			str nextPutAll: String crlf.
			str nextPutAll: contents ]
]

{ #category : 'accessing - tags' }
NTNote >> tags [

	^ tags
]

{ #category : 'accessing - tags' }
NTNote >> tags: anObject [

	tags := anObject
]

{ #category : 'accessing - tags' }
NTNote >> tagsNameString [
	"Answer a <String> to be displayed"

	| tagsNameList |
	self tags ifEmpty: [ ^ '' ].

	tagsNameList := self tags collect: [ :each | each tagName ].
	^ (tagsNameList asOrderedCollection sorted: [ :a :b | a < b ])
		  joinUsing: ','
]

{ #category : 'accessing' }
NTNote >> tagsString [

	^ tagsString 
]

{ #category : 'sorting' }
NTNote >> threeWayCompareTo: aNTNoteObject [ 
	^ self creationDate > aNTNoteObject creationDate
]

{ #category : 'accessing' }
NTNote >> title [
	
	title ifNotNil: [ ^ title ].
	self generateTitle.
	^ title
]

{ #category : 'accessing' }
NTNote >> title: aString [

	title := aString
]
