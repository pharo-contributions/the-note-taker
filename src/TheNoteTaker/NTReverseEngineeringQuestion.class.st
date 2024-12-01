"
- get example destroys the contents of the current notes! argh

- I do not get why a tag keeps a reference to notes. May this is for the search

- I do not get why the method isNote is called there

```
hasSelectedNote
	""Answer <true> if the receiver has a selected note""

	^ notesIndexPresenter listSize ~= 0 and: [ self selectedNote isNote ]
```
If I have a list of notes why could it hold something else?


- why name of file is so complex

```
nameForFile

	^ String streamContents: [ :stream |
		stream 
			<< self title asLowercase ]
```

and is not just 

```
nameForFile

	^ self title asLowercase 
```	


- Notes should be saved in a folder

- Test execution should not polute the note folder

- ProjectPathString should be used and the setting should be merged into the class managing the projectPathString no need for a class. 

- The logic of basename is suspicious

```
basename
	""Answer a String representing the receiver's file name""

	| dateCreationOfFileReference |
	fileReference ifNil: [
		nameOfFileReferenceBeforeSaved := 'Untitled'.
		^ nameOfFileReferenceBeforeSaved ].
	
	nameOfFileReferenceBeforeSaved := fileReference basename.
	dateCreationOfFileReference := Date today yyyymmdd.
	(fileReference basename includesSubstring: dateCreationOfFileReference) 
		ifFalse: [ ^ dateCreationOfFileReference , '_' , fileReference basename ].
	^ fileReference basename
```	

indeed what happens if I have a file with a date that is not the one of today?


- MDFile proposes contents: and save:. This is confusing.


- Stuff to be finished

```
noteInformation: aNtNodeModel

	self shouldBeImplemented.
	^ aNtNodeModel 
```

"
Class {
	#name : 'NTReverseEngineeringQuestion',
	#superclass : 'Object',
	#category : 'TheNoteTaker-Core',
	#package : 'TheNoteTaker',
	#tag : 'Core'
}
