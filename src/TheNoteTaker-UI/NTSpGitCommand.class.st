"
Implements logic to add a single note to a note taking application. Particularily, it provides a user-request dialog to ask for note input information to be added.
"
Class {
	#name : 'NTSpGitCommand',
	#superclass : 'NTSpAbstractCommand',
	#category : 'TheNoteTaker-UI-Commands',
	#package : 'TheNoteTaker-UI',
	#tag : 'Commands'
}

{ #category : 'default' }
NTSpGitCommand class >> defaultDescription [

	^ 'Save on git'
]

{ #category : 'default' }
NTSpGitCommand class >> defaultName [

	^ 'Git Save'
]

{ #category : 'executing' }
NTSpGitCommand >> execute [
	
	NTGitExecutor new add; commit; push

	
	
]
