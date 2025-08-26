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
		'fileName'
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
		contents: aFileReference contents;
		  creationDate: aFileReference creationTime;
		  modificationDate: aFileReference modificationTime;
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

	creationDate := aDateAndTime
]

{ #category : 'testing' }
NTNote >> exists [

	^ self fileReference exists
]

{ #category : 'accessing' }
NTNote >> fileName [

	fileName ifNil: [
			self fileName: (NTISOFileNamer new
					 date: creationDate asDate;
					 newNameBasedOn: self title) ].
	^ fileName
]

{ #category : 'accessing' }
NTNote >> fileName: aString [

	fileName := aString
]

{ #category : 'accessing' }
NTNote >> fileReference [

	^ self folderReference / self fileName
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
NTNote >> folderReference [

	^ folderReference ifNil: [
		folderReference := FileSystem workingDirectory ].
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

	| collection |
	collection := (contents substrings: String crlf).
	collection isNotEmpty
		ifTrue: [ self title: collection first ]
		ifFalse: [ self title: 'unnamed' ]
]

{ #category : 'initialization' }
NTNote >> initialize [

	super initialize.
	contents := String empty.
	creationDate := DateAndTime now.
	modificationDate := creationDate.
	tags := Set new
]

{ #category : 'testing' }
NTNote >> isDirty [

	self exists ifFalse: [ ^ true ].
	^ contents ~= self fileReferenceContents
]

{ #category : 'testing' }
NTNote >> isNote [

	^ true
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
		<<  self title asString;
		<< ']'
]

{ #category : 'accessing - tags' }
NTNote >> removeTag: aNTTag [

	self tags remove: aNTTag ifAbsent: [ ^ self ].
	aNTTag removeNote: self
]

{ #category : 'saving' }
NTNote >> save [

	self fileReference ensureDelete.
	self fileReference writeStreamDo: [ :str |
			str << self generateMetaDataElements.
			str << String crlf.
			str << String crlf.
			str << contents ]
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
	tagsNameList := self tags collect: [ :each | each tagName ].
	^ (tagsNameList asOrderedCollection sorted: [ :a :b | a < b ])
		  joinUsing: ','
]

{ #category : 'accessing' }
NTNote >> title [

	title ifNil: [ self generateTitle].
	^ title
]

{ #category : 'accessing' }
NTNote >> title: aString [

	title := aString
]
