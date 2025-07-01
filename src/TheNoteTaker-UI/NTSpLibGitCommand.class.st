"
Implements logic to add a single note to a note taking application. Particularily, it provides a user-request dialog to ask for note input information to be added.
"
Class {
	#name : 'NTSpLibGitCommand',
	#superclass : 'NTSpAbstractCommand',
	#instVars : [
		'repo',
		'remote'
	],
	#category : 'TheNoteTaker-UI-Commands',
	#package : 'TheNoteTaker-UI',
	#tag : 'Commands'
}

{ #category : 'default' }
NTSpLibGitCommand class >> defaultDescription [

	^ 'Save on git'
]

{ #category : 'default' }
NTSpLibGitCommand class >> defaultName [

	^ 'Git Save'
]

{ #category : 'executing' }
NTSpLibGitCommand >> add [

	| index |
	index := repo index.
	index addAll.
	index free
]

{ #category : 'executing' }
NTSpLibGitCommand >> commit [

	| signature tree commitId |
	signature := LGitSignature
		             name: 'Quentin'
		             email: 'quentin.moutte.etu@univ-lille.fr'.

	"6. Écrire l’arbre"
	tree := repo index writeTreeAndReturnOid.
	repo index free.

	"7. Créer un commit via LGitCommitBuilder"
	commitId := (LGitCommitBuilder of: repo)
		            tree: (LGitTree of: repo fromId: tree);
		            message: 'SAVING' withUnixLineEndings;
		            parents: "(repo isUnborn
				             ifTrue: [ #(  ) ]
				             ifFalse: [ self libGitCommitsFrom: repo for: #(  ) ])" #(  );
		            author: signature;
		            committer: signature;
		            writeCommit;
		            "FFI is expecting an string"commitId
]

{ #category : 'executing' }
NTSpLibGitCommand >> execute [

	self
		init;
		add;
		commit;
		"pull;"
		push.

	repo free
]

{ #category : 'executing' }
NTSpLibGitCommand >> githubPathString [
	"Answer a <String> with a local or remote path where notes will be committed"

	^ self settingsClass githubPathString
]

{ #category : 'executing' }
NTSpLibGitCommand >> init [

	<repositoryHandleAccessor>
	(repo isNil or: [ repo isNull ]) ifFalse: [ ^ self ].

	repo := (LGitRepository on: self projectPath) open.
	repo checkout: 'master'.
	remote := repo origin.
	remote setUrl: self githubPathString
]

{ #category : 'executing' }
NTSpLibGitCommand >> projectPath [
	"Answer a <FileReference> with a local or remote path where notes will be committed"

	^ self settingsClass noteLocation
]

{ #category : 'executing' }
NTSpLibGitCommand >> projectPathString [
	"Answer a <String> with a local or remote path where notes will be committed"

	^ self projectPath fullName
]

{ #category : 'executing' }
NTSpLibGitCommand >> pull [

	| aLGitAnnotatedCommit |
	"repo fetchFrom: remote remoteName."
	remote fetch.
	repo merge: remote
]

{ #category : 'executing' }
NTSpLibGitCommand >> push [

	"remote pushWithRefSpec: aRefSpec pushOptions: pushOptions"
	
	| gitRemote |
	gitRemote := (LGitRemote
		              of: repo
		              named: remote remoteName) lookup.
	self pushBranchToRemote: remote gitRemote: gitRemote
]

{ #category : 'executing' }
NTSpLibGitCommand >> pushBranchToRemote: aRemote gitRemote: gitRemote [

	| pushOptions credentials |
	credentials := LGitCredentialsSSH
		               username: 'moufort'
		               passphrase: 'ShQDgihTB6WSw3B'
		               publicKeyReference:
		               FileLocator home asFileReference / '.ssh'
		               / 'id_ed25519.pub'
		               privateKeyReference:
		               FileLocator home asFileReference / '.ssh'
		               / 'id_ed25519'.

	"pushOptions := gitRemote ffiLibrary uniqueInstance
		               pushOptionsStructureClass defaults
		               callbacks:
			               (gitRemote ffiLibrary uniqueInstance
				                remoteCallbacksStructureClass withProvider:
					                IceCredentialsProvider) yourself;
		               yourself.

	gitRemote
		pushWithRefSpec: (LGitRefSpec new
				 source: 'refs/heads/master';
				 destination: 'refs/heads/master';
				 yourself)
		pushOptions: pushOptions"
		
	pushOptions := gitRemote ffiLibrary uniqueInstance
		               pushOptionsStructureClass defaults
		               callbacks:
			               ((gitRemote ffiLibrary uniqueInstance
				                 remoteCallbacksStructureClass withProvider:
					                 (IceCredentialsProvider defaultForRemote:
							                  aRemote))
				                yourself);
		               yourself.

	Iceberg configureLGitProxyOpt: pushOptions proxyOptions.

	gitRemote
		pushWithRefSpec: (LGitRefSpec new
				 source: 'refs/heads/master';
				 destination: 'refs/heads/master';
				 yourself)
		pushOptions: pushOptions
]

{ #category : 'executing' }
NTSpLibGitCommand >> settingsClass [

	^ self application settings
]
