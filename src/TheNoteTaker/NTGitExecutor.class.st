"
I'm simple wrapper around git unix commands.
"
Class {
	#name : 'NTGitExecutor',
	#superclass : 'Object',
	#category : 'TheNoteTaker-Utilities',
	#package : 'TheNoteTaker',
	#tag : 'Utilities'
}

{ #category : 'adding' }
NTGitExecutor >> add [

	LibC runCommand: self gitMinusCString , self projectPathString , ' add .'
]

{ #category : 'adding' }
NTGitExecutor >> commit [

	LibC runCommand: self gitMinusCString , self projectPathString , ' commit -m "saving"'

]

{ #category : 'adding' }
NTGitExecutor >> gitMinusCString [

	^ 'git -C '
]

{ #category : 'accessing' }
NTGitExecutor >> githubPathString [
	"Answer a <String> with a local or remote path where notes will be committed"

	^ self settingsClass githubPathString
]

{ #category : 'adding' }
NTGitExecutor >> init [

	LibC runCommand: self gitMinusCString , self projectPathString , ' init'.
	LibC runCommand: self gitMinusCString , self projectPathString , ' add origin ' , self githubPathString 
]

{ #category : 'initialization' }
NTGitExecutor >> initialize [

	super initialize.
	
	(self projectPathString, '.git') asFileReference exists ifFalse: [ self init ]
]

{ #category : 'accessing' }
NTGitExecutor >> projectPathString [
	"Answer a <String> with a local or remote path where notes will be committed"

	^ self settingsClass projectPathString
]

{ #category : 'adding' }
NTGitExecutor >> pull [

	LibC runCommand: self gitMinusCString , self projectPathString , ' pull'
]

{ #category : 'adding' }
NTGitExecutor >> push [

	LibC runCommand: self gitMinusCString , self projectPathString , ' push ' , self githubPathString, ' HEAD:main'.
]

{ #category : 'initialization' }
NTGitExecutor >> settingsClass [

	^ NTSettings
]
