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
NTSpGitCommand >> add [

	LibC runCommand:
		self gitOnNoteFolder , ' add .'
]

{ #category : 'executing' }
NTSpGitCommand >> commit [

	LibC runCommand: self gitOnNoteFolder , ' commit -m "saving"'
]

{ #category : 'executing' }
NTSpGitCommand >> execute [

	(self projectPathString , '.git') asFileReference exists ifFalse: [
		self init ].

	self
		add;
		commit;
		push
]

{ #category : 'executing' }
NTSpGitCommand >> gitOnNoteFolder [

	^ 'git -C ' , self projectPathString
]

{ #category : 'executing' }
NTSpGitCommand >> githubPathString [
	"Answer a <String> with a local or remote path where notes will be committed"

	^ self settingsClass githubPathString
]

{ #category : 'executing' }
NTSpGitCommand >> init [

	LibC runCommand: self gitOnNoteFolder , ' init'.
	LibC runCommand:
		self gitOnNoteFolder , ' remote add origin ' , self githubPathString
]

{ #category : 'executing' }
NTSpGitCommand >> projectPathString [
	"Answer a <String> with a local or remote path where notes will be committed"

	^ self settingsClass noteLocation fullName
]

{ #category : 'executing' }
NTSpGitCommand >> pull [

	LibC runCommand:
		self gitOnNoteFolder , ' pull'
]

{ #category : 'executing' }
NTSpGitCommand >> push [

	LibC runCommand: self gitOnNoteFolder , ' push -f origin master'
]

{ #category : 'executing' }
NTSpGitCommand >> settingsClass [

	^ self application settings
]
