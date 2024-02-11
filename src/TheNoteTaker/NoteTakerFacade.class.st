Class {
	#name : 'NoteTakerFacade',
	#superclass : 'Object',
	#instVars : [
		'notes'
	],
	#category : 'TheNoteTaker-Core',
	#package : 'TheNoteTaker',
	#tag : 'Core'
}

{ #category : 'adding' }
NoteTakerFacade >> addNoteNamed: aNoteName [

	self notes add: (self newNoteNamed: aNoteName)
]

{ #category : 'initialization' }
NoteTakerFacade >> initialize [

	self notes: OrderedCollection new.
]

{ #category : 'adding' }
NoteTakerFacade >> newNoteNamed: aNoteName [

	^ NTNoteObject named: aNoteName
]

{ #category : 'adding' }
NoteTakerFacade >> notes [

	^ notes
]

{ #category : 'accessing' }
NoteTakerFacade >> notes: aCollection [ 
	notes := aCollection
]
