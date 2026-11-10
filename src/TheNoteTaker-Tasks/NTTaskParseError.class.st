"
I am signaled by `NTTaskReader` when a line of a task file cannot be read.

## Responsibility:

- I know the number of the faulty line and its text, so an editor can highlight it.
- My message text says what was expected.

## Collaborators: 

- `NTTaskReader`: signals me.
- The task editor (Text tab): catches me and refuses to switch back to the List tab.

## Public API and Key Messages

- `NTTaskParseError signalLine: 3 text: 'foo' reason: 'item line expected'`
- `lineNumber`, `line`

See `NTTaskParseError class >> #exampleError`.

## Internal Representation

- `lineNumber`: an Integer (1-based), `line`: a String.
"
Class {
	#name : 'NTTaskParseError',
	#superclass : 'Error',
	#instVars : [
		'lineNumber',
		'line'
	],
	#category : 'TheNoteTaker-Tasks-Format',
	#package : 'TheNoteTaker-Tasks',
	#tag : 'Format'
}

{ #category : 'examples' }
NTTaskParseError class >> exampleError [

	<sampleInstance>
	^ self new
		  lineNumber: 2;
		  line: 'not an item';
		  messageText: 'Line 2: item line expected';
		  yourself
]

{ #category : 'signalling' }
NTTaskParseError class >> signalLine: aNumber text: aString reason: aReason [

	^ self new
		  lineNumber: aNumber;
		  line: aString;
		  signal: (String streamContents: [ :stream |
						   stream
							   nextPutAll: 'Line ';
							   print: aNumber;
							   nextPutAll: ': ';
							   nextPutAll: aReason ])
]

{ #category : 'accessing' }
NTTaskParseError >> line [

	^ line
]

{ #category : 'accessing' }
NTTaskParseError >> line: aString [

	line := aString
]

{ #category : 'accessing' }
NTTaskParseError >> lineNumber [

	^ lineNumber
]

{ #category : 'accessing' }
NTTaskParseError >> lineNumber: anInteger [

	lineNumber := anInteger
]
