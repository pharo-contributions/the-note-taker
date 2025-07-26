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

	self
		executeCommand: self gitOnNoteFolder , ' add .'
		onExit: [ :process :outString :errString |
				process isSuccess ifTrue: [ ^ self ].
				IceGenericError signal: errString ]
]

{ #category : 'executing' }
NTSpGitCommand >> asSpecCommand [

	^ super asSpecCommand
		  iconName: #delete;
		  shortcutKey: $T meta;
		  yourself
]

{ #category : 'executing' }
NTSpGitCommand >> commit [

	self
		executeCommand: self gitOnNoteFolder , ' commit -m "saving"'
		onExit: [ :process :outString :errString |
				process isSuccess ifTrue: [ ^ self ].
				errString isEmpty ifTrue: [ ^ self ].
				IceGenericError signal: errString ]
]

{ #category : 'executing' }
NTSpGitCommand >> execute [

	(self projectPathString , '.git') asFileReference exists ifFalse: [
		self init ].
	
	self
		add;
		commit;
		pull;
		"merge;"
		push
]

{ #category : 'executing' }
NTSpGitCommand >> executeCommand: aString onExit: onExitBlock [

	| repoDirectory parent location |
	location := self projectPath.

	repoDirectory := location basename.
	parent := location parent.

	(OSPlatform current in: [ :aPlatform |
		 aPlatform isMacOSX or: [ aPlatform isUnix ] ])
		ifTrue: [
				self
					executeUsingUnixSubProcessRepoDirectory: repoDirectory
					parent: parent
					command: (aString withoutPrefix: 'git ')
					onExit: [ :process :outString :errString |
						onExitBlock value: process value: outString value: errString ] ]
		ifFalse: [
				self
					executeUsingWindowsSubProcessRepoDirectory: repoDirectory
					parent: parent
					command: aString
					onExit: [ :process :outString :errString |
						onExitBlock value: process value: outString value: errString ] ]
]

{ #category : 'executing' }
NTSpGitCommand >> executeUsingUnixSubProcessRepoDirectory: repoDirectory parent: parent command: aString onExit: onExitBlock [

	| outFullStream errFullStream osUnixSubprocessClass |
	osUnixSubprocessClass := self class environment
		                         at: #OSSUnixSubprocess
		                         ifAbsent: [
		                         self error:
			                         'Missing OSSUnixSubprocess class' ].

	outFullStream := WriteStream on: (String new: 10000).
	errFullStream := WriteStream on: (String new: 10000).

	osUnixSubprocessClass new
		command: '/usr/bin/git';
		arguments: (aString splitOn: String space);
		workingDirectory: parent fullName;
		redirectStdout;
		redirectStderr;
		runAndWaitPollingEvery: 1000 milliSecond asDelay
		doing: [ :process :stdStream :errStream |
				outFullStream nextPutAll: stdStream upToEnd.
				errFullStream nextPutAll: errStream upToEnd.
				self updateJobStatus: errFullStream contents ]
		onExitDo: [ :process :stdStream :errStream |
				outFullStream nextPutAll: stdStream upToEnd.
				errFullStream nextPutAll: errStream upToEnd.
				onExitBlock
					value: process
					value: outFullStream contents
					value: errFullStream contents ]
]

{ #category : 'executing' }
NTSpGitCommand >> executeUsingWindowsSubProcessRepoDirectory: repoDirectory parent: parent command: aString onExit: onExitBlock [

	| stderrFile stdoutFile command return osWSWinProcessClass |
	osWSWinProcessClass := self class environment
		                       at: #OSWSWinProcess
		                       ifAbsent: [
		                       self error: 'Missing OSWSWinProcess class' ].

	stderrFile := FileLocator temp / 'git-stderr.txt'.
	stdoutFile := FileLocator temp / 'git-stdout.txt'.

	command := String streamContents: [ :stream |
			           stream
				           nextPutAll: aString;
				           nextPutAll: ' 2>> ';
				           nextPutAll: stderrFile fullName;
				           nextPutAll: ' 1>> ';
				           nextPutAll: stdoutFile fullName ].

	return := osWSWinProcessClass new
		          shellCommand: command;
		          creationFlags: 16r08000000;
		          workingDirectory: parent fullName;
		          run. "CREATE_NO_WINDOW"

	"We need to wait until the watcher, updates the exitCode"
	[ return isRunning or: [ return exitCode isNil ] ] whileTrue: [
			[ self updateJobStatus: stderrFile contents ]
				on: FileDoesNotExistException
				do: [ ].
			MorphicRenderLoop new doOneCycle.
			100 milliSecond wait ].

	onExitBlock
		value: return
		value: stdoutFile contents
		value: stderrFile contents.

	stderrFile ensureDelete.
	stdoutFile ensureDelete
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
NTSpGitCommand >> merge [

	self
		executeCommand: self gitOnNoteFolder , ' merge origin/master'
		onExit: [ :process :outString :errString |
				process isSuccess ifTrue: [ ^ self ].
				IceGenericError signal: errString ]
]

{ #category : 'executing' }
NTSpGitCommand >> projectPath [
	"Answer a <FileReference> with a local or remote path where notes will be committed"

	^ self settingsClass noteLocation
]

{ #category : 'executing' }
NTSpGitCommand >> projectPathString [
	"Answer a <String> with a local or remote path where notes will be committed"

	^ self projectPath fullName
]

{ #category : 'executing' }
NTSpGitCommand >> pull [

	self
		executeCommand: self gitOnNoteFolder , ' pull --ff-only origin master'
		onExit: [ :process :outString :errString |
				process isSuccess ifTrue: [ ^ self ].
				IceGenericError signal: errString ]
]

{ #category : 'executing' }
NTSpGitCommand >> push [

	self
		executeCommand: self gitOnNoteFolder , ' push origin master'
		onExit: [ :process :outString :errString |
				process isSuccess ifTrue: [ ^ self ].
				(errString includesSubstring: 'Permission denied (publickey)')
					ifTrue: [ IceAuthenticationError signal: errString ].
				IceGenericError signal: errString ]
]

{ #category : 'executing' }
NTSpGitCommand >> settingsClass [

	^ self application settings
]

{ #category : 'executing' }
NTSpGitCommand >> updateJobStatus: outputString [

	| job lines lastLine progress matches |
	job := CurrentJob value.
	job ifNil: [ ^ self ].

	lines := outputString lines.
	lines ifEmpty: [ ^ self ].

	lastLine := lines last.
	progress := 0.

	(lastLine includesSubstring: 'Counting objects') ifTrue: [
		progress := 0 ].

	(lastLine includesSubstring: 'Compressing objects') ifTrue: [
		progress := 25 ].

	(lastLine includesSubstring: 'Receiving objects') ifTrue: [
		progress := 50 ].

	(lastLine includesSubstring: 'Resolving deltas') ifTrue: [
		progress := 75 ].

	(lastLine includesSubstring: 'done.') ifTrue: [ progress := 100 ].

	matches := lastLine allRegexMatches: '(\d+)%'.
	matches ifNotEmpty: [
		progress := progress + (matches first allButLast asNumber / 4) ].

	progress ifNil: [ ^ self ].

	job value: progress
]
