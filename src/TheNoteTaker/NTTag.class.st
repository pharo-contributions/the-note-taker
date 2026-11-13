"
A note tag object contains the necessary attributes and methods to represent a tag associated with notes.
(Similar to NTTag, who is the same object for the note, maybe refactor by make a generic object Tag for all object)

## Attributes

- tagName: A string representing the name or label of the tag.
- notes: A collection (list, set, or other data structure) of notes associated with the tag.

## Main methods

- Add Note: To associate a note with the tag.
- Remove Note: To disassociate a note from the tag.
- Rename Tag: To change the name of the tag.
- Delete Tag: To remove the tag entirely.
- Get Notes: To retrieve all notes associated with the tag.
- Accesss tag name: To retrieve the name of the tag.


A tag name is trimmed and has no comma, double quote or backslash (see `NTTag class>>#cleanName:`): commas separate the tags in the metadata of a note file, and quotes and backslashes are not escaped when Microdown writes the metadata, which would lose all the tags of the note when it is read again.
"
Class {
	#name : 'NTTag',
	#superclass : 'Object',
	#instVars : [
		'notes',
		'tagName'
	],
	#category : 'TheNoteTaker-Core',
	#package : 'TheNoteTaker',
	#tag : 'Core'
}

{ #category : 'naming' }
NTTag class >> cleanName: aString [
	"Answer aString trimmed and without the characters that would break the metadata of a note file:
	commas separate the tags, quotes and backslashes are not escaped when the metadata is written"

	^ (aString reject: [ :each | ',"\' includes: each ]) trimBoth
]

{ #category : 'instance creation' }
NTTag class >> newNamed: aString [
	"Answer a new tag named aString"
	
	^ self new 
		tagName: aString;
		yourself
]

{ #category : 'adding' }
NTTag >> addNote: aNTNoteObject [

	aNTNoteObject addTag: self.
	self notes add: aNTNoteObject
]

{ #category : 'accessing' }
NTTag >> hasNote: aNTNoteObject [

	^ notes includes: aNTNoteObject 
]

{ #category : 'initialization' }
NTTag >> initialize [

	super initialize.
	self notes: Set new
]

{ #category : 'accessing' }
NTTag >> notes [

	^ notes
]

{ #category : 'accessing' }
NTTag >> notes: anObject [

	notes := anObject
]

{ #category : 'removing' }
NTTag >> removeNote: aNTNoteObject [

	self notes remove: aNTNoteObject ifAbsent: [ ]
]

{ #category : 'accessing' }
NTTag >> tagName [
	"Answer a <String> representing the receiver's name"
	
	^ tagName
]

{ #category : 'accessing' }
NTTag >> tagName: aString [
	"Set the name of the receiver, cleaned so that it can be saved in a note file"

	tagName := self class cleanName: aString
]
