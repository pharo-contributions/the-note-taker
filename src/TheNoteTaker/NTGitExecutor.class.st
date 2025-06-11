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

	LibC runCommand: self gitMinusCString , self projectPathString , ' add ', self projectPathString , '/*'
]

{ #category : 'adding' }
NTGitExecutor >> commit [

	LibC runCommand: self gitCommitCommand

]

{ #category : 'adding' }
NTGitExecutor >> gitCommitCommand [
	"Answer a <String> with a Git command to commit the current notes to a local folder"
	
	^ String streamContents: [ : stream |
		stream
			<< self gitMinusCString;
			<< self projectPathString;
			<< 'commit -m "saving"' ]
]

{ #category : 'adding' }
NTGitExecutor >> gitMinusCString [

	^ 'git -C '
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

	LibC runCommand: self gitMinusCString , self projectPathString , ' push'
]

{ #category : 'initialization' }
NTGitExecutor >> settingsClass [

	^ NTSettings
]
