Class {
	#name : 'NTCommandLineHandler',
	#superclass : 'CommandLineHandler',
	#category : 'TheNoteTaker-Base',
	#package : 'TheNoteTaker',
	#tag : 'Base'
}

{ #category : 'accessing' }
NTCommandLineHandler class >> commandName [

	^ 'note'
]

{ #category : 'activation' }
NTCommandLineHandler >> activate [

	OSWindowDriver current startUp: true.
	NTSpApplication new start.
]
