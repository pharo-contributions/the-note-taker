"
I'm simple wrapper around git unix commands.
"
Class {
	#name : 'NTGitExecutor',
	#superclass : 'Object',
	#instVars : [
		'projectPathString'
	],
	#category : 'TheNoteTaker',
	#package : 'TheNoteTaker'
}

{ #category : 'adding' }
NTGitExecutor >> add [
	"I will avoid to hardcode path in the future"

	LibC runCommand: self gitMinusCString , projectPathString , ' add ', projectPathString, '/*'
]

{ #category : 'adding' }
NTGitExecutor >> commit [

	LibC runCommand: 'git -C /Users/ducasse/Workspace/FirstCircle/Writing/Working/researchnotes commit -m "saving"'.

]

{ #category : 'adding' }
NTGitExecutor >> gitMinusCString [

	^ 'git -C '
]

{ #category : 'adding' }
NTGitExecutor >> initialize [

	super initialize.
	projectPathString := '/Users/ducasse/Workspace/FirstCircle/Writing/Working/researchnotes'
]

{ #category : 'accessing' }
NTGitExecutor >> projectPathString: aString [

	projectPathString := aString
]

{ #category : 'adding' }
NTGitExecutor >> push [

	LibC runCommand: self gitMinusCString , projectPathString , ' push'
]
