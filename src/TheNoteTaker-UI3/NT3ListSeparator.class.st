"
I am a group header in the note list, such as November 2026 or #pharo. I cannot be selected.

## Responsibility:

- I know my label.
- I am not a note (`isNote` answers false).

## Collaborators:

- `NT3ListMode` subclasses create me; `NT3NoteRowPresenter` shows me.

## Public API and Key Messages

- `NT3ListSeparator label: aString`, `label`

```
NT3ListSeparator label: 'November 2026'
```

## Internal Representation

- `label`: a String.
"
Class {
	#name : 'NT3ListSeparator',
	#superclass : 'Object',
	#instVars : [
		'label'
	],
	#category : 'TheNoteTaker-UI3',
	#package : 'TheNoteTaker-UI3'
}

{ #category : 'examples' }
NT3ListSeparator class >> example [

	<sampleInstance>
	^ self label: 'November 2026'
]

{ #category : 'instance creation' }
NT3ListSeparator class >> label: aString [

	^ self new
		  label: aString;
		  yourself
]

{ #category : 'accessing' }
NT3ListSeparator >> label [

	^ label
]

{ #category : 'accessing' }
NT3ListSeparator >> label: aString [

	label := aString
]

{ #category : 'printing' }
NT3ListSeparator >> printOn: aStream [

	super printOn: aStream.
	aStream
		nextPut: $(;
		nextPutAll: label asString;
		nextPut: $)
]
